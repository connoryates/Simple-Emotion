## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Wrapper around simple emotion API

package Simple::Emotion;
use Moo;
with 'Simple::Emotion::OAuth',
     'Simple::Emotion::Storage',
     'Simple::Emotion::Speech',
     'Simple::Emotion::Operation';

use 5.008_005;
our $VERSION = '0.01';

use URI;
use Furl;
use Try::Tiny;
use HTTP::Request;
use Carp qw(carp cluck);
use List::Util qw(first);
use Simple::Emotion::Constants;
use JSON::XS qw(encode_json decode_json);

has scheme => ( is => 'ro', default => sub { 'https://' } );

# OAuth2 credentials/token
has pre_auth      => ( is => 'rw', default => 0, clearer => 1 );
has no_auth       => ( is => 'rw', default => 0, clearer => 1 );
has client_id     => ( is => 'rw', default => sub { $ENV{SIMPLE_EMOTION_CLIENT_ID}     } );
has access_token  => ( is => 'rw', default => sub { $ENV{SIMPLE_EMOTION_ACCESS_TOKEN}  } );
has client_secret => ( is => 'rw', default => sub { $ENV{SIMPLE_EMOTION_CLIENT_SECRET} } );

has grant_type => ( is => 'rw', default => sub { 'client_credentials' } );
has token_type => ( is => 'rw', default => sub { 'Bearer' } );

has scope => (
    is      => 'rw',
    default => sub { [] },
    coerce  => sub {
        return $Simple::Emotion::Constants::TRANSCRIPTION_FLOW_SIMPLE
          if $_[0] eq 'transcription';

        $_[0];
    },
    trigger => sub {
        # Not sure if needed anymore
        my $self   = shift;
        my $params = decode_json($self->params);

        $params->{scope} = $self->_get_scope;
        $self->params($params);
    }
);

# API Specific parameters
has org_id    => ( is => 'rw' );
has user_id   => ( is => 'rw' );
has audio_id  => ( is => 'rw' );
has folder_id => ( is => 'rw' );
has no_params => ( is => 'rw', clearer => 1 );

# HTTP request details
has route        => ( is => 'rw', clearer => 1, default => sub { '/' } );
has request_path => ( is => 'rw', clearer => 1, default => sub { '/' } );
has content_type => ( is => 'rw', default => sub { 'application/json' } );

has params  => (
    is      => 'rw',
    coerce  => sub { encode_json(shift) },
    default => sub { +{ scope => shift->scope } },
    clearer => 1,
);

has query_params => (
    is  => 'rw',
    isa => sub {
        carp "Request params must be a HASH or string"
          if ref $_[0] and ref $_[0] ne 'HASH';
    },
    # TODO: remove this
    default => sub { my $self = shift; $self->audio_id || $self->org_id || $self->user_id || '/' },
    coerce  => sub { return ref $_[0] ? join '/', values %{ $_[0] } : $_[0] },
);

has request_type => (
    is  => 'rw',
    isa => sub {
        my $req = uc shift;
        carp "Invalid request type"
          unless first { $req eq  $_ } REST_HTTP;
    },
    coerce => sub { uc shift },
);

# Request and URI details
has uri          => ( is => 'lazy', clearer => 1 );
has base         => ( is => 'lazy' );
has splat        => ( is => 'rw', default => 0, predicate => 1 );
has user_agent   => ( is => 'lazy', handles => [qw/request/] );
has http_request => ( is => 'lazy', clearer => 1 );

has url => ( is => 'ro', lazy => 1, default => sub { shift->uri->as_string } );

has content         => ( is => 'rw', clearer => 1 );
has callback_url    => ( is => 'rw' );
has callback_secret => ( is => 'rw' );

sub _build_base       { return URI->new(BASE_URL) }
sub _build_user_agent { return Furl->new }

sub _build_http_request {
    my $self = shift;

    return HTTP::Request->new(
        $self->request_type => $self->uri->as_string,
        $self->headers,
        $self->params,
    );
}

sub _build_uri {
    my $self = shift;

    my $uri  = URI->new($self->scheme . $self->base);
    my $path = $self->_replace_splat($self->request_path);

    $self->no_params ?
      $uri->path($path) :
      $uri->path($path . $self->query_params);

    return $uri;
}

sub _set_scope { push @{ shift->scope }, shift }
sub _get_scope { return join ' ', shift->scope }

sub BUILD {
    my $self = shift;

    $self->authorize unless $self->access_token
      or $self->no_auth or !$self->pre_auth;
}

sub headers {
    my $self = shift;

    my @headers = ();

    push @headers, 'Content-Type' => $self->content_type;
    push @headers, 'Authorization' => 'Bearer ' . $self->access_token
     if $self->access_token;

    return \@headers;
}

sub make_request {
    my $self = shift;

    my $content;
    try {
        use Data::Dumper;
        print Dumper $self->http_request;
        my $resp = $self->request($self->http_request);

        die $resp->content unless $resp->is_success;

        $content = decode_json($resp->content);
    } catch {
        $self->_error($_);
    } finally {
        $self->_clean_up;
    };

    $self->content($content);

    return $content;
}

sub id {
    my $self = shift;

    my $id = $self->_extract_id
      or cluck "No _id returned from last request to " . $self->url;

    return $id || VOID;
}

sub _create_request {
    my ($self, $endpoint, $request_type) = @_;

    $self->request_path($self->route . $endpoint);
    $self->request_type($request_type);
}

sub _extract_id {
    my $self = shift;

    my $content = $self->content;

    if (ref $content and ref $content eq 'HASH') {
        while (my ($k, $v) = each %{ $content }) {
            my $id = $k . '_id';

            if (first { $_ =~ /$id/ } $self->meta->get_attribute_list) {
                if (ref $v and ref $v eq 'HASH') {
                    return $v->{_id} if $v->{_id};
                }
            }
        }
    }

    return;
}

sub _error {
    my ($self, $err) = @_;

    if ($err =~ /^HTTP request/) { 
        carp "HTTP request to " . $self->url . " failed. Reason: $err";
    }

    # If the exception is not a custom one,
    # it must be JSON from the API
    my $decoded;
    try {
        $decoded = decode_json($err) or die $!;
    } catch {
        carp "Unhandled exception: $err";
    };

    carp $decoded if $decoded;

    return;
}

sub _valid_splat {
    my ($self, $splat) = @_;

    return 1 if first { $splat eq $_ } 
      grep { /_id$/ } $self->meta->get_attribute_list;

    return;
}

sub _replace_splat {
    my ($self, $path) = @_;

    return unless $path;

    if (my @splat = ($path =~ m!/\#\{([a-z_]+)\}/!g)) {
        for my $splat (@splat) {
            if ($self->_valid_splat($splat)) {
                # Per API docs: "Use - if not known."
                my $param = $self->$splat || '-';

                $path =~ s!#\{$splat\}!$param!g;
            }
        }
    }

    return $path;
}

sub _clean_up {
    my $self = shift;

    $self->clear_http_request;
    $self->clear_params;
    $self->clear_uri;
    $self->clear_route;
    $self->clear_request_path;
    $self->clear_no_params;
    $self->clear_no_auth;
    $self->clear_content;
}

1;

__END__

=encoding utf-8

=head1 NAME

Simple::Emotion - Detect emotions from audio recordings

=head1 SYNOPSIS

  use Simple::Emotion;

=head1 DESCRIPTION

Simple::Emotion is

=head1 AUTHOR

Connor Yates E<lt>connor.t.yates@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Connor Yates

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
