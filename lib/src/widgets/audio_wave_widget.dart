import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

class AudioWaveWidget extends StatefulWidget {
  const AudioWaveWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWaveWidget> {
  final controller = SiriWaveController(
    amplitude: 0.5,
    frequency: 10,
    speed: 0.1
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: SiriWave(
            controller: controller,
            style: SiriWaveStyle.ios_9,
            options: const SiriWaveOptions(
              height: 80,
              // width: 200
            ),
          ),
        ),
      ],
    );
  }
}
