import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/src/widgets/audio_controller.dart';

import '../util.dart';
import 'inherited_user.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.bubbleBuilder,
    this.customMessageBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageMessageBuilder,
    required this.message,
    required this.messageWidth,
    this.onAvatarTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.usePreviewData,
    required this.mPlayer,
    required this.audioController,
    this.onMessageFirePress, this.onAvatarLongPress, this.headers,
  }) : super(key: key);

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author)
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Build a custom message inside predefined bubble
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// Build an image message inside predefined bubble
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// Any message type
  final types.Message message;

  /// Maximum message width
  final int messageWidth;

  // Called when uses taps on an avatar
  final void Function(types.User)? onAvatarTap;
  final void Function(types.User)? onAvatarLongPress;

  /// Called when user makes a long press on any message
  final void Function(types.Message, GlobalKey)? onMessageLongPress;

  final void Function(types.Message, GlobalKey)? onMessageFirePress;

  /// Called when user makes a long press on status icon in any message
  final void Function(types.Message)? onMessageStatusLongPress;

  /// Called when user taps on status icon in any message
  final void Function(types.Message)? onMessageStatusTap;

  /// Called when user taps on any message
  final void Function(types.Message)? onMessageTap;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName]
  final bool showName;

  /// Show message's status
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  final FlutterSoundPlayer mPlayer;

  final AudioController audioController;

  final Map<String, String>? headers;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.usePreviewData]
  final bool usePreviewData;

  Widget _avatarBuilder(BuildContext context) {
    final color = getUserAvatarNameColor(
      message.author,
      InheritedChatTheme.of(context).theme.userAvatarNameColors,
    );
    final hasImage = message.author.imageUrl != null;
    final initials = getUserInitials(message.author);

    return showAvatar
        ? Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onLongPress: () => onAvatarLongPress?.call(message.author),
              onTap: () => onAvatarTap?.call(message.author),
              child: CircleAvatar(
                backgroundColor: hasImage
                    ? InheritedChatTheme.of(context)
                        .theme
                        .userAvatarImageBackgroundColor
                    : color,
                backgroundImage:
                    hasImage ? NetworkImage(message.author.imageUrl!) : null,
                radius: 16,
                child: !hasImage
                    ? Text(
                        initials,
                        style: InheritedChatTheme.of(context)
                            .theme
                            .userAvatarTextStyle,
                      )
                    : null,
              ),
            ),
          )
        : const SizedBox(width: 40);
  }

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) {
    bool isFiring = false;
    //正在焚毁的消息不需要去掉背景,同textMessage
    isFiring = message.metadata?['firing'] ?? false;
    return bubbleBuilder != null
        ? bubbleBuilder!(
            _messageBuilder(currentUserIsAuthor),
            message: message,
            nextMessageInGroup: roundBorder,
          )
        : enlargeEmojis && hideBackgroundOnEmojiMessages && !isFiring
            ? _messageBuilder(currentUserIsAuthor)
            : Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: !currentUserIsAuthor ||
                          message.type == types.MessageType.image
                      ? InheritedChatTheme.of(context).theme.secondaryColor
                      : InheritedChatTheme.of(context).theme.primaryColor,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: _messageBuilder(currentUserIsAuthor),
                ),
              );
  }

  Widget _messageBuilder(bool currentUserIsAuthor) {
    //即将焚毁的消息
    if(message.metadata?['firing'] ?? false) {
      return TextMessage(
        emojiEnlargementBehavior: emojiEnlargementBehavior,
        hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
        message: types.TextMessage(
          author: message.author,
          id: message.id,
          text:  message.metadata?['fireTip'] ?? '消息已焚'
        ),
        onPreviewDataFetched: onPreviewDataFetched,
        showName: showName,
        usePreviewData: usePreviewData,
      );
    }
    switch (message.type) {
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        if (fileMessageBuilder != null) {
          return fileMessageBuilder!(fileMessage, messageWidth: messageWidth);
        }
        switch (fileMessage.mimeType) {
          case 'audio':
          case 'acc':
          case 'audio/x-aac':
            return AudioMessage(
              message: fileMessage,
              showName: showName,
              audioController: audioController,
              currentUserIsAuthor: currentUserIsAuthor,
            );
          default:
            return FileMessage(message: fileMessage);
        }
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(message: imageMessage, messageWidth: messageWidth, headers: headers,);
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                onPreviewDataFetched: onPreviewDataFetched,
                showName: showName,
                usePreviewData: usePreviewData,
              );
      default:
        return const SizedBox();
    }
  }

  Widget _statusBuilder(BuildContext context) {
    print('_statusBuilder: ${message.status}');
    switch (message.status) {
      case types.Status.delivered:
      case types.Status.sent:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
                'assets/icon-error.png',
                color: InheritedChatTheme.of(context).theme.errorColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
                'assets/icon-seen.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InheritedChatTheme.of(context).theme.primaryColor,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _currentUserIsAuthor = _user.id == message.author.id;
    final _enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
                emojiEnlargementBehavior, message as types.TextMessage);
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(
        _currentUserIsAuthor || roundBorder ? _messageBorderRadius : 0,
      ),
      bottomRight: Radius.circular(_currentUserIsAuthor
          ? roundBorder
              ? _messageBorderRadius
              : 0
          : _messageBorderRadius),
      topLeft: Radius.circular(_messageBorderRadius),
      topRight: Radius.circular(_messageBorderRadius),
    );
    var messageKey = GlobalKey();
    var fireKey = GlobalKey();
    bool isFireMessage = false;
    bool isFiring = false;
    try {
      isFireMessage = message.metadata?['fireTime'] > 0;
      //正在焚毁的消息不需要去掉背景,同textMessage
      isFiring = message.metadata?['firing'] ?? false;
    } catch (e) {
      // print('fireTime解析失败');
    }
    return Container(
      alignment:
          _currentUserIsAuthor ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(
        bottom: 4,
        left: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentUserIsAuthor && isFireMessage && !isFiring)
            _fireWidget(fireKey),
          if (!_currentUserIsAuthor && showUserAvatars) _avatarBuilder(context),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  key: messageKey,
                  onLongPress: () =>
                      onMessageLongPress?.call(message, messageKey),
                  onTap: () {
                    if (message is types.FileMessage) {
                      if ((message as types.FileMessage)
                              .mimeType
                              ?.contains('audio') ??
                          false) {
                        audioController
                            .togglePlayer(message as types.FileMessage);
                      }
                    } else {
                      onMessageTap?.call(message);
                    }
                  },
                  child: _bubbleBuilder(
                    context,
                    _borderRadius,
                    _currentUserIsAuthor,
                    _enlargeEmojis,
                  ),
                ),
              ],
            ),
          ),
          if (_currentUserIsAuthor)
            Padding(
              padding: InheritedChatTheme.of(context).theme.statusIconPadding,
              child: showStatus
                  ? GestureDetector(
                      onLongPress: () =>
                          onMessageStatusLongPress?.call(message),
                      onTap: () => onMessageStatusTap?.call(message),
                      child: _statusBuilder(context),
                    )
                  : null,
            ),
          if (!_currentUserIsAuthor && isFireMessage && !isFiring)
            _fireWidget(fireKey)
        ],
      ),
    );
  }

  _fireWidget(GlobalKey key) => GestureDetector(
    key: key,
    onTap: () => onMessageFirePress?.call(message, key),
    child: Image.asset(
      'assets/icon-fire.png',
      color: Colors.red,
      package: 'flutter_chat_ui',
      width: 24,
      height: 24,
    ),
  );
}
