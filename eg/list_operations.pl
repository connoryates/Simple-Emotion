#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $emotion = Simple::Emotion->new(
    scope    => 'operations',
    pre_auth => 1,
);

#print Dumper $emotion->get_operation({
#    operation => {
#        _id => '58dad1d4befddf2164a02ed6',
#    },
#});

print Dumper $emotion->list_operations({
    operation => {
        owner => [
            {
                _id  => '58d1a6881499067d763486d4',
                type => 'user',
            }
        ],
#        type => 'transload-audio',
    },
});

exit(0);
