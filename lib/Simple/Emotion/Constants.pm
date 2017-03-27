## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Package for constants and globals

package Simple::Emotion::Constants;
use Moo;

extends 'Exporter';

our @EXPORT = qw(POST GET PUT HEAD PATCH DELETE VOID BASE_URL REST_HTTP SPLAT_REGEXP SPLAT_CAPTURE);

use constant POST   => 'POST';
use constant GET    => 'GET';
use constant PUT    => 'PUT';
use constant HEAD   => 'HEAD';
use constant PATCH  => 'PATCH';
use constant DELETE => 'DELETE';

use constant SPLAT_REGEXP  => qr/\#\{.+\}/;
use constant SPLAT_CAPTURE => qr/\#\{(.+)\}/;
use constant VOID          => '';

use constant BASE_URL  => 'api.simpleemotion.com';
use constant REST_HTTP => qw(GET POST PATCH PUT HEAD);

our $TRANSCRIPTION_FLOW        = 'storage.audio.uploadFromUrl operations.get speech.transcribe storage.analysis.get storage.audio.add';
our $TRANSCRIPTION_FLOW_SIMPLE = 'storage operations speech';

1;

=pod

    Package to contain constants used throughout the roles.

=cut
