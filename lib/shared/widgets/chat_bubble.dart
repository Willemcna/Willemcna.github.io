import 'package:flutter/material.dart';

/// Simple chat-style speech bubble used on the homepage hero.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, this.isUser = false});

  /// Bubble text content.
  final String text;

  /// When true, renders as a right-aligned \"user\" bubble; otherwise left-aligned.
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
