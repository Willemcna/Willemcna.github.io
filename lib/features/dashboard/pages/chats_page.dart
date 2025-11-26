import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/organization_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/services/chat_service.dart';
import '../providers/dashboard_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_list.dart';
import '../widgets/chat_view.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final orgService = OrganizationService();
            final tenantService = TenantService();
            return DashboardProvider(orgService, tenantService)..loadOrganizations();
          },
        ),
        ChangeNotifierProxyProvider<DashboardProvider, ChatProvider>(
          create: (_) {
            final tenantService = TenantService();
            final chatService = ChatService(tenantService);
            return ChatProvider(chatService);
          },
          update: (_, dashboardProvider, previous) {
            final tenantService = TenantService();
            final chatService = ChatService(tenantService);
            final provider = previous ?? ChatProvider(chatService);
            if (dashboardProvider.hasTenantConnection) {
              provider.loadSessions();
            }
            return provider;
          },
        ),
      ],
      child: Consumer2<DashboardProvider, ChatProvider>(
        builder: (context, dashboardProvider, chatProvider, _) {
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
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: ChatList(
                    sessions: chatProvider.sessions,
                    selectedSession: chatProvider.selectedSession,
                    onSessionSelected: (session) {
                      chatProvider.selectSession(session);
                    },
                    searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
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
                          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
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

