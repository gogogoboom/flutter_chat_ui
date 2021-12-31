import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_sound/flutter_sound.dart';

import '../models/send_button_visibility_mode.dart';
import 'attachment_button.dart';
import 'audio_gesture_widget.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'more_button.dart';
import 'send_button.dart';

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input({
    Key? key,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onSendPressed,
    this.onTextChanged,
    this.onAudioHanding,
    this.onTextFieldTap,
    required this.sendButtonVisibilityMode,
    required this.recorder,
    required this.onAudioCompleted,
    required this.attachments,
  }) : super(key: key);

  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  final void Function(bool, bool)? onAudioHanding;

  /// Will be called on [TextField] tap
  final void Function()? onTextFieldTap;

  final void Function(File, int sec)? onAudioCompleted;

  final FlutterSoundRecorder recorder;

  final List<ChatAttachment>? attachments;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  @override
  _InputState createState() => _InputState();
}

/// [Input] widget state
class _InputState extends State<Input> {
  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = false;
  final _textController = TextEditingController();
  AreaType areaType = AreaType.none;
  double keyboardHeight = 250;

  @override
  void initState() {
    super.initState();

    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        areaType = AreaType.input;
      }
    });
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  Widget _leftWidget() {
    return IconButton(
        onPressed: () {
          _doAreaTypeChange(AreaType.audio);
        },
        icon: Icon(
          areaType != AreaType.audio
              ? Icons.keyboard_voice_outlined
              : Icons.keyboard,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);

    return GestureDetector(
      // onTap: () => _inputFocusNode.requestFocus(),
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): const SendMessageIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
              const NewLineIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.shift):
              const NewLineIntent(),
        },
        child: Actions(
          actions: {
            SendMessageIntent: CallbackAction<SendMessageIntent>(
              onInvoke: (SendMessageIntent intent) => _handleSendPressed(),
            ),
            NewLineIntent: CallbackAction<NewLineIntent>(
              onInvoke: (NewLineIntent intent) {
                final _newValue = '${_textController.text}\r\n';
                _textController.value = TextEditingValue(
                  text: _newValue,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: _newValue.length),
                  ),
                );
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Padding(
              padding: InheritedChatTheme.of(context).theme.inputPadding,
              child: Material(
                borderRadius:
                    InheritedChatTheme.of(context).theme.inputBorderRadius,
                color:
                    InheritedChatTheme.of(context).theme.inputBackgroundColor,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    24 + _query.padding.left,
                    20,
                    24 + _query.padding.right,
                    20 + _query.viewInsets.bottom + _query.padding.bottom,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _leftWidget(),
                          Expanded(
                            child: areaType == AreaType.audio
                                ? AudioGestureWidget(
                                    onAudioHanding: widget.onAudioHanding,
                                    recorder: widget.recorder,
                                    onAudioCompleted: widget.onAudioCompleted,
                                  )
                                : TextField(
                                    controller: _textController,
                                    cursorColor: InheritedChatTheme.of(context)
                                        .theme
                                        .inputTextCursorColor,
                                    decoration: InheritedChatTheme.of(context)
                                        .theme
                                        .inputTextDecoration
                                        .copyWith(
                                          hintStyle:
                                              InheritedChatTheme.of(context)
                                                  .theme
                                                  .inputTextStyle
                                                  .copyWith(
                                                    color:
                                                        InheritedChatTheme.of(
                                                                context)
                                                            .theme
                                                            .inputTextColor
                                                            .withOpacity(0.5),
                                                  ),
                                          hintText: InheritedL10n.of(context)
                                              .l10n
                                              .inputPlaceholder,
                                        ),
                                    focusNode: _inputFocusNode,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: widget.onTextChanged,
                                    onTap: widget.onTextFieldTap,
                                    style: InheritedChatTheme.of(context)
                                        .theme
                                        .inputTextStyle
                                        .copyWith(
                                          color: InheritedChatTheme.of(context)
                                              .theme
                                              .inputTextColor,
                                        ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                          ),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _doAreaTypeChange(AreaType.emoji);
                              },
                              icon: Icon(
                                areaType != AreaType.emoji
                                    ? Icons.emoji_emotions_outlined
                                    : Icons.keyboard,
                                color: Colors.white,
                              )),
                          Visibility(
                            visible: !_sendButtonVisible,
                            child: MoreButton(
                              onPressed: () {
                                _doAreaTypeChange(AreaType.attachment);
                              },
                            ),
                          ),
                          Visibility(
                            visible: _sendButtonVisible,
                            child: SendButton(
                              onPressed: _handleSendPressed,
                            ),
                          ),
                        ],
                      ),
                      // KeyboardAware(
                      //   builder: (context, keyboardConfig) {
                      //     keyboardHeight = max(
                      //         keyboardHeight, keyboardConfig.keyboardHeight);
                      //     return Container();
                      //   },
                      // ),
                      Offstage(
                        offstage: areaType != AreaType.emoji,
                        child: SizedBox(
                          height: keyboardHeight,
                          child: EmojiPicker(
                              onEmojiSelected:
                                  (Category category, Emoji emoji) {
                                _onEmojiSelected(emoji);
                              },
                              // onBackspacePressed: _onBackspacePressed,
                              config: Config(
                                  columns: 7,
                                  // Issue: https://github.com/flutter/flutter/issues/28894
                                  emojiSizeMax:
                                      32 * (Platform.isIOS ? 1.30 : 1.0),
                                  verticalSpacing: 0,
                                  horizontalSpacing: 0,
                                  initCategory: Category.RECENT,
                                  bgColor: Colors.transparent,
                                  indicatorColor: Colors.blue,
                                  iconColor: Colors.grey,
                                  iconColorSelected: Colors.blue,
                                  progressIndicatorColor: Colors.blue,
                                  backspaceColor: Colors.blue,
                                  showRecentsTab: true,
                                  recentsLimit: 28,
                                  noRecentsText: 'No Recents',
                                  noRecentsStyle: const TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  tabIndicatorAnimDuration: kTabScrollDuration,
                                  categoryIcons: const CategoryIcons(),
                                  buttonMode: ButtonMode.CUPERTINO)),
                        ),
                      ),
                      Offstage(
                        offstage: areaType != AreaType.attachment,
                        child: SizedBox(
                          height: keyboardHeight,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, mainAxisSpacing: 10),
                            itemCount: widget.attachments?.length ?? 0,
                            itemBuilder: _attachmentItem,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///1、与之前的相同。表情、附件和语音重复点击后弹出键盘，输入框获取焦点
  ///2、
  void _doAreaTypeChange(AreaType next) {
    if (next == areaType) {
      _inputFocusNode.requestFocus();
      areaType = AreaType.input;
      print('areaType相同==> $areaType');
    } else {
      switch (areaType) {
        case AreaType.none:
          break;
        case AreaType.input:
          // _inputFocusNode.unfocus();
          FocusScope.of(context).unfocus();
          break;
        case AreaType.emoji:
          break;
        case AreaType.audio:
          break;
        case AreaType.attachment:
          break;
      }
      areaType = next;
      print('areaType ==> $areaType');
      // Future.delayed(Duration(seconds: 1), () {
      //   if(close) {
      //     _inputFocusNode.unfocus();
      //   }
      // });
    }
    setState(() {});
  }

  _onEmojiSelected(Emoji emoji) {
    _textController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }

  Widget _attachmentItem(BuildContext context, int index) {
    var item = widget.attachments?[index];
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 12,
        ),
        Material(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            highlightColor: Colors.grey,
            focusColor: Colors.grey,
            onTap: item?.onClick.call,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: item?.icon,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        item!.title
      ],
    );
  }
}

class ChatAttachment {
  final Widget icon;

  final Widget title;

  final VoidCallback onClick;

  ChatAttachment(this.icon, this.title, this.onClick);
}

enum AreaType {
  none,
  input,
  emoji,
  audio,
  attachment,
}
