## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Role for operation endpoints

package Simple::Emotion::Operation;
use Moo::Role;

use Simple::Emotion::Constants;

use constant _ROUTE => '/operations/v0';

my @methods = qw(get_operation list_operations remove_operation);

around @methods => sub {
    my ($orig, $self, $params) = @_;

    $self->route(_ROUTE);
    $self->params($params) if $params;

    $self->$orig(@_);
    $self->make_request;
};

sub get_operation {
    my $self = shift;

    $self->_create_request($self->get_endpoint, POST);
}

sub list_operations {
    my $self = shift;

    $self->_create_request($self->list_endpoint, POST);
}

sub remove_operation {
    my $self = shift;

    $self->_create_request($self->remove_endpoint, POST);
}

1;

__END__

=pod

=head1 sub get_operation

    Get a matching operation object

    Method for endpoint /operations/v0/get

    Authentication: true

    Expects params:
        - operation: HASH
           -  _id: string

    Responses:
        - 200 OK
            {
              "audio": {
                "_id": "string",
                "owner": {
                  "_id": "string",
                  "type": "user"
                },
                "type": "analyze-transcript",
                "parameters": {
                  "audio_id": "string"
                },
                "tags": [],
                "progress": {
                  "min": 0,
                  "value": 0,
                  "max": 0
                },
                "status": "string",
                "error": {
                  "code": 0,
                  "message": "string"
                },
                "result": {
                  "analysis_id": "string"
                },
                "states": {
                  "queued": true,
                  "completed": true,
                  "removed": true
                },
                "timestamps": {
                  "created": "2017-03-28T18:40:50Z",
                  "started": "2017-03-28T18:40:50Z",
                  "updated": "2017-03-28T18:40:50Z",
                  "completed": "2017-03-28T18:40:50Z",
                  "removed": "2017-03-28T18:40:50Z"
                }
              }
            }

        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error

=head2 sub list_operations

    List matching operations objects

    Method for endpoint: /operations/v0/list

    Authentication: true

    Expects params:
        - offset :int
        - limit :int
        - operation :HASH
            - owner :ARRAY(:HASH)
                - _id :string
                - type :string
        - type :string
        - tags :ARRAY
        - state :HASH
            - queued :bool
            - completed :bool
            
    Responses:
        - 200 OK
            {
              "offset": 0,
              "limit": 0,
              "total": 0,
              "operations": [
                {
                  "_id": "string",
                  "owner": {
                    "_id": "string",
                    "type": "user"
                  },
                  "type": "analyze-transcript",
                  "parameters": {
                    "audio_id": "string"
                  },
                  "tags": [],
                  "progress": {
                    "min": 0,
                    "value": 0,
                    "max": 0
                  },
                  "status": "string",
                  "error": {
                    "code": 0,
                    "message": "string"
                  },
                  "result": {
                    "analysis_id": "string"
                  },
                  "states": {
                    "queued": true,
                    "completed": true,
                    "removed": true
                  },
                  "timestamps": {
                    "created": "2017-03-28T18:40:50Z",
                    "started": "2017-03-28T18:40:50Z",
                    "updated": "2017-03-28T18:40:50Z",
                    "completed": "2017-03-28T18:40:50Z",
                    "removed": "2017-03-28T18:40:50Z"
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

=head3 sub remove_operation

    Removes a matching operation

    Method for endpoint: /operations/v0/remove

    Authentication: true

    Expects params:
        - operation :HASH
            - _id :string

    Reponses:
        - 200 OK
            :HASH
        - 400 Bad Request
        - 401 Unauthorized
        - 403 Forbidden
        - 404 Not Found
        - 409 Conflict
        - 500 Internal Server Error
=cut
