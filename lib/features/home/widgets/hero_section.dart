import 'package:flutter/material.dart';
import '../../../shared/widgets/chat_bubble.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onWhatsAppTap,
    required this.onHowItWorksTap,
  });

  final VoidCallback onWhatsAppTap;
  final VoidCallback onHowItWorksTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const ChatBubble(
                text: 'Hi, I\'m AChat – your WhatsApp AI that handles product and service conversations for you.',
                isUser: false,
              ),
              const ChatBubble(
                text: 'I answer questions, take bookings, and keep your customers engaged 24/7.',
                isUser: true,
              ),
              const ChatBubble(
                text: 'Ready to see how this could work for your business?',
                isUser: false,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onWhatsAppTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('WhatsApp us'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: onHowItWorksTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'How it works',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

