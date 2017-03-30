#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $url = $ARGV[0];

die "Missing URL" unless $url;

my $emotion = Simple::Emotion->new(
    scope    => 'storage operations speech',
    pre_auth => 1,
);

$emotion->add_audio({
    audio => {
        basename => 'test_diarized_metadata_8.wav',
        metadata => {
            speakers => [
                {
                    _id  => "5",
                    role => 'agent',
                },
                {
                    _id  => "6",
                    role => 'customer',
                },
            ],
        },
    },
    destination => {
        folder => {
            _id => '58d95ccfaeb1a506c3530a12',
        }
    }
});

my $id = $emotion->id;

$emotion->upload_from_url({
    url => $url,
    audio => {
        _id => $id,
    },
    operation => {
        tags      => [qw|diarized_test|],
        callbacks => {
            completed => {
                url    => 'http://dyl1-cy.getdyl.com/api/simple_emotion',
                secret => 'a1bded0ed0822ffbef81063609bff232cc120194',
            },
        },
    }
});

exit(0);
