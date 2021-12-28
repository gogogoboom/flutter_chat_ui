
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AudioController {
  
  late FlutterSoundPlayer mPlayer;

  final Map<String, Function(String?, PlayerState)> _listeners = {};
  
  String? playingUri;

  bool _mPlayerIsInited = false;

  AudioController() {
    mPlayer = FlutterSoundPlayer();
    mPlayer.openAudioSession().then((value) {
      _mPlayerIsInited = true;
    });
  }

  void togglePlayer(types.FileMessage message) {
    if(mPlayer.isPlaying) {
      _stopPlayer();
      if(message.uri != playingUri) {
        _play(message.uri);
      }
    } else {
      _play(message.uri);
    }
  }

  void _play(String uri) async {
    if(!_mPlayerIsInited) {
      return;
    }
    await mPlayer.startPlayer(
        fromURI: uri,
        codec: Codec.mp3,
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
}