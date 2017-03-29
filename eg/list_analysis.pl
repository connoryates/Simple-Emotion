#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Simple::Emotion;

my $id = $ARGV[0];

die "Missing ID" unless $id;

my $emotion = Simple::Emotion->new(
    scope    => 'storage',
    pre_auth => 1,
);

print Dumper $emotion->audio_to_text($id);

#my $resp = $emotion->list_analysis({
#    analysis  => {
#        audio => {
#            _id => $id,
#        }
#    },
#});

#my $analyses = $resp->{analyses};

#my @words = ();
#foreach my $analysis (@$analyses) {
#    my $data = $analysis->{data};
#    foreach my $t (@{ $data->{turns} }) {
#        push @words, map { $_->{word} } @{ $t->{words} };
#    }
#}

#print join " ", @words;
#print "\n";

exit(0);

# 58dc1eec81ab1a31e57ac860
# Long voicemail: 58dc384e81ab1a31e57ac88d
