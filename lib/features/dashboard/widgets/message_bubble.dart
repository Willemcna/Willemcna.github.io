import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/utils/message_parser.dart';
import '../../../core/utils/date_formatter.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final isHuman = message.message.isHuman;
    final content = message.message.content;

    return Column(
      crossAxisAlignment: isHuman ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isHuman
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessageContent(context, content, isHuman),
              if (showTimestamp) ...[
                const SizedBox(height: 4),
                _buildTimestamp(context),
              ],
            ],
          ),
        ),
        if (message.message.isAI) ...[
          const SizedBox(height: 4),
          _buildMessageTypeIndicators(context, content),
        ],
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context, String content, bool isHuman) {
    // Check for URLs and make them clickable
    final urls = MessageParser.extractUrls(content);
    
    if (urls.isEmpty) {
      return Text(
        content,
        style: TextStyle(
          color: isHuman
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    // Simple URL highlighting (for MVP)
    return SelectableText(
      content,
      style: TextStyle(
        color: isHuman
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: DateFormatter.formatAbsolute(message.time),
          child: Text(
            DateFormatter.formatRelative(message.time),
            style: TextStyle(
              fontSize: 11,
              color: message.message.isHuman
                  ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTypeIndicators(BuildContext context, String content) {
    final indicators = <Widget>[];

    if (MessageParser.hasOrderLink(content, true)) {
      indicators.add(
        Chip(
          label: const Text('Order Link'),
          avatar: const Icon(Icons.link, size: 16),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (MessageParser.hasHandover(content, true)) {
      indicators.add(
        Chip(
          label: const Text('Handover'),
          avatar: const Icon(Icons.phone, size: 16),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      alignment: WrapAlignment.end,
      children: indicators,
    );
  }
}

