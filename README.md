# NAME

Simple::Emotion - Client for api.simpleemotion.com.

# SYNOPSIS

With pre-authorization:

```perl
use Simple::Emotion;

my $e = Simple::Emotion->new(
    client_id     => $CLIENT_ID,
    client_secret => $CLIENT_SECRET,
    scope         => 'transcribe',
    pre_auth      => 1
);

my $resp = $e->upload_from_url('http://url-with-audio-file');
my $id   = $resp->id;

$e->audio_id($id);

my $analysis = $e->analyze;

# -- OR --

my $analysis = $e->analyze({ audio_id => $id });
```

Without pre-authorization:

```perl
 my $e = Simple::Emotion->new(
    client_id     => $CLIENT_ID,
    client_secret => $CLIENT_SECRET,
    scope         => 'transcribe',
);

$e->authorize;
    
```

You can also set your ```client_id``` and ```client_secret``` in your ```$ENV``` as:

```SIMPLE_EMOTION_CLIENT_ID```

and

```SIMPLE_EMOTION_CLIENT_SECRET```

or, if you already have an access token, you can set:

```SIMPLE_EMOTION_ACCESS_TOKEN```

# DESCRIPTION

Simple::Emotion is wrapper around api.simpleemotion.com - an API capable of detecting emotions from audio recordings.

[Official documentation here.](https://api.simpleemotion.com/docs/storage/v0.html)

### Note:

This API is in v0, so breaking changes will occur

# Constructor

## client_id

Your ```client_id```

## client_secret

Your ```client_secret```

## scope

The scope of your workflow, as provided by the API specs. You can also use some handy aliases for common workflows:

```perl
transcribe => [
    storage.audio.uploadFromUrl
    operations.get
    speech.transcribe
    storage.analysis.get
    storage.audio.add
]
```

## pre_auth

Automatically get an ```access_token``` before you make your first request.

## audio_id

You can construct a ```Simple::Emotion``` object with an ```audio_id```, set it later, or pass it as an arg to a method. 
In all cases, ```audio_id``` ends up as an attribute within ```Simple::Emotion```:

```perl
my $e = Simple::Emotion->new(
    client_id      => $CLIENT_ID,
    client_secrent => $CLIENT_SECRET,
    scope          => 'transcribe',
    pre_auth       => 1,
    audio_id       => 12345678
);

say $e->audio_id;    # 12345678

$e->audio_id(87654321);
$e->analyze;
say $e->audio_id;    # 87654321

$e->analyze({ audio_id => 11111111 });
say $e->audio_id;   # 11111111

```

## org_id

Specify your organization id. Same usage as ```audio_id```

## user_id

Specify a user id. Same usage as ```audio_id```

# AUTHOR

Connor Yates <connor.t.yates@gmail.com>

# COPYRIGHT

Copyright 2017- Connor Yates

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
