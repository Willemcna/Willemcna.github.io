import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'How It Works',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything starts where your customers already are: WhatsApp.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildStep(
                  context,
                  '1. Customer sends a message or voice note',
                  'Your customer reaches out on WhatsApp with a question, order, or booking request.',
                ),
                const SizedBox(height: 12),
                _buildStep(
                  context,
                  '2. The WhatsApp Agent responds instantly',
                  'The agent uses your approved products, services, rules and policies to answer and guide the customer.',
                ),
                const SizedBox(height: 12),
                _buildStep(
                  context,
                  '3. Product or Service flow',
                  'If they want to buy a product, the Product Branch helps them complete an order. '
                      'If they want a service, the Service Branch books an appointment in your calendar.',
                ),
                const SizedBox(height: 12),
                _buildStep(
                  context,
                  '4. Marketing engine and dashboard keep things running',
                  'The Direct Marketing & Messaging Engine brings customers back at the right time, '
                      'while the Dashboard shows you conversations, KPIs, and customer data.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WhatsAppAgentIntroSection extends StatelessWidget {
  const WhatsAppAgentIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pillar 1: The WhatsApp Agent',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'The WhatsApp Agent is the core of the system. It talks to your customers in a natural, helpful way '
              'using text and voice notes, while staying strictly within your approved data: your products, '
              'services, rules and policies.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              children: [
                _buildAgentHighlight(
                  context,
                  'WhatsApp-native',
                  'Lives entirely inside WhatsApp, where your customers are already active.',
                ),
                _buildAgentHighlight(
                  context,
                  'Understands voice notes',
                  'Transcribes and interprets voice notes to understand intent and take action.',
                ),
                _buildAgentHighlight(
                  context,
                  'Grounded in your data',
                  'Only answers based on your real products, services, and business rules.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentHighlight(
    BuildContext context,
    String title,
    String description,
  ) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ProductBranchSection extends StatelessWidget {
  const ProductBranchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For Product Businesses: Sell directly via WhatsApp',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'The Product Branch helps customers buy physical products quickly and without confusion.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildBulletList(
              context,
              [
                'Answer detailed product questions (uses, ingredients, specifications, etc.).',
                'Display products with images and prices.',
                'Add items to a shopping cart and send a checkout link or website link.',
                'Suggest additional or related products to increase basket size.',
                'Process voice notes and interpret what the customer wants to buy.',
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ideal for businesses selling cleaning products, food items, health products, and retail goods.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceBranchSection extends StatelessWidget {
  const ServiceBranchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For Service Businesses: Automate bookings on WhatsApp',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'The Service Branch assists customers in finding a time and booking appointments without back-and-forth.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildBulletList(
              context,
              [
                'Answer questions about your services and pricing.',
                'Display available time slots in real-time.',
                'Check multi-staff availability for teams with multiple practitioners.',
                'Book appointments directly in your calendar and prevent double-booking.',
                'Send booking confirmations and payment links (services only).',
                'Send reminders leading up to the appointment.',
                'Turn voice notes into clear booking actions.',
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ideal for salons, clinics, veterinarians, and any business that relies on scheduled appointments.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class DirectMarketingSection extends StatelessWidget {
  const DirectMarketingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pillar 2: Direct Marketing & Messaging Engine',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'This outbound engine sends proactive, personalised, and precisely timed messages to your customers. '
              'It is designed to increase return visits, improve lifetime value, and reduce drop-off between service or purchase cycles.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildSubsection(
              context,
              'Predictive messaging',
              [
                'Identifies when a customer is likely to run out of a product or need a service again.',
                'Sends reminders at exactly the right time to encourage re-orders and re-bookings.',
                'Grows sales without aggressive, spammy marketing.',
              ],
            ),
            const SizedBox(height: 16),
            _buildSubsection(
              context,
              'Personalised messaging',
              [
                'Uses emotional drivers, previous purchases, behaviour patterns, and engagement frequency.',
                'Tailors wording and timing so messages feel relevant, friendly, and genuinely helpful.',
              ],
            ),
            const SizedBox(height: 16),
            _buildSubsection(
              context,
              'Direct campaigns',
              [
                'Broadcast seasonal specials and new products.',
                'Fill quiet days with targeted booking promotions.',
                'Send follow-up messages after purchases or appointments.',
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Direct Marketing uses smart timing and real customer data — not random spam — to maximise conversion.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pillar 3: The Dashboard',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'The dashboard is your control centre. It gives you oversight of conversations, performance, customer data, '
              'and outbound campaigns in one place.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildCard(
                  context,
                  'Conversations',
                  [
                    'See all customer–agent conversations in one view.',
                    'Spot the questions people ask most often.',
                    'Identify gaps in information and opportunities for new offerings.',
                  ],
                ),
                _buildCard(
                  context,
                  'KPIs & insights',
                  [
                    'Track time saved by automation.',
                    'See the number of sales and bookings generated.',
                    'Understand busy vs quiet times and customer frequency.',
                  ],
                ),
                _buildCard(
                  context,
                  'CRM view',
                  [
                    'Organise customer profiles, purchase and service histories.',
                    'Capture emotional drivers and preferences.',
                    'View predicted next purchase or booking dates.',
                  ],
                ),
                _buildCard(
                  context,
                  'Outbound controls',
                  [
                    'Launch campaigns and trigger reminders.',
                    'Target specific customer groups.',
                    'Review message performance and refine over time.',
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OutcomesSection extends StatelessWidget {
  const OutcomesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What You Get',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'When the WhatsApp Agent, Direct Marketing Engine, and Dashboard work together, you get a modern, automated business that runs smoothly 24/7.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildBulletList(
              context,
              [
                'Faster customer service.',
                'Reduced admin workload.',
                'Fewer mistakes and missed messages.',
                'More sales and bookings.',
                'Higher customer satisfaction.',
                'A business that operates smoothly, even when you are offline.',
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'The system is designed to reduce friction, save time, and increase revenue — all by meeting customers on WhatsApp.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.onWhatsAppTap,
    required this.displayPhoneNumber,
  });

  final VoidCallback onWhatsAppTap;
  final String displayPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ready to talk?',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Send us a WhatsApp with your business name and we’ll walk you through how the system can work for you.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onWhatsAppTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('WhatsApp us'),
              ),
              const SizedBox(height: 16),
              Text(
                'Or message us on WhatsApp at $displayPhoneNumber',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildBulletList(BuildContext context, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

Widget _buildSubsection(
  BuildContext context,
  String title,
  List<String> bullets,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      const SizedBox(height: 8),
      _buildBulletList(context, bullets),
    ],
  );
}

Widget _buildCard(
  BuildContext context,
  String title,
  List<String> bullets,
) {
  return SizedBox(
    width: 280,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildBulletList(context, bullets),
          ],
        ),
      ),
    ),
  );
}


