use strict;
use warnings;

use Test::More;

use_ok 'Simple::Emotion';

my $emotion = Simple::Emotion->new;

isa_ok $emotion, 'Simple::Emotion';

done_testing();
