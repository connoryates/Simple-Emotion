#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $emotion = Simple::Emotion->new(
    scope    => 'transcription',
    pre_auth => 1,
);

print Dumper $emotion->list_analysis({
    analysis  => {
        audio => {
            _id => '58d9766979ee990686fe7e3e',
        },
    },
});

exit(0);
