import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../domain/dashboard/mobile_dashboard.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';

enum SummaryRange { week, month, custom }

@RoutePage()
class JobSummaryPage extends HookConsumerWidget {
  const JobSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final range = useState(SummaryRange.month);
    final customFromDate = useState(
      DateTime.now().subtract(const Duration(days: 30)),
    );
    final customToDate = useState(DateTime.now());
    final selectedDates = _summaryDatesFor(
      range.value,
      customFromDate: customFromDate.value,
      customToDate: customToDate.value,
    );
    final dashboard = ref.watch(
      mobileDashboardForPeriodProvider(
        DashboardDateRange(
          fromDate: _dashboardDate(selectedDates.from),
          toDate: _dashboardDate(selectedDates.to),
        ),
      ),
    );
    final statusCounts = dashboard.when(
      data: (result) => result.fold(
        (_) => const <DashboardStatusCount>[],
        (value) => value.statusCounts,
      ),
      loading: () => const <DashboardStatusCount>[],
      error: (_, _) => const <DashboardStatusCount>[],
    );
    final total = statusCounts.fold<int>(
      0,
      (sum, status) => sum + status.count,
    );

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _summaryHeader(
              context,
              styles,
              range.value,
              (value) => range.value = value,
            ),
            Expanded(
              child: dashboard.isLoading && !dashboard.hasValue
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                      children: [
                        _dateRangeFields(
                          context,
                          styles,
                          fromDate: selectedDates.from,
                          toDate: selectedDates.to,
                          editable: range.value == SummaryRange.custom,
                          onFromChanged: (value) =>
                              customFromDate.value = value,
                          onToChanged: (value) => customToDate.value = value,
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
                          decoration: BoxDecoration(
                            color: TmsColors.ink,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL JOB REQUESTS',
                                style: styles.labelSmall.copyWith(
                                  color: const Color(0xFF9AA0A8),
                                  fontSize: 10.sp,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '$total',
                                style: styles.displaySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 44.sp,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                dashboard.hasError
                                    ? 'Unable to load booking summary'
                                    : 'Transport booking status for ${_summaryPeriodLabel(range.value)}',
                                style: styles.bodySmall.copyWith(
                                  color: const Color(0xFFB0B5BD),
                                  fontSize: 12.sp,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ...statusCounts.expand(
                          (status) => [
                            _summaryStatusCard(
                              styles,
                              label: status.label,
                              value: status.count,
                              fraction: total == 0 ? 0 : status.count / total,
                              color: _summaryStatusColor(status.bucket),
                              statuses: status.statuses,
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryHeader(
  BuildContext context,
  dynamic styles,
  SummaryRange selected,
  ValueChanged<SummaryRange> onChanged,
) {
  final title = selected == SummaryRange.week
      ? 'WEEKLY SUMMARY'
      : 'MONTHLY SUMMARY';
  final periodLabel = switch (selected) {
    SummaryRange.week => 'Last week',
    SummaryRange.month => 'Last month',
    SummaryRange.custom => 'Custom range',
  };

  return Padding(
    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
    child: Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          child: InkWell(
            onTap: () => context.router.maybePop(),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: TmsColors.line),
              ),
              child: Icon(
                CupertinoIcons.chevron_back,
                size: 18.sp,
                color: TmsColors.ink,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: styles.titleMedium.copyWith(
              fontSize: 14.sp,
              letterSpacing: .4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        PopupMenuButton<SummaryRange>(
          initialValue: selected,
          onSelected: onChanged,
          offset: Offset(0, 36.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(value: SummaryRange.week, child: Text('Last week')),
            PopupMenuItem(value: SummaryRange.month, child: Text('Last month')),
            PopupMenuItem(
              value: SummaryRange.custom,
              child: Text('Custom date range'),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                periodLabel,
                style: styles.bodySmall.copyWith(
                  color: TmsColors.muted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                CupertinoIcons.chevron_down,
                size: 12.sp,
                color: TmsColors.muted,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _summaryStatusCard(
  dynamic styles, {
  required String label,
  required int value,
  required double fraction,
  required Color color,
  List<DashboardStatusBreakdown> statuses = const [],
}) => Container(
  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: TmsColors.line),
  ),
  child: Column(
    children: [
      Row(
        children: [
          Text(
            label,
            style: styles.bodyMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            '$value',
            style: styles.titleMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(99.r),
        child: LinearProgressIndicator(
          value: fraction.clamp(0.05, 1),
          minHeight: 6.h,
          color: color,
          backgroundColor: const Color(0xFFE8E8EA),
        ),
      ),
      if (statuses.isNotEmpty) ...[
        SizedBox(height: 12.h),
        ...statuses.map(
          (status) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status.description,
                    style: styles.bodySmall.copyWith(fontSize: 12.sp),
                  ),
                ),
                Text(
                  '${status.count}',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
);

Color _summaryStatusColor(String bucket) => switch (bucket.toUpperCase()) {
  'PENDING' => TmsColors.orange,
  'COMPLETED' => TmsColors.green,
  'CANCELLED' => TmsColors.red,
  _ => TmsColors.blue,
};

({DateTime from, DateTime to}) _summaryDatesFor(
  SummaryRange range, {
  required DateTime customFromDate,
  required DateTime customToDate,
}) {
  final to = DateTime.now();
  final from = switch (range) {
    SummaryRange.week => to.subtract(const Duration(days: 6)),
    SummaryRange.month => DateTime(to.year, to.month - 1, to.day),
    SummaryRange.custom => customFromDate,
  };
  return (from: from, to: range == SummaryRange.custom ? customToDate : to);
}

Widget _dateRangeFields(
  BuildContext context,
  dynamic styles, {
  required DateTime fromDate,
  required DateTime toDate,
  required bool editable,
  required ValueChanged<DateTime> onFromChanged,
  required ValueChanged<DateTime> onToChanged,
}) => Row(
  children: [
    Expanded(
      child: _dateRangeField(
        context,
        styles,
        label: 'From date',
        value: fromDate,
        onSelected: editable ? onFromChanged : null,
        firstDate: DateTime(2020),
        lastDate: toDate,
      ),
    ),
    SizedBox(width: 10.w),
    Expanded(
      child: _dateRangeField(
        context,
        styles,
        label: 'To date',
        value: toDate,
        onSelected: editable ? onToChanged : null,
        firstDate: fromDate,
        lastDate: DateTime.now(),
      ),
    ),
  ],
);

Widget _dateRangeField(
  BuildContext context,
  dynamic styles, {
  required String label,
  required DateTime value,
  ValueChanged<DateTime>? onSelected,
  required DateTime firstDate,
  required DateTime lastDate,
}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10.r),
  child: InkWell(
    borderRadius: BorderRadius.circular(10.r),
    onTap: onSelected == null
        ? null
        : () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (date != null) onSelected(date);
          },
    child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: TmsColors.line),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: styles.labelSmall),
          SizedBox(height: 4.h),
          Text(
            _dashboardDate(value),
            style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  ),
);

String _summaryPeriodLabel(SummaryRange range) => switch (range) {
  SummaryRange.week => 'the last week',
  SummaryRange.month => 'the last month',
  SummaryRange.custom => 'the selected date range',
};

String _dashboardDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
