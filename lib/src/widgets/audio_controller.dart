
import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart' show Level;

class AudioController {
  
  late FlutterSoundPlayer mPlayer;

  final Map<String, Function(String?, PlayerState)> _listeners = {};
  
  String? playingUri;

  bool _mPlayerIsInited = false;

  final Function(types.FileMessage)? downloadAttachment;

  AudioController(this.downloadAttachment) {
    mPlayer = FlutterSoundPlayer(logLevel: Level.error);
    mPlayer.openAudioSession().then((value) {
      _mPlayerIsInited = true;
    });
  }

  void togglePlayer(types.FileMessage message) {
    if(mPlayer.isPlaying) {
      _stopPlayer();
      if(message.uri != playingUri) {
        _play(message, message.uri);
      }
    } else {
      _play(message, message.uri);
    }
  }

  void _play(types.FileMessage msg, String uri) async {
    print('将要播放的音频 $uri');
    if(!_mPlayerIsInited) {
      return;
    }
    File file = File(uri);
    if(!file.existsSync()) {
      print('音频文件不存在，开始下载');
      downloadAttachment?.call(msg);
      return;
    }
    var uint8list = file.readAsBytesSync();
    await mPlayer.startPlayer(
        fromDataBuffer: uint8list,
        // codec: Codec.aacADTS,
        whenFinished: (){
          shrinkListener();
        }
    );
    playingUri = uri;
    mPlayer.dispositionStream()?.listen((event) {
      shrinkListener();
    });
    mPlayer.setSubscriptionDuration(const Duration(milliseconds: 50));
    shrinkListener();
  }

  void shrinkListener() {
    _listeners.forEach((key, value) {
      // print('$key ==> $value');
      value.call(playingUri, mPlayer.playerState);
    });
  }

  Future<void> _stopPlayer() async {
    await mPlayer.stopPlayer();
    shrinkListener();
  }

  void addAudioListener(String uri, Function(String?, PlayerState) l) {
    _listeners[uri] = l;
  }

  void removeListener(Function(String?, PlayerState) l) {
    _listeners.remove(l);
  }

  bool isPlaying(String uri) => mPlayer.isPlaying && playingUri == uri;

  void dispose() {
    mPlayer.stopPlayer();
    mPlayer.closeAudioSession();
  }
}