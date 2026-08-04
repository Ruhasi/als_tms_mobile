import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
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
                      ),
                      SizedBox(width: 13.w),
                      _metric(
                        data.deliveredThisMonth.toString(),
                        'DELIVERED,\n7D',
                        TmsColors.green,
                        styles,
                      ),
                      SizedBox(width: 13.w),
                      _metric(
                        data.flaggedJobs.toString(),
                        'FLAGGED',
                        TmsColors.orange,
                        styles,
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
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
                            context.router.push(const WeeklyStatusRoute()),
                        child: Text(
                          'Last week',
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
                  ...data.jobs.map((job) => _jobCard(context, job, styles)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 15.h),
              child: TmsButton(
                label: 'New job request',
                onPressed: () => context.router.push(const NewJobRoute()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _metric(String value, String label, Color color, dynamic styles) =>
    Expanded(
      child: Container(
        height: 80.h,
        padding: EdgeInsets.fromLTRB(19.w, 19.h, 8.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
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
    );

Widget _jobCard(BuildContext context, TmsJob job, dynamic styles) {
  final distance = switch (job.id) {
    'JOB-4471' => '118 km',
    'JOB-4488' => '34 km',
    'JOB-4433' => '126 km',
    _ => '257 km',
  };
  final vehicle = job.status == JobStatus.requested
      ? 'Awaiting vehicle'
      : job.vehicle.replaceFirst(' Container Truck', '');
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () => context.router.push(JobDetailRoute(jobId: job.id)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    job.id,
                    style: styles.labelSmall.copyWith(
                      fontSize: 12.sp,
                      letterSpacing: 1.35,
                    ),
                  ),
                  const Spacer(),
                  StatusPill(job.status),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 14.sp,
                        color: TmsColors.muted,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 2.w,
                        height: 18.h,
                        color: TmsColors.line,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 10.w,
                        height: 10.w,
                        color: TmsColors.orange,
                      ),
                    ],
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.pickup,
                          style: styles.bodyMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          distance,
                          style: styles.bodySmall.copyWith(fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.destination,
                          style: styles.bodyMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Divider(height: 1, color: TmsColors.line),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.pickupTime,
                      style: styles.bodySmall.copyWith(fontSize: 10.sp),
                    ),
                  ),
                  Text(
                    vehicle,
                    style: styles.bodySmall.copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
