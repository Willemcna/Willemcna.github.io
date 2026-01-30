import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/organization_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/services/webhook_service.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/supabase_connection_form.dart';
import '../widgets/organization_switcher.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _displayNameController = TextEditingController();
  final _webhookUrlController = TextEditingController();
  final _messageWebhookUrlController = TextEditingController();
  bool _isSavingConnection = false;
  bool _isSavingWebhook = false;
  bool _isSavingMessageWebhook = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _webhookUrlController.dispose();
    _messageWebhookUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final orgService = OrganizationService();
        final tenantService = TenantService();
        return DashboardProvider(orgService, tenantService)
          ..loadOrganizations();
      },
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              drawer: Sidebar(selectedIndex: 2, onItemSelected: (_) {}),
              body: const LoadingIndicator(),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            drawer: Sidebar(
              selectedIndex: 2,
              onItemSelected: (_) {},
              organizationName: provider.selectedOrganization?.name,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Organization Switcher
                    if (provider.organizations.length > 1) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organization',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              OrganizationSwitcher(
                                organizations: provider.organizations,
                                selectedOrganization:
                                    provider.selectedOrganization,
                                onOrganizationSelected: (org) {
                                  provider.selectOrganization(org);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Supabase Connection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supabase Connection',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Connect your Supabase instance to view your dashboard',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: provider.selectedOrganization != null
                                  ? TenantService().getTenantConnection(
                                      provider.selectedOrganization!.id,
                                    )
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                String? initialUrl;
                                String? initialAnonKey;

                                if (snapshot.hasData && snapshot.data != null) {
                                  initialUrl = snapshot.data!.supabaseUrl;
                                  initialAnonKey =
                                      snapshot.data!.supabaseAnonKey;
                                }

                                return SupabaseConnectionForm(
                                  initialUrl: initialUrl,
                                  initialAnonKey: initialAnonKey,
                                  isLoading: _isSavingConnection,
                                  onSubmit: (url, anonKey) async {
                                    if (provider.selectedOrganization == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select an organization',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isSavingConnection = true);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    try {
                                      final tenantService = TenantService();
                                      await tenantService.saveTenantConnection(
                                        orgId:
                                            provider.selectedOrganization!.id,
                                        supabaseUrl: url,
                                        supabaseAnonKey: anonKey,
                                      );

                                      await provider
                                          .initializeTenantConnection();

                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Connection saved successfully',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(
                                          () => _isSavingConnection = false,
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Webhook Configuration
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Webhook Configuration',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configure a webhook URL to receive notifications when chats are toggled on/off',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: provider.selectedOrganization != null
                                  ? WebhookService().getWebhookUrl(
                                      provider.selectedOrganization!.id,
                                    )
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  _webhookUrlController.text = snapshot.data!;
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _webhookUrlController,
                                      decoration: const InputDecoration(
                                        labelText: 'Webhook URL',
                                        hintText: 'https://example.com/webhook',
                                        border: OutlineInputBorder(),
                                        helperText:
                                            'Enter the URL where webhook notifications will be sent',
                                      ),
                                      keyboardType: TextInputType.url,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _isSavingWebhook
                                          ? null
                                          : () async {
                                              if (provider
                                                      .selectedOrganization ==
                                                  null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please select an organization',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              final webhookUrl =
                                                  _webhookUrlController.text
                                                      .trim();
                                              if (webhookUrl.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please enter a webhook URL',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              setState(
                                                () => _isSavingWebhook = true,
                                              );
                                              final messenger =
                                                  ScaffoldMessenger.of(context);

                                              try {
                                                final webhookService =
                                                    WebhookService();
                                                await webhookService
                                                    .saveWebhookUrl(
                                                      orgId: provider
                                                          .selectedOrganization!
                                                          .id,
                                                      webhookUrl: webhookUrl,
                                                    );

                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Webhook saved successfully',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${e.toString()}',
                                                    ),
                                                  ),
                                                );
                                              } finally {
                                                if (mounted) {
                                                  setState(
                                                    () => _isSavingWebhook =
                                                        false,
                                                  );
                                                }
                                              }
                                            },
                                      child: _isSavingWebhook
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Save Webhook'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Message Webhook Configuration
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Message Webhook Configuration',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configure a webhook URL to receive notifications when messages are sent from the message bar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder(
                              future: provider.selectedOrganization != null
                                  ? WebhookService().getMessageWebhookUrl(
                                      provider.selectedOrganization!.id,
                                    )
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  _messageWebhookUrlController.text =
                                      snapshot.data!;
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _messageWebhookUrlController,
                                      decoration: const InputDecoration(
                                        labelText: 'Message Webhook URL',
                                        hintText:
                                            'https://example.com/message-webhook',
                                        border: OutlineInputBorder(),
                                        helperText:
                                            'Enter the URL where message webhook notifications will be sent',
                                      ),
                                      keyboardType: TextInputType.url,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _isSavingMessageWebhook
                                          ? null
                                          : () async {
                                              if (provider
                                                      .selectedOrganization ==
                                                  null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please select an organization',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              final webhookUrl =
                                                  _messageWebhookUrlController
                                                      .text
                                                      .trim();
                                              if (webhookUrl.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please enter a webhook URL',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              setState(
                                                () => _isSavingMessageWebhook =
                                                    true,
                                              );
                                              final messenger =
                                                  ScaffoldMessenger.of(context);

                                              try {
                                                final webhookService =
                                                    WebhookService();
                                                await webhookService
                                                    .saveMessageWebhookUrl(
                                                      orgId: provider
                                                          .selectedOrganization!
                                                          .id,
                                                      webhookUrl: webhookUrl,
                                                    );

                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Message webhook saved successfully',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${e.toString()}',
                                                    ),
                                                  ),
                                                );
                                              } finally {
                                                if (mounted) {
                                                  setState(
                                                    () =>
                                                        _isSavingMessageWebhook =
                                                            false,
                                                  );
                                                }
                                              }
                                            },
                                      child: _isSavingMessageWebhook
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Save Message Webhook'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
