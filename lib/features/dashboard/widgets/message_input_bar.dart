import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/services/webhook_service.dart';

class MessageInputBar extends StatefulWidget {
  final String sessionId;
  final String? orgId;
  final Function(String message)? onMessageSent;

  const MessageInputBar({
    super.key,
    required this.sessionId,
    this.orgId,
    this.onMessageSent,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isSending = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _isListening = status == 'listening';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    if (mounted) {
      setState(() {
        _speechAvailable = available;
      });
    }
  }

  void _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _messageController.text = result.recognizedWords;
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (widget.orgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organization not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final webhookService = WebhookService();
      await webhookService.sendMessageWebhook(
        orgId: widget.orgId!,
        sessionId: widget.sessionId,
        message: message,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _messageController.clear();
        widget.onMessageSent?.call(message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Transcribe button
            if (_speechAvailable)
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
                tooltip: _isListening ? 'Stop recording' : 'Start recording',
              ),
            // Message input field
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _isSending ? null : _sendMessage,
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }
}
