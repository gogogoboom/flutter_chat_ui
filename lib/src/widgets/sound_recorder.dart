import 'dart:io';
import 'dart:math';

import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:permission_handler/permission_handler.dart';

import '../../flutter_chat_ui.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;

  bool get isRecording => _audioRecorder?.isRecording ?? false;
  String? outFilePath;
  final Function(Duration)? onDuration;

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  SoundRecorder(this._audioRecorder, this.onDuration);

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    if (Platform.isAndroid) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('没有录制语音权限');
      }
    }
    await _audioRecorder?.openAudioSession();
    _isRecorderInitialized = true;
    await _audioRecorder
        ?.setSubscriptionDuration(const Duration(milliseconds: 50));
    _audioRecorder?.dispositionStream()?.listen((event) {
      onDuration?.call(event.duration);
    });
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
    outFilePath = outputPath;
    await _audioRecorder?.startRecorder(
        toFile: outFilePath,
        codec: Codec.aacADTS,
        audioSource: AudioSource.microphone);
  }

  Future _stop() async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder?.stopRecorder();
    int size = await File(outFilePath!).length();
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
    if (outFilePath != null) {
      await _audioRecorder?.deleteRecord(fileName: outFilePath!);
    }
  }
}
