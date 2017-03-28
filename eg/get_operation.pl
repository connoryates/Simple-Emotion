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

my $op = $emotion->get_operation({
    operation => {
        _id => '58daac8ad307531fa9eea754'
    }
});

print Dumper $op;

1;
