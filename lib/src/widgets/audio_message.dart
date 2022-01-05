import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/audio_controller.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

class AudioMessage extends StatefulWidget {
  const AudioMessage({
    Key? key,
    required this.message,
    required this.showName,
    required this.audioController,
    required this.currentUserIsAuthor,
  }) : super(key: key);

  final types.FileMessage message;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  final AudioController audioController;

  final bool currentUserIsAuthor;

  @override
  State<StatefulWidget> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  late Function(String?, PlayerState) callback;

  Widget _audioWidgetBuilder(
    types.User user,
    BuildContext context,
  ) {
    final theme = InheritedChatTheme.of(context).theme;
    final color = getUserAvatarNameColor(
        widget.message.author, theme.userAvatarNameColors);
    final name = getUserName(widget.message.author);
    num seconds = max(1, widget.message.size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showName)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.userNameTextStyle.copyWith(color: color),
            ),
          ),
        Row(
          children: [
            SelectableText(
              '$seconds\'\'',
              style: user.id == widget.message.author.id
                  ? theme.sentMessageBodyTextStyle
                  : theme.receivedMessageBodyTextStyle,
              textWidthBasis: TextWidthBasis.longestLine,
            ),
            const Spacer(),
            Visibility(
                visible: _showWave(),
                child: SpinKitWave(
                  color: widget.currentUserIsAuthor
                      ? Colors.white
                      : InheritedChatTheme.of(context).theme.primaryColor,
                  size: 10,
                  itemCount: 3,
                  type: SpinKitWaveType.center,
                ))
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    callback = (uri, playState) {
      if (mounted) {
        setState(() {});
      }
    };
    widget.audioController.addAudioListener(widget.message.uri, callback);
    super.initState();
  }

  @override
  void dispose() {
    widget.audioController.removeListener(callback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = InheritedChatTheme.of(context).theme;
    final _user = InheritedUser.of(context).user;
    num seconds = widget.message.size;
    return Container(
      width: 40 + seconds * 8,
      margin: EdgeInsets.symmetric(
        horizontal: _theme.messageInsetsHorizontal,
        vertical: _theme.messageInsetsVertical,
      ),
      child: _audioWidgetBuilder(_user, context),
    );
  }

  bool _showWave() {
    return widget.audioController.isPlaying(widget.message.uri);
  }
}
