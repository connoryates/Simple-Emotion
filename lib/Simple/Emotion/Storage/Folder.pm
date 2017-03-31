## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for folder storage

package Simple::Emotion::Storage::Folder;
use Moo::Role;

use Simple::Emotion::Constants;

use constant _ROUTE => 'storage/v0/folder';

has add_folder_endpoint    => ( is => 'rw', default => sub { '/add'    } );
has list_folders_endpoint  => ( is => 'rw', default => sub { '/list'   } );
has folder_exists_endpoint => ( is => 'rw', default => sub { '/exists' } );
has get_folder_endpoint    => ( is => 'rw', default => sub { '/get'    } );

my @methods = qw(add_folder list_folders folder_exists get_folder);

around @methods => sub {
    my ($orig, $self, $params) = @_;

    $self->route(_ROUTE);
    $self->params($params) if $params;

    $self->$orig(@_);
    $self->make_request;
};

sub add_folder {
    my $self = shift;

    $self->_create_request($self->add_folder_endpoint, POST);
}

sub list_folders {
    my $self = shift;

    $self->_create_request($self->list_folders_endpoint, POST);
}

sub folder_exists {
    my $self = shift;

    $self->_create_request($self->folder_exists_endpoint, POST);
}

sub get_folder {
    my $self = shift;

    $self->_create_request($self->get_folder_endpoint, POST);
}

1;

__END__

=pod

=head1 add_folder

    Create a new folder to hold audio files

    Method for endpoint: POST => /storage/v0/folder

    Authentication: true

    Expects params:
        - destination :HASH
            - _id :string
            - owner :HASH
                - _id :string
                - type :user
            - service :string
            - name :string
        -basename :string 

    Responses:
        -200 OK
            {
                "_id": "string"
            }
        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error

=head2 sub list_folders

    Lists matching folder objects

    Method for endpoint: GET => /storage/v0/folder

    Authentication: true

    Expects params:
        - owner :HASH
            - _id :string
            - type :user
        - service :string
        - name :string

    Response:
        - 200 OK
        {
            "offset": 0,
            "limit": 0,
            "total": 0,
            "folders": [
                {
                    "_id": "string",
                    "owner": {
                        "_id": "string",
                        "type": "user"
                    },
                    "service": "string",
                    "name": "string",
                    "states": {
                        "removed": true
                    },
                    "timestamps": {
                        "created": "2017-03-24T17:18:38Z",
                        "modified": "2017-03-24T17:18:38Z",
                        "removed": "2017-03-24T17:18:38Z"
                    }
                }
            ]
        }
        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error


=head3 sub folder_exists

    Checks if a matching folder exists.

    Method for endpoint: HEAD => /storage/v0/folder/{_id}

    Authentication: true

    Expects params:
        - _id :string
        - owner :HASH
            - _id :string
            - type :user
        - service :string
        - name :string

    Responses:
        - 200 OK
            {
                "exists": true
            }
        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error


=head4 sub get_folder

    Get a matching folder

    Method for endpoint: GET => /storage/v0/folder/{_id}

    Expects params:
        - _id :string
        - owner :HASH
            - _id :string
            - type :user
        - service :string
        - name :string

    Responses:
        - 200 OK
            {
                "folder": {
                    "_id": "string",
                    "owner": {
                        "_id": "string",
                        "type": "user"
                    },
                    "service": "string",
                    "name": "string",
                    "states": {
                        "removed": true
                    },
                    "timestamps": {
                        "created": "2017-03-24T17:18:38Z",
                        "modified": "2017-03-24T17:18:38Z",
                        "removed": "2017-03-24T17:18:38Z"
                    }
                }
            }
        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error
=cut
