import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/hero_section.dart';
import '../widgets/sections.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _whatsAppDisplayNumber = '+27 81 706 9318';
  static const String _whatsAppUrl = 'https://wa.me/27817069318';

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _productKey = GlobalKey();
  final GlobalKey _serviceKey = GlobalKey();
  final GlobalKey _predictionKey = GlobalKey();
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  Future<void> _scrollToSection(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(_whatsAppUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AChat'),
        actions: [
          TextButton(
            onPressed: () => _scrollToSection(_heroKey),
            child: const Text('Overview'),
          ),
          TextButton(
            onPressed: () => _scrollToSection(_serviceKey),
            child: const Text('Service businesses'),
          ),
          TextButton(
            onPressed: () => _scrollToSection(_productKey),
            child: const Text('Product businesses'),
          ),
          TextButton(
            onPressed: () => _scrollToSection(_predictionKey),
            child: const Text('Prediction model'),
          ),
          TextButton(
            onPressed: () => _scrollToSection(_dashboardKey),
            child: const Text('Dashboard'),
          ),
          TextButton(
            onPressed: () => _scrollToSection(_contactKey),
            child: const Text('Contact'),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/signup');
            },
            child: const Text('Sign Up'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            KeyedSubtree(
              key: _heroKey,
              child: HeroSection(
                onWhatsAppTap: _launchWhatsApp,
                onHowItWorksTap: () => _scrollToSection(_howItWorksKey),
              ),
            ),
            KeyedSubtree(
              key: _howItWorksKey,
              child: const HowItWorksSection(),
            ),
            const WhatsAppAgentIntroSection(),
            KeyedSubtree(
              key: _productKey,
              child: const ProductBranchSection(),
            ),
            KeyedSubtree(
              key: _serviceKey,
              child: const ServiceBranchSection(),
            ),
            _WhatsAppCtaBanner(
              message:
                  'Want this for your business? Tap below to chat with us on WhatsApp.',
              onTap: _launchWhatsApp,
            ),
            KeyedSubtree(
              key: _predictionKey,
              child: const DirectMarketingSection(),
            ),
            KeyedSubtree(
              key: _dashboardKey,
              child: const DashboardSection(),
            ),
            _WhatsAppCtaBanner(
              message:
                  'See how your data would look in the dashboard – message us on WhatsApp.',
              onTap: _launchWhatsApp,
            ),
            const OutcomesSection(),
            KeyedSubtree(
              key: _contactKey,
              child: ContactSection(
                onWhatsAppTap: _launchWhatsApp,
                displayPhoneNumber: _whatsAppDisplayNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppCtaBanner extends StatelessWidget {
  const _WhatsAppCtaBanner({
    required this.message,
    required this.onTap,
  });

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onTap,
                  child: const Text('WhatsApp us'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

