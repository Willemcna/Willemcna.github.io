import 'package:flutter/material.dart';

class SupabaseConnectionForm extends StatefulWidget {
  final Function(String url, String anonKey) onSubmit;
  final String? initialUrl;
  final String? initialAnonKey;
  final bool isLoading;

  const SupabaseConnectionForm({
    super.key,
    required this.onSubmit,
    this.initialUrl,
    this.initialAnonKey,
    this.isLoading = false,
  });

  @override
  State<SupabaseConnectionForm> createState() => _SupabaseConnectionFormState();
}

class _SupabaseConnectionFormState extends State<SupabaseConnectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl ?? '';
    _anonKeyController.text = widget.initialAnonKey ?? '';
  }

  @override
  void didUpdateWidget(covariant SupabaseConnectionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers when initial values change (e.g., after async load)
    if (widget.initialUrl != null && widget.initialUrl != oldWidget.initialUrl) {
      _urlController.text = widget.initialUrl!;
    }
    if (widget.initialAnonKey != null && widget.initialAnonKey != oldWidget.initialAnonKey) {
      _anonKeyController.text = widget.initialAnonKey!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_urlController.text.trim(), _anonKeyController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Supabase URL',
              hintText: 'https://your-project.supabase.co',
              prefixIcon: Icon(Icons.link),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Supabase URL';
              }
              if (!value.startsWith('http://') && !value.startsWith('https://')) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _anonKeyController,
            decoration: const InputDecoration(
              labelText: 'Supabase Anon Key',
              hintText: 'Your anon/public key',
              prefixIcon: Icon(Icons.vpn_key),
            ),
            obscureText: false,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Supabase Anon Key';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Connection'),
          ),
        ],
      ),
    );
  }
}

