import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/driver/driver_providers.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../widgets/driver_job_list_item.dart';

@RoutePage()
class DriverJobHistoryPage extends ConsumerWidget {
  const DriverJobHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final jobs = ref
        .watch(driverJobsProvider)
        .where((job) => job.isCompleted)
        .toList();

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 18.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(CupertinoIcons.chevron_back),
                  ),
                  Expanded(
                    child: Text(
                      'JOB HISTORY',
                      style: styles.titleMedium.copyWith(
                        fontSize: 16.sp,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Completed jobs and uploaded proof of delivery',
                  style: styles.bodySmall,
                ),
              ),
            ),
            Expanded(
              child: jobs.isEmpty
                  ? Center(
                      child: Text(
                        'No completed jobs yet',
                        style: styles.bodySmall,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                      itemCount: jobs.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final job = jobs[index];
                        return DriverJobListItem(
                          job: job,
                          styles: styles,
                          onTap: () => context.router.push(
                            DriverJobDetailRoute(jobId: job.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
