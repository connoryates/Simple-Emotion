## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for audio storage

package Simple::Emotion::Storage::Audio;
use Moo::Role;

use Simple::Emotion::Constants;

use constant _ROUTE => 'storage/v0/audio';

has upload_url_endpoint  => ( is => 'rw', default => sub { '/uploadFromUrl'  } );
has get_upload_endpoint  => ( is => 'rw', default => sub { '/getUploadUrl'   } );
has get_download_enpoint => ( is => 'rw', default => sub { '/getDownloadUrl' } );

my @methods = qw(
    upload_from_url add_audio
    list_audio      get_audio
    get_upload_url  audio_exists
    move_audio      remove_audio
    get_upload_url  get_download_url
);

around @methods => sub {
    my ($orig, $self, $params) = @_;

    $self->route(_ROUTE);
    $self->params($params) if $params;

    $self->$orig(@_);
    $self->make_request;
};

sub add_audio {
    my $self = shift;

    $self->_create_request($self->add_endpoint, POST);    
}

sub upload_from_url {
    my $self = shift;

    $self->_create_request($self->upload_url_endpoint, POST);
}

sub list_audio {
    my $self = shift;

    $self->_create_request($self->list_endpoint, POST);
}

sub get_audio {
    my $self = shift;

    $self->_create_request($self->get_endpoint, POST);
}

sub audio_exists {
    my $self = shift;

    $self->_create_request($self->exists_endpoint, POST);
}

sub get_download_url {
    my $self = shift;

    $self->_create_request($self->get_download_endpoint, POST);
}

sub get_upload_url {
    my $self = shift;

    $self->_create_request($self->get_upload_endpoint, POST);
}

sub move_audio {
    my $self = shift;

    $self->_create_request($self->move_endpoint, POST);
}

sub remove_audio {
    my $self = shift;

    $self->_create_request($self->remove_endpoint, POST);
}

1;

__END__

=pod

=head1 sub upload_from_url

    Upload binary data from a url into a matching audio file.

    Method for endpoint: /audio/{_id}/uploadFromUrl

    Authentication: true

    Expects params:
        - id :string
        - owner :HASH
            - _id :string
            - type :string
        - service :string
        - name :string
        - url :string    REQUIRED
        - tags :ARRAY
        - callback :HASH
            - completed :HASH
                - url :string
                - secret :string

    Responses:
        - 200 OK
            {
                "operation": {
                    "_id": "string"
                }
            }

        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error

=cut
