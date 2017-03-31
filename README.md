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

    # Create an audio folder to hold your recordings
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

    # Create an audio file
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

    my $secret = headers->{'X-SE-Signature'};

    my $op = $emotion->get_operation({
        operation => {
            _id => $params->{operation}->{_id},
        },
    });

    # Start a transcription operation on an audio_id
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

    my $secret = headers->{'X-SE-Signature'};

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

Simple::Emotion is wrapper around api.simpleemotion.com - an API capable of transcribing and detecting emotions from audio recordings.

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

# Methods

All API endpoints are represented as snake_cased methods.

For example, the endpoint ```uploadFromUrl``` becomes ```sub upload_from_url```.

## Storage - Folder

### add_folder

Add a new folder to hold an audio file.

Expects a ```HASH``` that must include ```service``` and ```name``` key/value pairs.

### folder_exists 

Check if a folder already exists.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### get_folder

Retrieve a folder object.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### list_folders

List all folder objects.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

## Storage - Audio

### add_audio

Add an audio file to a folder. You must call this method before you can transload an audio url.

```add_audio``` expects different arguments based on your workflow. For example, a one-way voicemail
may want to use the arguments:

```json
    {
      "audio": {
        "basename": "string",
        "metadata": {
          "speakers": [
            {
              "_id": "string",
              "role": "agent"
            }
          ]
        },
        "timestamps": {
          "recorded": "2017-03-31T15:36:32Z"
        }
      },
      "destination": {
        "folder": {
          "_id": "string",
          "owner": {
            "_id": "string",
            "type": "user"
          },
        }
      },
    }
```

Where as a diarized workflow would need to specify more than ```speaker``` .

### audio_exists

Check if an audio file already exists.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### get_audio

Get a specified audio file.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### get_download_url

Gets a URL that can be used to download the raw contents of a matching audio file.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### get_upload_url

Gets a URL that can be used to upload the raw contents of a matching audio file.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### list_audio

List all matching audi objects.

Expects a ```HASH``` that must an include an ```audio``` ```service```, ```name```, or ```owner_id```.

### move_audio

Moves a matching audio file to the specified destination.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```
along with a ```destination``` ```HASH``` that must include a ```folder_id``` OR ```service``` AND ```name```.

### remove_audio

Remove a matching audio file.

Expects a ```HASH``` that must include an ```audio_id``` or ```name``` AND ```service```.

### upload_from_url

Upload an audio file directly from its url.

Expects a ```HASH``` that must include at least a ```url``` key/value and an ```audio_id``` OR ```name``` and ```service```.

NOTE: Ensure that the name you have set for your target audio file has an extension that matches your recording!

## Storage - Analysis

### analysis_exists

Check if an analysis object exists.

Expects a ```HASH``` that must include either an ```analysis_id``` OR ```name``` and ```service```
OR 
an ```audio_id``` or ```name``` AND ```service```.

### get_analysis

Get a specified analysis object.

Expects a ```HASH``` that must include either an ```analysis_id``` OR ```name``` and ```service```
OR 
an ```audio_id``` or ```name``` AND ```service```.

### list_analysis

Lists matching analysis objects.

Expects a ```HASH``` that must include either an ```audio_id``` OR ```name``` and ```service```

### remove_analysis

Removes a matching analysis object.

Expects a ```HASH``` that must include either an ```analysis_id``` OR ```name``` and ```service```
OR 
an ```audio_id``` or ```name``` AND ```service```.

### rename_analysis

Expects a ```HASH``` that must include either an ```analysis_id``` OR ```name``` and ```service```
OR 
an ```audio_id``` or ```name``` AND ```service```.
AND
a rename key: ```name```

## Speech

### transcribe

Transcribes an uploaded audio file.

Expects a ```HASH``` that must include an ```audio_id``` OR ```name``` and ```service```.

### detect

Detects speech in an uploaded audio file.

Expects a ```HASH``` that must include an ```audio_id``` OR ```name``` and ```service```.

## Shortcut methods

Make your workflow a bit simpler with these methods:

## transload_url

Add an audio file and upload a recording url in one method:

```perl
    my $emotion = Simple::Emotion->new(
        client_id       => $CLIENT_ID,
        client_secret   => $CLIENT_SECRET,
        pre_auth        => 1,
        # Or set later or not at all
        callback_url    => 'https://your-apps-webhook',
        callback_secret => $CALLBACK_SECRET,
    );

    # Or construct these
    $emotion->basename('voicemails');
    $emotion->service('voicemail_storage');

    $emotion->transload_url({
        url  => 'https://your-recording-url',
        name => $RECORDING_NAME,
    });
```

## audio_to_text

Once an analysis has finished, you can use this method to get a string
of the transcribed audio back.

```perl
    my $transcription = $emotion->audio_to_text($audio_id);
```

## operation_to_text

The webhook from the Simple Emotion API returns the ```operation_id```
of a completed job. It is up to your app to consume this request. If your
app's webhook would like the transcription text directly from the ```operation_id```,
simply pass the ```operation_id``` to this method, and it will retrieve
the stored transcription.

```perl
    my $transcription = $emotion->operation_to_text($operation_id);
```

## SIMPLE_EMOTION_*

You can export your ```client_id``` and ```client_secret``` or
```access_token``` into your ```$ENV``` if you wish.

```bash
    $ export SIMPLE_EMOTION_CLIENT_ID="your_client_id"
    $ export SIMPLE_EMOTION_CLIENT_SECRET="your_client_secret"
    $ export SIMPLE_EMOTION_ACCESS_TOKEN="your_access_token"
```

The ```client_id``` and ```client_secret``` attributes will default to these,
so there is no need to specify them in during construction.

# AUTHOR

Connor Yates <connor.t.yates@gmail.com>

# COPYRIGHT

Copyright 2017- Connor Yates

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
