import 'dart:io';
import 'dart:math';

import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  bool get isRecording => _audioRecorder?.isRecording ?? false;
  String? outFilePath;

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  SoundRecorder(this._audioRecorder);

  Future init() async {
    // _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException(
          'Microphone permission is not granted');
    }
    await _audioRecorder?.openAudioSession();
    _isRecorderInitialized = true;
  }

  Future dispose() async {
    await _audioRecorder?.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialized = false;
  }

  Future _record() async {
    if (!_isRecorderInitialized) return;
    Directory tempDir = await pathProvider.getTemporaryDirectory();
    String outputPath = '${tempDir.path}/${getRandomString(5)}.aac';
    print('********* start record outputpath : $outputPath');
    outFilePath = outputPath;
    await _audioRecorder?.startRecorder(toFile: outFilePath);
    _audioRecorder?.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  Future _stop() async {
    if (!_isRecorderInitialized) return;
    print('********* stop record ********* ');
    await _audioRecorder?.stopRecorder();
    int size = await File(outFilePath!).length();
    print('********* file size ==> $size ********* ');
    // _audioRecorder = null;
  }

  Future toggleRecorder() async {
    if (_audioRecorder?.isStopped ?? false) {
      await _record();
    } else {
      await _stop();
    }
  }

  Future cancelRecorder() async {
    await _audioRecorder?.stopRecorder();
    if(outFilePath != null) {
      await _audioRecorder?.deleteRecord(fileName: outFilePath!);
    }
  }
}

