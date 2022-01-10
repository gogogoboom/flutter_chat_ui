import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents send button widget
class FireButton extends StatelessWidget {
  /// Creates send button widget
  const FireButton({
    Key? key,
    required this.onPressed, this.fireNow,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;
  final String? fireNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      // margin: const EdgeInsets.only(right: 12),
      // width: 24,
      child: IconButton(
        icon: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icon-fire.png',
              color: InheritedChatTheme.of(context).theme.inputTextColor,
              package: 'flutter_chat_ui',
              width: 24,
              height: 24,
            ),
            if(fireNow != null)
            Text(fireNow!, style: TextStyle(
              fontSize: 6,
              color: InheritedChatTheme.of(context).theme.inputTextColor
            ),)
          ],
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      ),
    );
  }
}
