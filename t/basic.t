use strict;
use Test::More;

use_ok 'Simple::Emotion';

my $emotion = Simple::Emotion->new;

isa_ok $emotion, 'Simple::Emotion';

subtest 'Checking can methods and attributes' => sub {
    my @methods = qw(make_request analyze detect_events);
    my @attr    = qw(audio_id org_id user_id uri url params request_type base http_request user_agent);

    can_ok $emotion, @methods;
    can_ok $emotion, @attr;
};

subtest 'Testing attributes' => sub {
    isa_ok $emotion->user_agent, 'Furl', 'Got Furl object back from user_agent attribute';
    isa_ok $emotion->base, 'URI', 'Got URI object back from base_uri attribute';
    is     $emotion->base->as_string, 'api.simpleemotion.com', 'Got correct base URI back as string';
    is     $emotion->scheme, 'https://', 'Got correct scheme';
    is     $emotion->uri, 'https://api.simpleemotion.com/', 'Got correct base URI back from uri';
    is     $emotion->url, 'https://api.simpleemotion.com/', 'Got correct base URL back from url';


    $emotion->request_type('GET');
    is $emotion->request_type, 'GET', 'Got normalized REST method for GET';

    $emotion->request_type('get');
    is $emotion->request_type, 'GET', 'Got normalized REST method for get';


    $emotion->request_type('POST');
    is $emotion->request_type, 'POST', 'Got normalized REST method for POST';

    $emotion->request_type('post');
    is $emotion->request_type, 'POST', 'Got normalized REST method for post';


    $emotion->request_type('PUT');
    is $emotion->request_type, 'PUT', 'Got normalized REST method for PUT';

    $emotion->request_type('put');
    is $emotion->request_type, 'PUT', 'Got normalized REST method for put';


    $emotion->request_type('PATCH');
    is $emotion->request_type, 'PATCH', 'Got normalized REST method for PATCH';

    $emotion->request_type('patch');
    is $emotion->request_type, 'PATCH', 'Got normalized REST method for patch';


    $emotion->request_type('HEAD');
    is $emotion->request_type, 'HEAD', 'Got normalized REST method for HEAD';

    $emotion->request_type('head');
    is $emotion->request_type, 'HEAD', 'Got normalized REST method for head';
};

subtest 'Testing methods' => sub {
#    my $e = Simple::Emotion->new( audio_id => 4082085897 );
#    $e->analyze;
#    $e->detect_events;

#    $e = Simple::Emotion->new( org_id => 5990830985 );
#    $e->org_list;
#    $e->org_info;
#    $e->org_rename;
#    $e->org_user_list;

#    $e->user_id(1234456693);
#    $e->add_org_user;

};

done_testing();
