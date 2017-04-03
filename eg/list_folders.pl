#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $emotion = Simple::Emotion->new(
    pre_auth => 1,
    scope    => 'storage',
);

print Dumper $emotion->list_folders;

exit(0);
