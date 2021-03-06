## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Wrapper around simple emotion API

package Simple::Emotion;
use Moo;
with 'Simple::Emotion::OAuth',
     'Simple::Emotion::Endpoints';

use 5.008_005;
our $VERSION = '0.01';

use URI;
use Furl;
use Try::Tiny;
use HTTP::Request;
use Carp qw(carp cluck);
use List::Util qw(first);
use Simple::Emotion::Constants;
use Scalar::Util qw(looks_like_number);
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
has audio_id     => ( is => 'rw' );
has folder_id    => ( is => 'rw' );
has operation_id => ( is => 'rw' );

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
has user_agent   => ( is => 'lazy', handles => [qw/request/] );
has http_request => ( is => 'lazy', clearer => 1 );

has url => ( is => 'ro', lazy => 1, default => sub { shift->uri->as_string } );

has content      => ( is => 'rw', clearer => 1 );
has callback_url => (
    is      => 'rw',
    trigger => sub {
        my ($self, $url) = @_;

        carp "Attribute callback_url must be a string"
          if ref $url;

        my $params = decode_json($self->params || '{}');

        $params->{operation}->{callbacks}->{completed}->{url} = $url;
        $self->params($params);
    }
);

has callback_secret => (
    is      => 'rw',
    trigger => sub {
        my ($self, $secret) = @_;

        carp "Attribute callback_secret must be a string"
          if ref $secret;

        my $params = decode_json($self->params || '{}');

        $params->{operation}->{callbacks}->{completed}->{secret} = $secret;
        $self->params($params);
    }
);

has tags => (
    is      => 'rw',
    clearer => 1,
    trigger => sub {
        my ($self, $tags) = @_;

        $tags = ref $tags ? $tags : [ $tags ];

        $self->_set_param(['tags', $tags]);
    },
);

has service => (
    is      => 'rw',
    clearer => 1,
    trigger => sub {
        my ($self, $service) = @_;

        carp "Attribute service must be a Str"
          if ref $service;

        $self->_set_param(['service', $service]);
    },
);

has basename => (
    is       => 'rw',
    clearer  => 1,
    trigger  => sub {
        my ($self, $basename) = @_;

        carp "Attribute basename must be a Str"
          if ref $basename;

        $self->_set_param(['basename', $basename]);
    },
);

# trigger these as well? Gut says no
has analysis_version => (
    is      => 'rw',
    clearer => 1,
    default => sub { +{ latest => true } }, 
);

has analysis_type => (
    is      => 'rw',
    clearer => 1,
    default => sub { 'transcribe-raw-speech' },
);

has diarized => ( is => 'rw', clearer => 1, default => sub { false } );

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

    my $uri = URI->new($self->scheme . $self->base);
    $uri->path($self->request_path);

    return $uri;
}

sub _set_scope { push @{ shift->scope }, shift }
sub _get_scope { return join ' ', shift->scope }

sub _set_param {
    my ($self, $param) = @_;

    my $params = decode_json($self->params)
      if $self->params and !ref $self->params;

    $params ||= +{};

    my ($key, $val) = ($param->[0], $param->[1]);
    $params->{$key} = $val;

    $self->params($params);
}

sub last_response { shift->content }

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
        my $resp = $self->request($self->http_request);

        die $resp->content unless $resp->is_success;

        $content = decode_json($resp->content);
    } catch {
        $self->_error($_);
    } finally {
        $self->_clean_up;
    };

    $self->content($content);

    # No ID returned from OAuth request
    my $caller = caller;
    $self->_set_id unless $caller =~ /OAuth$/;

    return $content;
}

sub id {
    my $self = shift;

    my $id = $self->_extract_id
      or cluck "No _id returned from last request to " . $self->url;

    return $id || VOID;
}

sub audio_to_text {
    my ($self, $audio_id) = @_;

    $audio_id ||= $self->audio_id;

    $self->get_analysis({
        analysis  => {
            audio => {
                _id => $audio_id,
            },
            type    => $self->analysis_type,
            version => $self->analysis_version,
        },
    });

    return $self->_extract_audio_text;
}

sub transload_audio {
    my ($self, $input) = @_;

    my $url = ref $input ? $input->{url} : $input;

    carp "Missing url" unless defined $url;

    my ($payload, $basename);
    if (ref $input and $input->{name} and $input->{service}) {
        $payload = {
            folder => {
                name    => $input->{folder_name},
                service => $input->{service},
            }
        };

        $basename = $input->{basename} if defined $input->{basename};
    }
    elsif (!ref $input and $self->folder_id) {
        $payload = {
            folder  => {
                _id => $self->folder_id,
            },
        },
    }
    else {
        carp "Missing folder_id, or name and service";
    }

    $basename ||= $self->basename;

    $self->add_audio({
        audio => {
            basename => $basename,
        },
        destination => $payload,
    });

    carp "Missing audio_id" unless $self->audio_id;

    $self->upload_from_url({
        audio => {
            _id => $self->audio_id,
        },
        url => $url,
        operation => {
            tags  => $self->tags,
            callbacks => {
                completed  => {
                    url    => $self->callback_url,
                    secret => $self->callback_secret,
                },
            },
        },
    });

    return $self->operation_id;
}

sub operation_to_text {
    my ($self, $op_id) = @_;

    carp "Missing operation_id" unless $op_id;

    my $params = $self->_operation_params($op_id);

    carp "Missing audio_id, cannot convert operation to text"
      unless defined $params->{audio_id};

    return $self->audio_to_text($params->{audio_id});
}

sub transcribe_operation {
    my ($self, $op_id) = @_;

    carp "Missing operation_id" unless $op_id;

    my $params = $self->_operation_params($op_id);

    carp "Missing audio_id, cannot convert transcribe audio"
      unless defined $params->{audio_id};

    return $self->transcribe({
        audio => {
            _id => $params->{audio_id},
        },
        diarized  => $self->diarized,
        operation => {
            callbacks => {
                completed  => {
                    url    => $self->callback_url,
                    secret => $self->callback_secret,
                }
            }
        }
    });
}

sub _operation_params {
    my ($self, $op_id) = @_;

    $self->get_operation({
        operation => {
            _id => $op_id,
        },
    });

    return $self->content->{operation}->{parameters};
}

sub _set_id {
    my $self = shift;

    my $content = $self->content;

    while (my ($k, $v) = each %$content) {
        my $type_id = $k . '_id';

        if ($self->can($type_id)) {
            # Set each ID type after response
            $self->$type_id($v->{_id}) if defined $v->{_id};
        }
    }

    return;
}

sub _extract_audio_text {
    my $self = shift;

    my $content  = $self->content or carp "Cannot get audio text - no content returned";
    my $analyses = $content->{analyses} || $content->{analysis};

    carp "Missing analyses" unless $analyses;
    carp "Unsupported data structure" unless ref $analyses;

    if (ref $analyses eq 'HASH') {
        return join ' ', @{ $self->__extract_audio_text($analyses) };
    }
    elsif (ref $analyses eq 'ARRAY') {
        my @words = ();

        for my $analysis (@$analyses) {
            push @words, $self->__extract_audio_text($analysis);
        }

        return join ' ', @words;
    }

    cluck "Unsupported data structure found: " . ref $analyses;

    return;
}

sub __extract_audio_text {
    my ($self, $analysis) = @_;

    return unless $analysis;

    my $data = $analysis->{data};

    my @words = ();
    for my $t (@{ $data->{turns} }) {
        push @words, map { $_->{word} } @{ $t->{words} };
    }

    return \@words;
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

sub _clean_up {
    my $self = shift;

    $self->clear_http_request;
    $self->clear_params;
    $self->clear_uri;
    $self->clear_route;
    $self->clear_request_path;
    $self->clear_no_auth;
    $self->clear_content;
    $self->clear_tags;
    $self->clear_diarized;
}

1;

__END__

=encoding utf-8

=head1 NAME

Simple::Emotion - Transcribe and detect emotions from audio recordings.

=head1 SYNOPSIS

    use Simple::Emotion;

    my $emotion = Simple::Emotion->new(
        client_id     => $CLIENT_ID,
        client_secret => $CLIENT_SECRET,
    );

    $emotion->authorize;
    $emotion->scope('storage');

    $emotion->add_folder({
        folder => {
            basename => 'my_voicemail_folder',
        },
        destination => {
            folder => {
                owner => {
                    _id => $OWNER_ID,
                    type => 'user',
                },
            },
            service => 'voicemail_transcription',
            name => 'voicemail',
        },
    });

    # Retains the last ID returned
    my $folder_id = $emotion->id;

    # Create an audio folder to hold your recording
    $emotion->add_audio({
        folder => {
            basename => 'voicemail_1.mp3',
        },
        destination => {
            folder => {
                _id => $folder_id,
            }
        },
    });

    my $audio_id = $emotion->id;

    # Upload your recording directly from its url
    $emotion->upload_from_url({
        audio => {
            _id => $audio_id,
        },
        url => 'https://your-download-link',
        operation => {
            tags  => [qw(voicemail_transcription)],
            callbacks => {
                completed  => {
                    url    => 'https://your-apps-webhook',
                    secret => 'SUPER DUPER',
                },
            },
        },
    });

    # Wait for webhook...
    my $params = @_;

    my $op = $emotion->get_operation({
        operation => {
            _id => $params->{operation}->{_id},
        },
    });

    $emotion->transcribe({
        audio => {
            _id => $op->{audio}->{_id},
        },
    });

    # Wait for webhook...

    my $transcription = $emotion->audio_to_text($audio_id);

    # Get full analysis read out:

    my $analyses = $emotion->list_analysis({
        audio => {
            _id => $audio_id,
        },
    });

=head1 DESCRIPTION

Simple::Emotion is a wrapper around api.simpleemotion.com - a beta API capable of audio transcription and emotion detection.

[Official API documentation here.](https://api.simpleemotion.com/docs/storage/v0.html)

### Note:

This API is in v0, so breaking changes will occur

=head1 Constructor

    ## client_id

        Your ```client_id```

    ## client_secret

        Your ```client_secret```

    ## scope

        The scope of your workflow, as provided by the API specs. You can also use some handy aliases for common workflows:

            transcription => [qw(
                storage.audio.uploadFromUrl
                operations.get
                speech.transcribe
                storage.analysis.get
                storage.audio.add
            )];

    ## pre_auth

        Automatically get an ```access_token``` before you make your first request.

=head1 Attributes

=head1 Methods

=head1 AUTHOR

Connor Yates E<lt>connor.t.yates@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Connor Yates

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
