import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:siri_wave/siri_wave.dart';

class AudioWaveWidget extends StatefulWidget {
  final FlutterSoundRecorder? recorder;
  final bool isOverflow;

  const AudioWaveWidget(
      {Key? key, required this.recorder, required this.isOverflow})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWaveWidget> {
  final _controller = SiriWaveController(speed: 0.1, frequency: 0);
  Duration duration = Duration.zero;
  int initWidth = 150;

  @override
  void initState() {
    widget.recorder?.onProgress?.listen((event) {
      double amplitude = ((event.decibels?.toDouble() ?? 0) / 100) * 2;
      _controller.setAmplitude(min(amplitude, 1));
      if (mounted) {
        setState(() {
          duration = event.duration;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: min(initWidth + duration.inSeconds * 5, 400),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: SiriWave(
              controller: _controller,
              style: SiriWaveStyle.ios_9,
              options: SiriWaveOptions(
                backgroundColor: widget.isOverflow ? Colors.red : Colors.black,
                height: 80,
                // width: 200
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80,
        ),
        Icon(
          CupertinoIcons.clear_circled_solid,
          size: 80,
          color: widget.isOverflow ? Colors.grey : Colors.white,
        ),
        SizedBox(
          height: 200,
        )
      ],
    );
  }
}
