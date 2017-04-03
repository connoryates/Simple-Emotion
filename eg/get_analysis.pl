#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $id = $ARGV[0];

die "No ID specified" unless $id;

my $emotion = Simple::Emotion->new(
    scope    => 'transcription',
    pre_auth => 1,
);

print Dumper $emotion->list_analysis({
    analysis  => {
        audio => {
            _id => $id,
        },
    },
});

exit(0);
