/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Identifies the source for the [CAudioPlayer] data playback.
enum CAudioSource {
  /// A bundled asset with your application
  asset,

  /// A file on the file system probably chosen via file picker
  file,

  /// A internet resource to download and play
  url,
}

/// Identifies the state of the [CAudioPlayer] object.
enum CAudioState {
  /// Currently in a playback mode.
  playing,

  /// Audio has been paused.
  paused,

  /// Audio has been stopped and will reset with playing.
  stopped,
}

/// Provides the ability to play audio files or perform text to speech within
/// your application.
class CAudioPlayer {
  // Member Fields:
  late CAudioState _state;
  late dynamic _data;
  late dynamic _player;

  CAudioPlayer(dynamic player, dynamic data) {
    _state = CAudioState.stopped;
    _data = data;
    _player = player;
  }

  /// Identifies the current state of the audio player.
  CAudioState get state => _state;

  /// Plays or resumes a paused audio source.
  Future<void> play() async {
    if (_state == CAudioState.playing) {
      return;
    }

    if (_player is FlutterTts) {
      await (_player as FlutterTts).speak(_data);
    } else {
      if (_state == CAudioState.paused) {
        await (_player as AudioPlayer).resume();
      } else {
        await (_player as AudioPlayer).play(_data);
      }
    }
    _state = CAudioState.playing;
  }

  /// Pauses a currently playing audio source.
  Future<void> pause() async {
    if (_state != CAudioState.playing) {
      return;
    }

    if (_player is FlutterTts) {
      await (_player as FlutterTts).pause();
    } else {
      await (_player as AudioPlayer).pause();
    }
    _state = CAudioState.paused;
  }

  /// Stops the playing audio source.
  Future<void> stop() async {
    if (_state == CAudioState.stopped) {
      return;
    }

    if (_player is FlutterTts) {
      await (_player as FlutterTts).stop();
    } else {
      await (_player as AudioPlayer).stop();
    }
    _state = CAudioState.stopped;
  }
}
