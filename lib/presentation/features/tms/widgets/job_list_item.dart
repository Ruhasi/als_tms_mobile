import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_template/domain/tms/models/tms_models.dart';
import 'package:flutter_template/presentation/core/routing/app_router.dart';
import 'package:flutter_template/presentation/core/theme/tms_theme.dart';
import 'package:flutter_template/presentation/core/widgets/tms_widgets.dart';
import 'package:flutter_template/presentation/features/tms/widgets/vehicle_assignment_sheet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class JobListItem extends ConsumerWidget {
  const JobListItem({super.key, required this.job, required this.styles});

  final TmsJob job;
  final dynamic styles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = isVehicleUnassigned(job.vehicle)
        ? 'Awaiting vehicle'
        : job.vehicle.replaceFirst(' Container Truck', '');
    return Material(
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
                        height: 12.h,
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

                        SizedBox(height: 12.h),
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
    );
  }
}
