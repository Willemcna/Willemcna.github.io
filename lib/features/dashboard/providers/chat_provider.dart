import 'package:flutter/foundation.dart';
import '../../../core/models/session.dart' as models;
import '../../../core/models/chat_message.dart';
import '../../../core/models/handover.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/handover_service.dart';
import 'dart:async';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final HandoverService _handoverService;

  ChatProvider(this._chatService, this._handoverService);

  List<models.Session> _sessions = [];
  models.Session? _selectedSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _handoverSubscription;
  bool _hasMoreMessages = true;
  int _messageOffset = 0;
  Map<String, String> _handoverBuckets = {}; // sessionId -> bucket

  List<models.Session> get sessions => _sessions;
  models.Session? get selectedSession => _selectedSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreMessages => _hasMoreMessages;
  Map<String, String> get handoverBuckets => _handoverBuckets;

  /// Get bucket for a session ID
  String? getBucketForSession(String sessionId) {
    return _handoverBuckets[sessionId];
  }

  /// Check if session is in handover
  bool isSessionInHandover(String sessionId) {
    return _handoverBuckets.containsKey(sessionId);
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _chatService.getSessions();
      await _loadHandovers();
      _subscribeToUpdates();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHandovers() async {
    try {
      final handovers = await _handoverService.getHandovers();
      _handoverBuckets.clear();
      for (final handover in handovers) {
        _handoverBuckets[handover.sessionId] = handover.bucket;
      }
      _subscribeToHandoverUpdates();
    } catch (e) {
      // Silently handle handover loading errors
      print('Failed to load handovers: $e');
    }
  }

  void _subscribeToHandoverUpdates() {
    _handoverSubscription?.cancel();
    _handoverSubscription = _handoverService.subscribeToHandovers().listen((
      handovers,
    ) {
      _handoverBuckets.clear();
      for (final handover in handovers) {
        _handoverBuckets[handover.sessionId] = handover.bucket;
      }
      notifyListeners();
    });
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
    _realtimeSubscription = _chatService.subscribeToAllMessages().listen((
      newMessages,
    ) {
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
    _handoverSubscription?.cancel();
    _chatService.unsubscribe();
    _handoverService.unsubscribe();
    super.dispose();
  }
}
