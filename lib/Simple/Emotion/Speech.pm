## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for analysis storage

package Simple::Emotion::Speech;
use Moo::Role;

use Simple::Emotion::Constants;

use constant _ROUTE => '/speech/v0';

has transcribe_endpoint => ( is => 'rw', default => sub { '/transcribe' } );
has detect_endpoint     => ( is => 'rw', default => sub { '/detect'     } );

our @SPEECH_METHODS = qw(transcribe detect);

around @SPEECH_METHODS => sub {
    my ($orig, $self, $params) = @_;

    $self->route(_ROUTE);
    $self->params($params) if $params;

    $self->$orig(@_);
    $self->make_request;
};

sub transcribe {
    my $self = shift;

    $self->_create_request($self->transcribe_endpoint, POST);
}

sub detect {
    my $self = shift;

    $self->_create_request($self->detect_endpoint, POST);
}

1;

__END__

=pod

=head1 sub transcribe

    Transcribe an audio recording, given an audio_id

    Method for endpoint: /speech/v0/transcribe

    Authentication: true

    Expects params:
        - TODO

    Responses:
        - TODO

=head2 sub detect

    # TODO

=cut
