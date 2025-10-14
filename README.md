# godot-pd

GDExtension that allows you to interact with and run [Pure Data](https://puredata.info/) patches in Godot.

Currently uses Pd vanilla version [**0.56-1**](https://puredata.info/downloads/pure-data/releases/0.54-1).

Latest tested Godot version: **4.5 stable**.

## Installation

Download the latest release from the [release page](https://github.com/fediazc/godot-pd/releases), then copy the `addons/` folder to your Godot project's root folder.

You can also [build from source](#building-from-source).

## Overview

To begin using the extension, assign an `AudioStreamPD` resource to an `AudioStreamPlayer`'s `stream` property in the inspector. For more details, please see the in-editor documentation for both `AudioStreamPlaybackPD` and `AudioStreamPD`.

Here's some sample code:

```GDScript
@onready var player: AudioStreamPlayer = $AudioStreamPlayer

var pd: AudioStreamPlaybackPD

func _ready():
    # setup
    player.play()
    pd = player.get_stream_playback()
    
    # playing patches
    pd.open_patch("example.pd")

    # sending messages
    pd.send_bang("start-loop")
    pd.send_float("set-pitch", 440)

    # receiving messages
    pd.subscribe("my-tag")

    pd.receive_bang.connect(_on_receive_bang)
    pd.receive_float.connect(_on_receive_float)

func _on_receive_bang(dest: String):
    # do something...

func _on_receive_float(dest: String, num: float):
    # do something with num...

```

## Issues and Limitations

- Sometimes, trying to open an **invalid or missing** patch file with `AudioStreamPlaybackPD.open_patch()` will cause a crash. This is _probably_ related to [libpd issue #372](https://github.com/libpd/libpd/issues/372), although I have not been able to reproduce this consistently.
- It's not possible to access patch files directly from `res://` with this extension. You will need to access them using regular file system paths. As a result, when exporting you will need to manually move patch files into your export folder as it will not be possible to access them from the exported PCK.

## Building from source

```sh
# on macOS
./dev.macos.sh
```
