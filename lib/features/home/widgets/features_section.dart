import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return isWide
                  ? _buildWideLayout(context)
                  : _buildNarrowLayout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildFeatureCard(context, Icons.analytics, 'Real-time Analytics', 'Track KPIs, message volume, and performance metrics in real-time')),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(context, Icons.chat_bubble, 'WhatsApp-style Chat View', 'View conversations exactly as they appear in WhatsApp')),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(context, Icons.link, 'Order Link Tracking', 'Monitor when order links are sent to customers')),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(context, Icons.phone, 'Human Handover Detection', 'Track when conversations are escalated to human agents')),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(context, Icons.analytics, 'Real-time Analytics', 'Track KPIs, message volume, and performance metrics in real-time'),
        const SizedBox(height: 24),
        _buildFeatureCard(context, Icons.chat_bubble, 'WhatsApp-style Chat View', 'View conversations exactly as they appear in WhatsApp'),
        const SizedBox(height: 24),
        _buildFeatureCard(context, Icons.link, 'Order Link Tracking', 'Monitor when order links are sent to customers'),
        const SizedBox(height: 24),
        _buildFeatureCard(context, Icons.phone, 'Human Handover Detection', 'Track when conversations are escalated to human agents'),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

