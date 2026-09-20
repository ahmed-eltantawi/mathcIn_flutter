import 'package:flutter/material.dart';

import 'chat_composer.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    required this.isGenerating,
  });

  final Function(String) onSendMessage;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return ChatComposer(
      onSendMessage: onSendMessage,
      isGenerating: isGenerating,
    );
  }
}
