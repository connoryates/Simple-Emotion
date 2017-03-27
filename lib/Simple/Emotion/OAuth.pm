## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for OAuth

package Simple::Emotion::OAuth;
use Moo::Role;

use Simple::Emotion::Constants;
use Carp qw(carp);

use constant _ROUTE => '/oauth2/v0/';

has auth_endpoint => ( is => 'rw', default => sub { 'token' } );

our @OAUTH_METHODS = qw(token);

sub _auth_params {
    my $self = shift;

    return {
        client_id     => $self->client_id,
        client_secret => $self->client_secret,
        scope         => $self->scope,
        grant_type    => $self->grant_type,
    }
}

around @OAUTH_METHODS => sub {
    my ($orig, $self) = @_;

    $self->route(_ROUTE);
    $self->params($self->_auth_params);

    $self->$orig(@_);

    my $resp = $self->make_request;

    $self->access_token = $resp->{access_token} or carp "No access_token returned. Cannot authenticate";
    $self->token_type   = $resp->{token_type};
};

sub authorize {
    my $self = shift;

    return $self->token;
}

sub token {
    my $self = shift;

    $self->_create_request($self->auth_endpoint, POST);
}

1;

__END__

=pod

=head1 sub authorize

    Convienence method for sub token

    Method for endpoint: /oauth2/v0/token

    Authentication: true
        - client_id
        - client_secret

=head2 sub token

    Authenticate your app via OAuth2. Returns an access_token

    Method for endpoint: /oauth2/v0/token

    Authentication: true
        - client_id
        - client_secret
=cut
