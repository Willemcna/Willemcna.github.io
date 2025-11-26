import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/organization_service.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/product_service.dart';
import '../providers/dashboard_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/kpi_cards.dart';
import '../widgets/graphs_tab.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/organization_switcher.dart';
import '../../../shared/widgets/date_range_picker.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

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
        ChangeNotifierProxyProvider<DashboardProvider, AnalyticsProvider>(
          create: (_) {
            final tenantService = TenantService();
            final productService = ProductService(tenantService);
            final analyticsService = AnalyticsService(tenantService, productService);
            return AnalyticsProvider(analyticsService);
          },
          update: (_, dashboardProvider, previous) {
            final tenantService = TenantService();
            final productService = ProductService(tenantService);
            final analyticsService = AnalyticsService(tenantService, productService);
            final provider = previous ?? AnalyticsProvider(analyticsService);
            if (dashboardProvider.hasTenantConnection) {
              provider.loadKPIs();
            }
            return provider;
          },
        ),
      ],
      child: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          if (dashboardProvider.isLoading) {
            return Scaffold(
              body: const LoadingIndicator(message: 'Loading dashboard...'),
            );
          }

          if (dashboardProvider.error != null && !dashboardProvider.hasTenantConnection) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        dashboardProvider.error ?? 'Connection Error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                        child: const Text('Connect Supabase'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                if (dashboardProvider.organizations.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OrganizationSwitcher(
                      organizations: dashboardProvider.organizations,
                      selectedOrganization: dashboardProvider.selectedOrganization,
                      onOrganizationSelected: (org) {
                        dashboardProvider.selectOrganization(org);
                      },
                    ),
                  ),
              ],
            ),
            drawer: Sidebar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              organizationName: dashboardProvider.selectedOrganization?.name,
            ),
            body: dashboardProvider.hasTenantConnection
                ? _buildDashboardContent(context)
                : _buildEmptyState(context, dashboardProvider),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'KPIs'),
                  Tab(text: 'Graphs'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date range controls for KPIs
                          Consumer<AnalyticsProvider>(
                            builder: (context, provider, _) {
                              return DateRangePickerWidget(provider: provider);
                            },
                          ),
                          const SizedBox(height: 16),
                          KPICards(kpiData: analyticsProvider.kpiData),
                        ],
                      ),
                    ),
                    GraphsTab(
                      provider: analyticsProvider,
                      analyticsService: AnalyticsService(
                        TenantService(),
                        ProductService(TenantService()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, DashboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Supabase Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your Supabase instance to view your dashboard',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text('Connect Supabase'),
            ),
          ],
        ),
      ),
    );
  }
}

