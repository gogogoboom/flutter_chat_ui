
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AudioGestureWidget extends StatefulWidget {
  final Function(bool)? onAudioHanding;
  const AudioGestureWidget({Key? key, this.onAudioHanding}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AudioGestureState();
}

class AudioGestureState extends State<AudioGestureWidget> {

  String buttonText = '按住 说话';
  Offset? position;
  Duration? duration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (LongPressDownDetails details) {
        setState(() {
          buttonText = '松开 发送';
        });
        position = details.globalPosition;
        widget.onAudioHanding?.call(true);
        print('onLongPressDown ==> ${details.globalPosition}');
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if((position?.dy ?? 0) - details.globalPosition.dy > 50) {
          setState(() {
            buttonText = '松开 取消';
          });
        } else {
          setState(() {
            buttonText = '松开 发送';
          });
        }
        print('onLongPressMoveUpdate ==> ${details.globalPosition}');
      },
      onSecondaryLongPressMoveUpdate: (LongPressMoveUpdateDetails details){
        print('onSecondaryLongPressMoveUpdate ==> ${details.globalPosition}');
      },
      onTertiaryLongPressMoveUpdate: (LongPressMoveUpdateDetails details){
        print('onTertiaryLongPressMoveUpdate ==> ${details.globalPosition}');
      },
      onLongPressUp: () {
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false);
        print('onLongPressUp');
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false);
        print('onTapUp');
      },
      onLongPressCancel: () {
        setState(() {
          buttonText = '按住 说话';
        });
        widget.onAudioHanding?.call(false);
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(buttonText, style: TextStyle(color: Colors.white),),
      ),
    );
  }

}

abstract class AudioGestureCallback {

  void onSend();

  void onCancel();

  void onShortCancel();
}