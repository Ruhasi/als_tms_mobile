import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_template/presentation/features/tms/widgets/job_list_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
// Kept for the commented TmsButton below — remove if that CTA is deleted.
// ignore: unused_import
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final dashboard = ref.watch(dashboardProvider);
    return dashboard.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Could not load jobs'))),
      data: (data) => Scaffold(
        backgroundColor: TmsColors.canvas,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 19.h),
              color: TmsColors.ink,
              child: Column(
                children: [
                  SizedBox(height: kToolbarHeight),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tuesday, 4 August',
                              style: styles.bodySmall.copyWith(
                                color: TmsColors.textGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              data.user.name,
                              style: styles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 11.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: const BoxDecoration(
                                      color: TmsColors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'TRANSPORTER',
                                    style: styles.labelSmall.copyWith(
                                      color: Colors.white.withValues(alpha: .8),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 62.w,
                        height: 62.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1D232D),
                          border: Border.all(
                            color: const Color(0xFF2E3540),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          data.user.initials,
                          style: styles.titleMedium.copyWith(
                            color: const Color(0xFFC8CCD1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 100.h),
                children: [
                  Row(
                    children: [
                      _metric(
                        data.openJobs.toString(),
                        'OPEN JOBS',
                        TmsColors.ink,
                        styles,
                        onTap: () => context.router.push(
                          AllJobRequestsRoute(initialFilter: 'open'),
                        ),
                      ),
                      SizedBox(width: 13.w),
                      _metric(
                        data.deliveredThisMonth.toString(),
                        'DELIVERED,\n7D',
                        TmsColors.green,
                        styles,
                        onTap: () => context.router.push(
                          AllJobRequestsRoute(initialFilter: 'delivered'),
                        ),
                      ),
                      SizedBox(width: 13.w),
                      _metric(
                        data.flaggedJobs.toString(),
                        'FLAGGED',
                        TmsColors.orange,
                        styles,
                        onTap: () => context.router.push(
                          AllJobRequestsRoute(initialFilter: 'flagged'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  _summaryCard(
                    styles,
                    onTap: () => context.router.push(const JobSummaryRoute()),
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Text(
                        'RECENT JOB REQUESTS',
                        style: styles.titleMedium.copyWith(
                          fontSize: 14.sp,
                          letterSpacing: .2,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            context.router.push(AllJobRequestsRoute()),
                        child: Text(
                          'See all',
                          style: styles.bodyMedium.copyWith(
                            color: TmsColors.orange,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  ...data.jobs.map(
                    (job) => Column(
                      children: [
                        JobListItem(job: job, styles: styles),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Previous sticky CTA — restore if customer prefers the simpler look.
            // Padding(
            //   padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 15.h),
            //   child: TmsButton(
            //     label: 'New job request',
            //     onPressed: () => context.router.push(const NewJobRoute()),
            //   ),
            // ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 42.h,
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: TmsColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => context.router.push(const NewJobRoute()),
                  icon: Icon(Icons.add_rounded, size: 22.sp),
                  label: Text(
                    'New job request',
                    style: styles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryCard(dynamic styles, {required VoidCallback onTap}) => Material(
  color: TmsColors.ink,
  borderRadius: BorderRadius.circular(15.r),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15.r),
    child: Padding(
      padding: EdgeInsets.fromLTRB(17.w, 14.h, 15.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.insights_outlined,
              color: TmsColors.orange,
              size: 21.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show summary',
                  style: styles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Review last week or last month',
                  style: styles.bodySmall.copyWith(
                    color: const Color(0xFFB8BEC7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    ),
  ),
);

Widget _metric(
  String value,
  String label,
  Color color,
  dynamic styles, {
  VoidCallback? onTap,
}) => Expanded(
  child: Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 80.h,
        padding: EdgeInsets.fromLTRB(19.w, 19.h, 8.w, 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: styles.displaySmall.copyWith(
                fontSize: 30.sp,
                height: 1.0,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: styles.labelSmall.copyWith(
                fontSize: 8.sp,
                letterSpacing: 1.2,
                height: 1.25,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    ),
  ),
);
