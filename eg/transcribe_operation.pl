#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $id = $ARGV[0];

die "Missing ID" unless $id;

my $emotion = Simple::Emotion->new(
    pre_auth => 1,
    scope    => 'transcription',
    callback_url    => 'http://dyl1-cy.getdyl.com/api/simple_emotion',
    callback_secret => 'super',    
);

print Dumper $emotion->transcribe_operation($id);

exit(0);
