# NAME

Simple::Emotion - Client for api.simpleemotion.com.

# SYNOPSIS

```perl
    use Simple::Emotion;

    my $emotion = Simple::Emotion->new(
        client_id     => $CLIENT_ID,
        client_secret => $CLIENT_SECRET,
    );

    $emotion->authorize;
    $emotion->scope('transcription');

    $emotion->add_folder({
        folder => {
            basename => 'my_voicemail_folder',
        },
        destination => {
            folder  => {
                owner => {
                    _id  => $OWNER_ID,
                    type => 'user',
                },
            },
            service => 'voicemail_transcription',
            name => 'voicemail',
        },
    });

    # Create an audio folder to hold your recording
    $emotion->add_audio({
        folder => {
            basename => 'voicemail_1.mp3',
        },
        destination => {
            folder  => {
                _id => $emotion->folder_id,
            }
        },
    });

    # Upload your recording directly from its url
    $emotion->upload_from_url({
        audio => {
            _id => $emotion->audio_id,
        },
        url => 'https://your-download-link',
        operation => {
            tags  => [qw(voicemail_upload)],
            callbacks => {
                completed  => {
                    url    => 'https://your-apps-webhook',
                    secret => 'SUPER DUPER',
                },
            },
        },
    });

    # Wait for webhook in your API...
    my $params = params;

    my $secret = $params->{headers}->{'X-SE-Signature'};

    my $op = $emotion->get_operation({
        operation => {
            _id => $params->{operation}->{_id},
        },
    });

    $emotion->transcribe({
        audio => {
            _id => $op->{audio}->{_id},
        },
        operation => {
            tags  => [qw(voicemail_transcription)],
            callbacks => {
                completed  => {
                    url    => 'https://your-apps-webhook',
                    secret => 'SUPER DUPER',
                },
            },
        },
    });

    # Wait for webhook in your API...
    my $params = params;

    my $secret = $params->{headers}->{'X-SE-Signature'};

    my $op = $emotion->get_operation({
        operation => {
            _id => $params->{operation}->{_id},
        },
    });
    
    my $audio_id = $op->{audio}->{_id};
    
    # Convert analyses to text
    my $transcription = $emotion->audio_to_text($audio_id);

    # Get full analysis read out:
    my $analyses = $emotion->list_analysis({
        audio => {
            _id => $audio_id,
        },
    });
```

# DESCRIPTION

Simple::Emotion is wrapper around api.simpleemotion.com - an API capable of detecting emotions from audio recordings.

[Official API documentation here.](https://api.simpleemotion.com/docs/storage/v0.html)

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
transcription => [qw(
    storage.audio.uploadFromUrl
    operations.get
    speech.transcribe
    storage.analysis.get
    storage.audio.add
)];
```

## pre_auth

Automatically get an ```access_token``` before you make your first request.

If you set:

```perl
my $emotion = Simple::Emotion->new(
    client_id     => $CLIENT_ID,
    client_secret => $CLIENT_SECRET,
    pre_auth      => 1,
);
```

There is no need to call:

```perl
$emotion->authorize;
```

## audio_id

You can construct a ```Simple::Emotion``` object with an ```audio_id```, set it later, or pass it as an arg to a method. 
In all cases, ```audio_id``` ends up as an attribute within ```Simple::Emotion```:

```perl
my $e = Simple::Emotion->new(
    client_id      => $CLIENT_ID,
    client_secrent => $CLIENT_SECRET,
    scope          => 'transcription',
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
