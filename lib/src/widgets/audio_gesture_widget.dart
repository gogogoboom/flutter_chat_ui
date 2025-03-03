import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../../flutter_chat_ui.dart';
import 'sound_recorder.dart';

// const theSource = AudioSource.microphone;

class AudioGestureWidget extends StatefulWidget {
  final Function(bool, bool)? onAudioHanding;
  final Function(File, int sec)? onAudioCompleted;
  final FlutterSoundRecorder recorder;

  const AudioGestureWidget(
      {Key? key,
      this.onAudioHanding,
      required this.recorder,
      required this.onAudioCompleted})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AudioGestureState();
}

class AudioGestureState extends State<AudioGestureWidget> {
  String buttonText = '按住 说话';
  Offset? position;
  Duration? mDuration;
  late SoundRecorder _mRecorder;
  bool isOverflow = false;

  @override
  void initState() {
    _mRecorder = SoundRecorder(widget.recorder, (Duration duration) {
      mDuration = duration;
    });
    _mRecorder.init();
    super.initState();
  }

  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _mRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (LongPressDownDetails details) {
        setState(() {
          buttonText = '松开 发送';
        });
        isOverflow = false;
        position = details.globalPosition;
        widget.onAudioHanding?.call(true, isOverflow);
        _mRecorder.toggleRecorder();
        // widget.recorder.onProgress?.listen((event) {
        //   mDuration = event.duration;
        //   print('录音时长：$event,${event.duration}');
        // });
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if ((position?.dy ?? 0) - details.globalPosition.dy > 100) {
          isOverflow = true;
          setState(() {
            buttonText = '松开 取消';
          });
        } else {
          isOverflow = false;
          setState(() {
            buttonText = '松开 发送';
          });
        }
        widget.onAudioHanding?.call(true, isOverflow);
      },
      onLongPressUp: () {
        print('onLongPressUp');
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false, isOverflow);
        _mRecorder.toggleRecorder();
        String? filePath = _mRecorder.outFilePath;
        if (!isOverflow && (filePath?.isNotEmpty ?? false)) {
          widget.onAudioCompleted
              ?.call(File(filePath!), mDuration?.inSeconds ?? 0);
        } else {
          print('取消发送');
        }
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false, isOverflow);
        _mRecorder.cancelRecorder();
        print('onTapUp');
      },
      onLongPressCancel: () {
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false, isOverflow);
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: TextStyle(
            color: InheritedChatTheme.of(context).theme.inputTextColor,
          ),
        ),
      ),
    );
  }
}

abstract class AudioGestureCallback {
  void onSend();

  void onCancel();

  void onShortCancel();
}
