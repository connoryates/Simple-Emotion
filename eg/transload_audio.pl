#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $url = $ARGV[0];

die "Missing URL" unless $url;

my $num = int(rand(100));

my $emotion = Simple::Emotion->new(
    pre_auth  => 1,
    scope     => 'transcription',
    folder_id => '58d95ccfaeb1a506c3530a12',
    basename  => 'voicemail_test_' . $num . '.mp3',
    callback_url => 'http://dyl1-cy.getdyl.com/api/simple_emotion',
    callback_secret => 'secret',
);

$emotion->transload_audio($url);

exit(0);
