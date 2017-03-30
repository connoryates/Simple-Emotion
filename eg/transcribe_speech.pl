#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;
use Simple::Emotion::Constants;

my $id = $ARGV[0];

die "Missing ID" unless $id;

my $emotion = Simple::Emotion->new(
    scope    => 'transcription',
    pre_auth => 1,
);

my $trans = $emotion->transcribe({
    audio => {
        _id => $id
    },
    diarized  => true,
    operation => {
        callbacks => {
            completed  => {
                url    => 'http://dyl1-cy.getdyl.com/api/simple_emotion',
                secret => 'SUPER SECRET',
            },
        }
    },
});

print Dumper $trans;

exit(0);
