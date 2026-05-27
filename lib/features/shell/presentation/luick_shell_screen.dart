import 'package:flutter/material.dart';

import '../../../core/config/supabase_config.dart';

class LuickShellScreen extends StatelessWidget {
  const LuickShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('luick'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Luick delivery foundation',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Phase 0 and Phase 1 are scoped to native Flutter setup, Supabase schema, RLS, seed data, and simulator verification.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      _StatusRow(
                        label: 'Flutter native shell',
                        value: 'Ready',
                        icon: Icons.phone_android,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: 'Supabase config',
                        value: SupabaseConfig.isConfigured
                            ? 'Configured'
                            : 'Waiting for dart-define values',
                        icon: Icons.storage,
                        color: SupabaseConfig.isConfigured
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;

        return Row(
          crossAxisAlignment:
              isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isCompact) const SizedBox(height: 4),
                  if (isCompact)
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            if (!isCompact)
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
