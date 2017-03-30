#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $id = $ARGV[0];

die "Missing ID" unless $id;

my $emotion = Simple::Emotion->new(
    scope    => 'transcription',
    pre_auth => 1,
);

my $op = $emotion->get_operation({
    operation => {
        _id => $id
    }
});

print Dumper $op;

1;
