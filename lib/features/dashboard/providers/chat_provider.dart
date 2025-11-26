import 'package:flutter/foundation.dart';
import '../../../core/models/session.dart' as models;
import '../../../core/models/chat_message.dart';
import '../../../core/services/chat_service.dart';
import 'dart:async';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;

  ChatProvider(this._chatService);

  List<models.Session> _sessions = [];
  models.Session? _selectedSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _realtimeSubscription;
  bool _hasMoreMessages = true;
  int _messageOffset = 0;

  List<models.Session> get sessions => _sessions;
  models.Session? get selectedSession => _selectedSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreMessages => _hasMoreMessages;

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _chatService.getSessions();
      _subscribeToUpdates();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectSession(models.Session session) async {
    _selectedSession = session;
    _messages = [];
    _messageOffset = 0;
    _hasMoreMessages = true;
    _error = null;
    notifyListeners();

    await loadMessages();
    _subscribeToSessionUpdates();
  }

  Future<void> loadMessages() async {
    if (_selectedSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newMessages = await _chatService.getSessionMessages(
        _selectedSession!.sessionId,
        limit: 50,
        offset: _messageOffset,
      );

      if (newMessages.isEmpty) {
        _hasMoreMessages = false;
      } else {
        _messages = [...newMessages, ..._messages];
        _messageOffset += newMessages.length;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToUpdates() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _chatService.subscribeToAllMessages().listen((newMessages) {
      // Reload sessions when new messages arrive
      loadSessions();
    });
  }

  void _subscribeToSessionUpdates() {
    if (_selectedSession == null) return;

    _realtimeSubscription?.cancel();
    _realtimeSubscription = _chatService
        .subscribeToSession(_selectedSession!.sessionId)
        .listen((newMessages) {
      _messages = [..._messages, ...newMessages];
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _chatService.unsubscribe();
    super.dispose();
  }
}

