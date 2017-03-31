## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for analysis storage

package Simple::Emotion::Storage::Analysis;
use Moo::Role;

use Simple::Emotion::Constants;

use constant _ROUTE => '/storage/v0/analysis';

my @methods = qw(list_analysis get_analysis remove_analysis rename_analysis);

around @methods => sub {
    my ($orig, $self, $params) = @_;

    $self->route(_ROUTE);
    $self->params($params) if $params;

    $self->$orig(@_);
    $self->make_request;
};

sub list_analysis {
    my $self = shift;

    $self->_create_request($self->list_endpoint, POST);
}

sub get_analysis {
    my $self = shift;

    $self->_create_request($self->get_endpoint, POST);
}

sub remove_analysis {
    my $self = shift;

    $self->_create_request($self->remove_endpoint, POST);
}

sub rename_analysis {
    my $self = shift;

    $self->_create_request($self->rename_endpoint, POST);
}

1;

__END__

=pod

=head1 sub list_analysis

    List matching analysis objects.

    Method for endpoint: /storage/v0/analysis

    Authentication: true

    Expects params:
        - audio :HASH
            - _id :string
            - owner :HASH
                - _id :string
                - type :user
            - service :string
            - name :string

    Responses:
        - 200 OK
            {
                "offset": 0,
                "limit": 0,
                "total": 0,
                "analyses": [
                    {
                        "_id": "string",
                        "audio": {
                            "_id": "string"
                        },
                        "name": "string",
                        "type": "analyze-transcript",
                        "version": {
                            "major": 0,
                            "minor": 0,
                            "patch": 0,
                            "revision": 0
                        },
                        "data": {},
                        "states": {
                            "removed": true
                        },
                        "timestamps": {
                            "created": "2017-03-23T21:19:47Z",
                            "modified": "2017-03-23T21:19:47Z",
                            "removed": "2017-03-23T21:19:47Z"
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

=cut
