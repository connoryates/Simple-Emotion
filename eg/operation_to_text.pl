#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $id = $ARGV[0];

die "Missing ID" unless $id;

my $emotion = Simple::Emotion->new(
    pre_auth => 1,
    scope    => 'transcription',
);

print Dumper $emotion->operation_to_text($id);

exit(0);
