#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $emotion = Simple::Emotion->new(
    scope    => 'storage',
    pre_auth => 1,
);

print Dumper $emotion->list_analysis({
    analysis  => {
        audio => {
            _id => '58dad606f0f82d2466394133',
        }
    },
});

exit(0);
