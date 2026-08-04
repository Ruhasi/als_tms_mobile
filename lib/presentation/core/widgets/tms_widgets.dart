import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../domain/tms/models/tms_models.dart';
import '../theme/tms_theme.dart';

class TmsButton extends StatelessWidget {
  const TmsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.dark = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: double.infinity,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: dark ? TmsColors.ink : TmsColors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final JobStatus status;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      JobStatus.requested => ('REQUESTED', TmsColors.gold),
      JobStatus.accepted => ('ACCEPTED', TmsColors.blue),
      JobStatus.inTransit => ('IN TRANSIT', TmsColors.blue),
      JobStatus.delivered => ('DELIVERED', TmsColors.green),
      JobStatus.cancelled => ('CANCELLED', TmsColors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class SelectorTile extends StatelessWidget {
  const SelectorTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.badge,
    this.locked = false,
  });
  final String label, value;
  final VoidCallback? onTap;
  final String? badge;
  final bool locked;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: locked ? null : onTap,
    borderRadius: BorderRadius.circular(9),
    child: Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TmsColors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: TmsColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Text(
              badge!,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: locked ? TmsColors.muted : TmsColors.orange,
              ),
            ),
          if (!locked)
            const Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: TmsColors.muted,
            ),
        ],
      ),
    ),
  );
}

Future<TmsOption?> showOptionSheet(
  BuildContext context, {
  required String title,
  required List<TmsOption> options,
}) {
  return showModalBottomSheet<TmsOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: .8,
        minChildSize: .5,
        maxChildSize: .94,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: const BoxDecoration(
            color: TmsColors.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: TmsColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
              const CupertinoSearchTextField(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: options.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = options[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      child: ListTile(
                        onTap: () => Navigator.pop(context, item),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(item.subtitle),
                        trailing: item.isAuto
                            ? const Text(
                                'AUTO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: TmsColors.orange,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
