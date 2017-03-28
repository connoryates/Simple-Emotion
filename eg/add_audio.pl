#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $url = $ARGV[0];

my $emotion = Simple::Emotion->new(
    scope    => 'transcription',
    pre_auth => 1,
);

$emotion->add_audio({
    audio => {
        basename => 'test_voicemail.mp3',
    },
    destination => {
        folder  => {
            _id => '58d95ccfaeb1a506c3530a12',
        },
    },
});

my $id = $emotion->id;

print Dumper $emotion->get_audio({
    audio => {
        _id => $id,
    },
});

$emotion->upload_from_url({
    url   => $url,
    audio => {
        _id => $id,
    },
});

$emotion->transcribe({
    audio => {
        _id => $id,
    },
    diarized => 0,
});

#$emotion->detect({
#    audio => {
#        _id => $id,
#    },
#});

exit(0);
