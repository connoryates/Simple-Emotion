## Author: Connor Yates
## vim: ts=8:sw=4:expandtab:shiftround
## Abstract: Package for constants and globals

package Simple::Emotion::Constants;
use Moo;

use Types::Serialiser;

extends 'Exporter';

our @EXPORT = qw(
    POST GET PUT HEAD PATCH DELETE VOID BASE_URL REST_HTTP true false
    ANALYSIS_MAJOR ANALYSIS_MINOR ANALYSIS_PATCH ANALYSIS_REVISION
);

use constant POST   => 'POST';
use constant GET    => 'GET';
use constant PUT    => 'PUT';
use constant HEAD   => 'HEAD';
use constant PATCH  => 'PATCH';
use constant DELETE => 'DELETE';

use constant VOID => '';

use constant BASE_URL  => 'api.simpleemotion.com';
use constant REST_HTTP => qw(GET POST PATCH PUT HEAD);

use constant ANALYSIS_MAJOR    => 0;
use constant ANALYSIS_MINOR    => 0;
use constant ANALYSIS_PATCH    => 0;
use constant ANALYSIS_REVISION => 0;

our $TRANSCRIPTION_FLOW        = 'storage.audio.uploadFromUrl operations.get speech.transcribe storage.analysis.get storage.audio.add';
our $TRANSCRIPTION_FLOW_SIMPLE = 'storage operations speech';

use constant true  => $Types::Serialiser::true;
use constant false => $Types::Serialiser::false;

1;

=pod

    Package to contain constants used throughout the roles.

=cut
