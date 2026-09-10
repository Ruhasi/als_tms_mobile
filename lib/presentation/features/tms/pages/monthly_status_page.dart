import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../domain/dashboard/mobile_dashboard.dart';
import '../../../core/theme/tms_theme.dart';

@RoutePage()
class MonthlyStatusPage extends HookConsumerWidget {
  const MonthlyStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = useState(_SummaryPeriod.lastMonth);
    final range = _rangeFor(period.value);
    final dashboard = ref.watch(mobileDashboardForPeriodProvider(range));

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      appBar: AppBar(
        title: const Text('MONTHLY SUMMARY'),
        backgroundColor: TmsColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _errorState(ref, range),
        data: (result) => result.fold(
          (_) => _errorState(ref, range),
          (data) => _summary(period, data),
        ),
      ),
    );
  }
}

Widget _summary(ValueNotifier<_SummaryPeriod> period, MobileDashboard data) {
  final bookings = data.transportBookings;
  final values = [
    bookings.onGoing,
    bookings.pending,
    bookings.completed,
    bookings.cancelled,
  ];
  final total = values.reduce((a, b) => a + b);
  final max = values.reduce((a, b) => a > b ? a : b);

  return ListView(
    padding: const EdgeInsets.all(20),
    children: [
      DropdownButtonFormField<_SummaryPeriod>(
        initialValue: period.value,
        decoration: _fieldDecoration(),
        items: _SummaryPeriod.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.label)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) period.value = value;
        },
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TmsColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL TRANSPORT BOOKINGS',
              style: TextStyle(fontSize: 9, color: Colors.white70),
            ),
            Text(
              '$total',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'BOOKING STATUS',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 12),
      _statusChartRow('Ongoing', bookings.onGoing, max, TmsColors.blue),
      _statusChartRow('Pending', bookings.pending, max, TmsColors.gold),
      _statusChartRow('Completed', bookings.completed, max, TmsColors.green),
      _statusChartRow('Cancelled', bookings.cancelled, max, TmsColors.red),
      const SizedBox(height: 24),
      const Text(
        'WORK QUEUE',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _queueCard(
              'Expense vouchers',
              data.expenseVouchers.count,
              value: data.expenseVouchers.value,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _queueCard(
              'Pending to invoice',
              data.pendingToInvoice.count,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _queueCard('Pending to EV', data.pendingToEv.count),
    ],
  );
}

Widget _statusChartRow(String label, int value, int max, Color color) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : value / max,
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: .14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 26,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

Widget _queueCard(String label, int count, {double? value}) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: TmsColors.line),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: TmsColors.muted)),
      const SizedBox(height: 6),
      Text(
        '$count',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      if (value != null)
        Text(
          'Value: ${value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 10, color: TmsColors.muted),
        ),
    ],
  ),
);

Widget _errorState(WidgetRef ref, DashboardDateRange range) => Center(
  child: TextButton.icon(
    onPressed: () => ref.invalidate(mobileDashboardForPeriodProvider(range)),
    icon: const Icon(Icons.refresh),
    label: const Text('Unable to load summary. Retry'),
  ),
);

InputDecoration _fieldDecoration() => InputDecoration(
  labelText: 'Period',
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
);

DashboardDateRange _rangeFor(_SummaryPeriod period) {
  final to = DateTime.now();
  final from = period == _SummaryPeriod.lastWeek
      ? to.subtract(const Duration(days: 6))
      : DateTime(to.year, to.month - 1, to.day);
  return DashboardDateRange(
    fromDate: _formatDate(from),
    toDate: _formatDate(to),
  );
}

String _formatDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

enum _SummaryPeriod {
  lastWeek('Last week'),
  lastMonth('Last month');

  const _SummaryPeriod(this.label);
  final String label;
}
