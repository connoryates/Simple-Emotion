requires 'perl', '5.008005';

requires 'Moo', 0;
requires 'HTTP::Request', 0;
requires 'Furl', 0;
requires 'Try::Tiny', 0;
requires 'URI', 0;
requires 'Carp', 0;
requires 'URI', 0;

on test => sub {
    requires 'Test::More', '0.96';
};
