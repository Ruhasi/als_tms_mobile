import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';

enum SummaryRange { week, month }

@RoutePage()
class JobSummaryPage extends HookConsumerWidget {
  const JobSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final range = useState(SummaryRange.month);
    final isMonth = range.value == SummaryRange.month;
    final summary = isMonth
        ? (
            total: 55,
            comparison: '14% above July at the same point in the month',
            delivered: 34,
            inTransit: 12,
            requested: 6,
            cancelled: 3,
            onTimeRate: 92,
          )
        : (
            total: 18,
            comparison: '3 more requests than the previous seven days',
            delivered: 10,
            inTransit: 4,
            requested: 3,
            cancelled: 1,
            onTimeRate: 94,
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
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                children: [
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
                          '${summary.total}',
                          style: styles.displaySmall.copyWith(
                            color: Colors.white,
                            fontSize: 44.sp,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          summary.comparison,
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
                  _summaryStatusCard(
                    styles,
                    label: 'Delivered',
                    value: summary.delivered,
                    fraction: summary.delivered / summary.total,
                    color: TmsColors.green,
                  ),
                  SizedBox(height: 10.h),
                  _summaryStatusCard(
                    styles,
                    label: 'In transit',
                    value: summary.inTransit,
                    fraction: summary.inTransit / summary.total,
                    color: TmsColors.blue,
                  ),
                  SizedBox(height: 10.h),
                  _summaryStatusCard(
                    styles,
                    label: 'Requested',
                    value: summary.requested,
                    fraction: summary.requested / summary.total,
                    color: TmsColors.gold,
                  ),
                  SizedBox(height: 10.h),
                  _summaryStatusCard(
                    styles,
                    label: 'Cancelled',
                    value: summary.cancelled,
                    fraction: summary.cancelled / summary.total,
                    color: TmsColors.red,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: TmsColors.line),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'On-time delivery rate',
                          style: styles.bodyMedium.copyWith(
                            color: TmsColors.muted,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${summary.onTimeRate}%',
                          style: styles.titleLarge.copyWith(
                            color: TmsColors.green,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
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
  final title = selected == SummaryRange.month
      ? 'MONTHLY SUMMARY'
      : 'WEEKLY SUMMARY';
  final periodLabel = selected == SummaryRange.month
      ? 'Last month'
      : 'Last week';

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
    ],
  ),
);
