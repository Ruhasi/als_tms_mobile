import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nexus_360/domain/tms/models/tms_models.dart';
import 'package:nexus_360/domain/transport_booking/transport_booking.dart';
import 'package:nexus_360/presentation/core/routing/app_router.dart';
import 'package:nexus_360/presentation/core/theme/tms_theme.dart';
import 'package:nexus_360/presentation/core/widgets/tms_widgets.dart';
import 'package:nexus_360/presentation/features/tms/widgets/vehicle_assignment_sheet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class JobListItem extends ConsumerWidget {
  const JobListItem({
    super.key,
    required this.job,
    required this.styles,
    this.onTap,
  });

  final TmsJob job;
  final dynamic styles;
  final VoidCallback? onTap;

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
        onTap:
            onTap ??
            () => context.router.push(
              JobDetailRoute(jobId: int.tryParse(job.id) ?? 0),
            ),
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
                        height: 12.h.toDouble(),
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

/// Shared live-booking card used on the dashboard and all-job-request pages.
class TransportBookingListItem extends StatelessWidget {
  const TransportBookingListItem({
    super.key,
    required this.booking,
    required this.styles,
    this.onTap,
  });

  final TransportBooking booking;
  final dynamic styles;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = _bookingStatus(booking.currentStatus);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
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
                      booking.bookingNo,
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
                      color: status.color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      status.label.toUpperCase(),
                      style: styles.labelSmall.copyWith(
                        color: status.color,
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
                          _firstAddressLine(booking.pickupLocationAddress),
                          style: styles.bodyMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _firstAddressLine(booking.deliveryLocationAddress),
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
                      booking.requestedArrivalTime,
                      style: styles.bodySmall.copyWith(fontSize: 10.sp),
                    ),
                  ),
                  Text(
                    booking.customerReferenceNo,
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

({String label, Color color}) _bookingStatus(int status) => switch (status) {
  1 => (label: 'Pending for Approval', color: TmsColors.gold),
  2 => (label: 'Approved', color: TmsColors.red),
  3 => (label: 'Accepted', color: TmsColors.orange),
  4 => (label: 'Attended', color: TmsColors.blue),
  5 => (label: 'Arrived At Pickup', color: TmsColors.gold),
  6 => (label: 'Departed From Pickup', color: TmsColors.orange),
  7 => (label: 'Arrived at Delivery', color: TmsColors.green),
  8 => (label: 'Job Completed', color: TmsColors.green),
  9 => (label: 'Km Confirmed', color: TmsColors.green),
  10 => (label: 'Charged Submitted', color: TmsColors.green),
  11 => (label: 'Job Confirmed', color: TmsColors.green),
  12 => (label: 'Finance Confirmed', color: TmsColors.green),
  13 => (label: 'Job Closed', color: TmsColors.green),
  101 => (label: 'Cancelled', color: TmsColors.muted),
  102 => (label: 'Rejected', color: TmsColors.muted),
  103 => (label: 'Job Dispute', color: TmsColors.red),
  104 => (label: 'Finance Dispute', color: TmsColors.red),
  _ => (label: 'Unknown', color: TmsColors.muted),
};

String _firstAddressLine(String address) {
  final line = address
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  return line.isEmpty ? 'Location unavailable' : line;
}
