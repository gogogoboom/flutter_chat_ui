import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents attachment button widget
class AudioButton extends StatelessWidget {
  /// Creates attachment button widget
  const AudioButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      margin: const EdgeInsets.only(right: 16),
      width: 24,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.attachmentButtonIcon != null
            ? InheritedChatTheme.of(context).theme.attachmentButtonIcon!
            : Icon(Icons.keyboard_voice_outlined, color: Colors.white,),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip:
            InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
      ),
    );
  }
}
