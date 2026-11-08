import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../domain/driver/driver_job.dart';
import '../../../core/theme/tms_theme.dart';

class DriverJobListItem extends StatelessWidget {
  const DriverJobListItem({
    super.key,
    required this.job,
    required this.styles,
    this.onTap,
  });

  final DriverJob job;
  final dynamic styles;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(job.stage);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: Colors.transparent),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.bookingNo,
                      style: styles.labelSmall.copyWith(
                        fontSize: 12.sp,
                        letterSpacing: 1.35,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      job.stageLabel.toUpperCase(),
                      style: styles.labelSmall.copyWith(
                        color: color,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
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
                        height: 12.h.toDouble(),
                        color: TmsColors.line,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 10.w,
                        height: 10.h.toDouble(),
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
                          job.pickupName,
                          style: styles.bodyMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          job.deliveryName,
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
              const Divider(height: 1, color: TmsColors.line),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.requestedArrivalTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.bodySmall.copyWith(fontSize: 10.sp),
                    ),
                  ),
                  Text(
                    job.vehicleNo,
                    style: styles.bodySmall.copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
              if (job.proofs.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  '${job.proofs.length} proof of delivery file${job.proofs.length == 1 ? '' : 's'}',
                  style: styles.labelSmall.copyWith(
                    color: TmsColors.green,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Color _stageColor(DriverJobStage stage) => switch (stage) {
  DriverJobStage.assigned => TmsColors.orange,
  DriverJobStage.navigatingPickup ||
  DriverJobStage.navigatingDelivery => TmsColors.blue,
  DriverJobStage.arrivedPickup ||
  DriverJobStage.arrivedDelivery => TmsColors.gold,
  DriverJobStage.completed => TmsColors.green,
};
