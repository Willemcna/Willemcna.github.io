import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/organization_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/handover_service.dart';
import '../../../core/services/webhook_service.dart';
import '../../../core/models/session.dart' as models;
import '../providers/dashboard_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_list.dart';
import '../widgets/chat_view.dart';
import '../models/chat_category.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _starredSessions = <String>{};
  late TabController _tabController;
  ChatCategory _selectedCategory = ChatCategory.aiChat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = ChatCategory.values[_tabController.index];
      });
    });
  }

  void _ensureHandoverSessionsAreToggledOn(ChatProvider chatProvider) {
    // Automatically toggle on all handover sessions
    bool updated = false;
    for (final sessionId in chatProvider.handoverBuckets.keys) {
      // Check if it's not already explicitly toggled off
      if (!_starredSessions.contains('off_$sessionId')) {
        // If it's not in the starred set at all, we need to ensure it's toggled on
        // We'll use a special marker to indicate it's a handover session that should be on
        if (!_starredSessions.contains('handover_$sessionId')) {
          _starredSessions.add('handover_$sessionId');
          updated = true;
        }
      }
    }
    if (updated) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleStar(
    String sessionId,
    String? orgId,
    ChatProvider chatProvider,
  ) async {
    final isInHandover = chatProvider.isSessionInHandover(sessionId);
    final wasStarred = _isStarred(sessionId, chatProvider);
    final isNowOn = !wasStarred;

    setState(() {
      if (isInHandover) {
        // For handover sessions, track toggled off state separately
        if (wasStarred) {
          // Toggling off - mark as off
          _starredSessions.add('off_$sessionId');
        } else {
          // Toggling on - remove off marker
          _starredSessions.remove('off_$sessionId');
        }
      } else {
        // Regular sessions
        if (wasStarred) {
          _starredSessions.remove(sessionId);
        } else {
          _starredSessions.add(sessionId);
        }
      }
    });

    // Send webhook if organization is available
    if (orgId != null) {
      try {
        final webhookService = WebhookService();
        await webhookService.sendChatToggleWebhook(
          orgId: orgId,
          sessionId: sessionId,
          isOn: isNowOn,
        );
      } catch (e) {
        // Log error but don't show to user - webhook failures shouldn't break the UI
        print('Failed to send webhook: $e');
        // Optionally show a subtle notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Webhook notification failed: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  bool _isStarred(String sessionId, ChatProvider chatProvider) {
    // Sessions in handover are automatically toggled on
    if (chatProvider.isSessionInHandover(sessionId)) {
      // If explicitly toggled off, return false
      if (_starredSessions.contains('off_$sessionId')) {
        return false;
      }
      // Otherwise, handover sessions are automatically on
      return true;
    }
    // Regular sessions use normal starred state
    return _starredSessions.contains(sessionId);
  }

  int _getCategoryCount(
    List<models.Session> sessions,
    ChatCategory category,
    ChatProvider chatProvider,
  ) {
    switch (category) {
      case ChatCategory.aiChat:
        // Count sessions that are NOT starred AND NOT in handover
        return sessions.where((s) {
          return !_isStarred(s.sessionId, chatProvider) &&
              !chatProvider.isSessionInHandover(s.sessionId);
        }).length;
      case ChatCategory.general:
        // Count sessions that ARE starred OR in handover with bucket "general" (and toggled on)
        return sessions.where((s) {
          final bucket = chatProvider.getBucketForSession(s.sessionId);
          final isToggledOn = _isStarred(s.sessionId, chatProvider);

          if (bucket != null && bucket.toLowerCase() == 'general') {
            return isToggledOn;
          }
          return isToggledOn && bucket == null;
        }).length;
      case ChatCategory.quotes:
        // Count sessions in handover with bucket "quotes" (and toggled on)
        return sessions.where((s) {
          final bucket = chatProvider.getBucketForSession(s.sessionId);
          final isToggledOn = _isStarred(s.sessionId, chatProvider);
          return bucket != null &&
              bucket.toLowerCase() == 'quotes' &&
              isToggledOn;
        }).length;
      case ChatCategory.delivery:
        // Count sessions in handover with bucket "delivery" (and toggled on)
        return sessions.where((s) {
          final bucket = chatProvider.getBucketForSession(s.sessionId);
          final isToggledOn = _isStarred(s.sessionId, chatProvider);
          return bucket != null &&
              bucket.toLowerCase() == 'delivery' &&
              isToggledOn;
        }).length;
    }
  }

  Widget _buildTabWithBadge(BuildContext context, String label, int count) {
    return Tab(
      child: count > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 4),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final orgService = OrganizationService();
            final tenantService = TenantService();
            return DashboardProvider(orgService, tenantService)
              ..loadOrganizations();
          },
        ),
        ChangeNotifierProxyProvider<DashboardProvider, ChatProvider>(
          create: (_) {
            final tenantService = TenantService();
            final chatService = ChatService(tenantService);
            final handoverService = HandoverService(tenantService);
            return ChatProvider(chatService, handoverService);
          },
          update: (_, dashboardProvider, previous) {
            final tenantService = TenantService();
            final chatService = ChatService(tenantService);
            final handoverService = HandoverService(tenantService);
            final provider =
                previous ?? ChatProvider(chatService, handoverService);
            if (dashboardProvider.hasTenantConnection) {
              provider.loadSessions();
            }
            return provider;
          },
        ),
      ],
      child: Consumer2<DashboardProvider, ChatProvider>(
        builder: (context, dashboardProvider, chatProvider, _) {
          // Ensure handover sessions are automatically toggled on (only when not loading)
          if (!chatProvider.isLoading) {
            _ensureHandoverSessionsAreToggledOn(chatProvider);
          }

          if (!dashboardProvider.hasTenantConnection) {
            return Scaffold(
              appBar: AppBar(title: const Text('Chats')),
              drawer: Sidebar(
                selectedIndex: 1,
                onItemSelected: (_) {},
                organizationName: dashboardProvider.selectedOrganization?.name,
              ),
              body: const Center(
                child: Text('Please connect Supabase in Settings'),
              ),
            );
          }

          if (chatProvider.isLoading && chatProvider.sessions.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Chats')),
              drawer: Sidebar(
                selectedIndex: 1,
                onItemSelected: (_) {},
                organizationName: dashboardProvider.selectedOrganization?.name,
              ),
              body: const LoadingIndicator(message: 'Loading chats...'),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chats'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Search'),
                        content: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search messages...',
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Clear'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            drawer: Sidebar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              organizationName: dashboardProvider.selectedOrganization?.name,
            ),
            body: Row(
              children: [
                // Chat list sidebar
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            _buildTabWithBadge(
                              context,
                              'AI Chat',
                              0,
                            ), // AI Chat doesn't show badge
                            _buildTabWithBadge(
                              context,
                              'Quotes',
                              (chatProvider.isLoading ||
                                      chatProvider.sessions.isEmpty)
                                  ? 0
                                  : _getCategoryCount(
                                      chatProvider.sessions,
                                      ChatCategory.quotes,
                                      chatProvider,
                                    ),
                            ),
                            _buildTabWithBadge(
                              context,
                              'Delivery',
                              (chatProvider.isLoading ||
                                      chatProvider.sessions.isEmpty)
                                  ? 0
                                  : _getCategoryCount(
                                      chatProvider.sessions,
                                      ChatCategory.delivery,
                                      chatProvider,
                                    ),
                            ),
                            _buildTabWithBadge(
                              context,
                              'General',
                              (chatProvider.isLoading ||
                                      chatProvider.sessions.isEmpty)
                                  ? 0
                                  : _getCategoryCount(
                                      chatProvider.sessions,
                                      ChatCategory.general,
                                      chatProvider,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      // Chat list
                      Expanded(
                        child: ChatList(
                          sessions: chatProvider.sessions,
                          selectedSession: chatProvider.selectedSession,
                          onSessionSelected: (session) {
                            chatProvider.selectSession(session);
                          },
                          searchQuery: _searchQuery.isEmpty
                              ? null
                              : _searchQuery,
                          onToggleStar: (sessionId) => _toggleStar(
                            sessionId,
                            dashboardProvider.selectedOrganization?.id,
                            chatProvider,
                          ),
                          isStarred: (sessionId) =>
                              _isStarred(sessionId, chatProvider),
                          category: _selectedCategory,
                          handoverBuckets: chatProvider.handoverBuckets,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat view
                Expanded(
                  child: chatProvider.selectedSession == null
                      ? const Center(
                          child: Text('Select a conversation to view messages'),
                        )
                      : ChatView(
                          messages: chatProvider.messages,
                          isLoading: chatProvider.isLoading,
                          hasMoreMessages: chatProvider.hasMoreMessages,
                          onLoadMore: () {
                            chatProvider.loadMessages();
                          },
                          searchQuery: _searchQuery.isEmpty
                              ? null
                              : _searchQuery,
                          sessionId: chatProvider.selectedSession?.sessionId,
                          isToggledOn: chatProvider.selectedSession != null
                              ? _isStarred(
                                  chatProvider.selectedSession!.sessionId,
                                  chatProvider,
                                )
                              : false,
                          orgId: dashboardProvider.selectedOrganization?.id,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
