import 'package:flutter/material.dart';
import '../../../core/models/session.dart' as models;
import '../../../core/utils/date_formatter.dart';
import '../models/chat_category.dart';

class ChatList extends StatelessWidget {
  final List<models.Session> sessions;
  final models.Session? selectedSession;
  final Function(models.Session) onSessionSelected;
  final String? searchQuery;
  final Function(String) onToggleStar;
  final bool Function(String) isStarred;
  final ChatCategory category;
  final Map<String, String> handoverBuckets; // sessionId -> bucket

  const ChatList({
    super.key,
    required this.sessions,
    this.selectedSession,
    required this.onSessionSelected,
    this.searchQuery,
    required this.onToggleStar,
    required this.isStarred,
    this.category = ChatCategory.aiChat,
    this.handoverBuckets = const {},
  });

  List<models.Session> get _filteredSessions {
    // First filter by category
    List<models.Session> categoryFiltered;
    switch (category) {
      case ChatCategory.aiChat:
        // Show sessions that are NOT starred AND NOT in handover
        // OR sessions in handover that are toggled off
        categoryFiltered = sessions.where((session) {
          final isInHandover = handoverBuckets.containsKey(session.sessionId);
          final isToggledOn = isStarred(session.sessionId);

          if (isInHandover) {
            // If in handover but toggled off, show in AI Chat
            return !isToggledOn;
          }
          // Not in handover and not starred
          return !isToggledOn;
        }).toList();
        break;
      case ChatCategory.general:
        // Show sessions that ARE starred (toggled on) OR in handover with bucket "general" (and toggled on)
        categoryFiltered = sessions.where((session) {
          final bucket = handoverBuckets[session.sessionId];
          final isToggledOn = isStarred(session.sessionId);

          if (bucket != null && bucket.toLowerCase() == 'general') {
            // Only show if toggled on
            return isToggledOn;
          }
          // Regular starred sessions
          return isToggledOn && bucket == null;
        }).toList();
        break;
      case ChatCategory.quotes:
        // Show sessions in handover with bucket "quotes" (and toggled on)
        categoryFiltered = sessions.where((session) {
          final bucket = handoverBuckets[session.sessionId];
          final isToggledOn = isStarred(session.sessionId);
          return bucket != null &&
              bucket.toLowerCase() == 'quotes' &&
              isToggledOn;
        }).toList();
        break;
      case ChatCategory.delivery:
        // Show sessions in handover with bucket "delivery" (and toggled on)
        categoryFiltered = sessions.where((session) {
          final bucket = handoverBuckets[session.sessionId];
          final isToggledOn = isStarred(session.sessionId);
          return bucket != null &&
              bucket.toLowerCase() == 'delivery' &&
              isToggledOn;
        }).toList();
        break;
    }

    // Then apply search query if provided
    if (searchQuery == null || searchQuery!.isEmpty) {
      return categoryFiltered;
    }
    final query = searchQuery!.toLowerCase();
    return categoryFiltered.where((session) {
      return session.sessionId.toLowerCase().contains(query) ||
          (session.lastMessage?.message.content.toLowerCase().contains(query) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _filteredSessions;

    if (filteredSessions.isEmpty) {
      return const Center(child: Text('No conversations found'));
    }

    // Group sessions by day
    final groupedSessions = <String, List<models.Session>>{};
    for (final session in filteredSessions) {
      final dayHeader = DateFormatter.formatDayHeader(
        session.lastMessageDateTime,
      );
      if (!groupedSessions.containsKey(dayHeader)) {
        groupedSessions[dayHeader] = [];
      }
      groupedSessions[dayHeader]!.add(session);
    }

    return ListView.builder(
      itemCount: groupedSessions.length,
      itemBuilder: (context, index) {
        final dayHeader = groupedSessions.keys.elementAt(index);
        final daySessions = groupedSessions[dayHeader]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dayHeader,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...daySessions.map(
              (session) => _buildSessionTile(context, session),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionTile(BuildContext context, models.Session session) {
    final isSelected = selectedSession?.sessionId == session.sessionId;
    final lastMessage = session.lastMessage;
    final starred = isStarred(session.sessionId);
    final isInHandover = handoverBuckets.containsKey(session.sessionId);

    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(
        child: Text(session.sessionId.substring(0, 1).toUpperCase()),
      ),
      title: Text(session.sessionId),
      subtitle: lastMessage != null
          ? Text(
              lastMessage.message.content.length > 50
                  ? '${lastMessage.message.content.substring(0, 50)}...'
                  : lastMessage.message.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      // Toggle switch must always appear next to the session ID (trailing).
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastMessage != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                DateFormatter.formatRelative(lastMessage.time),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Switch(
            value: starred,
            onChanged: (_) => onToggleStar(session.sessionId),
          ),
        ],
      ),
      onTap: () => onSessionSelected(session),
    );
  }
}
