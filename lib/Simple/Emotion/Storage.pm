## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Methods for audio storage

package Simple::Emotion::Storage;
use Moo::Role;
with 'Simple::Emotion::Storage::Audio',
     'Simple::Emotion::Storage::Folder',
     'Simple::Emotion::Storage::Analysis';

use Simple::Emotion::Constants;

has add_endpoint    => ( is => 'rw', default => sub { '/add'    } );
has get_endpoint    => ( is => 'rw', default => sub { '/get'    } );
has list_endpoint   => ( is => 'rw', default => sub { '/list'   } );
has move_endpoint   => ( is => 'rw', default => sub { '/move'   } );
has exists_endpoint => ( is => 'rw', default => sub { '/exists' } );
has remove_endpoint => ( is => 'rw', default => sub { '/remove' } );

# TODO
# sub BUILD { shift->scope(STORAGE_SCOPE) }

1;

__END__
