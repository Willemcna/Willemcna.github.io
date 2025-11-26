import 'package:flutter/material.dart';
import '../../../core/models/session.dart' as models;
import '../../../core/utils/date_formatter.dart';

class ChatList extends StatelessWidget {
  final List<models.Session> sessions;
  final models.Session? selectedSession;
  final Function(models.Session) onSessionSelected;
  final String? searchQuery;

  const ChatList({
    super.key,
    required this.sessions,
    this.selectedSession,
    required this.onSessionSelected,
    this.searchQuery,
  });

  List<models.Session> get _filteredSessions {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return sessions;
    }
    final query = searchQuery!.toLowerCase();
    return sessions.where((session) {
      return session.sessionId.toLowerCase().contains(query) ||
          (session.lastMessage?.message.content.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _filteredSessions;

    if (filteredSessions.isEmpty) {
      return const Center(
        child: Text('No conversations found'),
      );
    }

    // Group sessions by day
    final groupedSessions = <String, List<models.Session>>{};
    for (final session in filteredSessions) {
      final dayHeader = DateFormatter.formatDayHeader(session.lastMessageDateTime);
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
            ...daySessions.map((session) => _buildSessionTile(context, session)),
          ],
        );
      },
    );
  }

  Widget _buildSessionTile(BuildContext context, models.Session session) {
    final isSelected = selectedSession?.sessionId == session.sessionId;
    final lastMessage = session.lastMessage;

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
      trailing: lastMessage != null
          ? Text(
              DateFormatter.formatRelative(lastMessage.time),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      onTap: () => onSessionSelected(session),
    );
  }
}

