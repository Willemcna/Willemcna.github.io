import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import 'message_bubble.dart';
import 'message_input_bar.dart';
import '../../../core/utils/date_formatter.dart';

class ChatView extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasMoreMessages;
  final Function()? onLoadMore;
  final String? searchQuery;
  final String? sessionId;
  final bool isToggledOn;
  final String? orgId;

  const ChatView({
    super.key,
    required this.messages,
    this.isLoading = false,
    this.hasMoreMessages = false,
    this.onLoadMore,
    this.searchQuery,
    this.sessionId,
    this.isToggledOn = false,
    this.orgId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool _isNearTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Scroll to bottom on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.messages.isNotEmpty && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when new messages arrive
    if (widget.messages.length > oldWidget.messages.length &&
        _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels < 100) {
      if (!_isNearTop) {
        _isNearTop = true;
        if (widget.hasMoreMessages && widget.onLoadMore != null) {
          widget.onLoadMore!();
        }
      }
    } else {
      _isNearTop = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ChatMessage> get _filteredMessages {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return widget.messages;
    }
    final query = widget.searchQuery!.toLowerCase();
    return widget.messages.where((msg) {
      return msg.message.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _filteredMessages;

    if (filteredMessages.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No messages found'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: false,
            padding: const EdgeInsets.all(16),
            itemCount: filteredMessages.length + (widget.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && widget.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final messageIndex = widget.isLoading ? index - 1 : index;
              final message = filteredMessages[messageIndex];

              // Check if we should show a day separator
              final shouldShowDaySeparator =
                  messageIndex == 0 ||
                  (messageIndex > 0 &&
                      !DateFormatter.isSameDay(
                        message.time,
                        filteredMessages[messageIndex - 1].time,
                      ));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (shouldShowDaySeparator) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormatter.formatDayHeader(message.time),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Align(
                    alignment: message.message.isHuman
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: MessageBubble(message: message, showTimestamp: true),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
        // Message input bar (only shown when session is toggled on)
        if (widget.isToggledOn &&
            widget.sessionId != null &&
            widget.orgId != null)
          MessageInputBar(
            sessionId: widget.sessionId!,
            orgId: widget.orgId,
            onMessageSent: (message) {
              // Optionally refresh messages or handle sent message
            },
          ),
      ],
    );
  }
}
