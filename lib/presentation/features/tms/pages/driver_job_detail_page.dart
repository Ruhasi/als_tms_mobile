import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/driver/driver_providers.dart';
import '../../../../domain/driver/driver_job.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class DriverJobDetailPage extends ConsumerWidget {
  const DriverJobDetailPage({
    super.key,
    @PathParam('jobId') required this.jobId,
  });

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final job = ref.watch(driverJobProvider(jobId));
    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job unavailable')));
    }

    Future<void> confirmArrival(DriverStop stop) async {
      final confirmed = await showArrivalConfirmDialog(context, job, stop);
      if (confirmed != true) return;
      ref.read(driverJobsProvider.notifier).confirmArrival(job.id, stop);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stop == DriverStop.pickup
                ? 'Pickup arrival confirmed.'
                : 'Delivery arrival confirmed.',
          ),
        ),
      );
    }

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
                      'DRIVER JOB',
                      style: styles.titleMedium.copyWith(
                        fontSize: 16.sp,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: TmsColors.orange.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      job.stageLabel.toUpperCase(),
                      style: styles.labelSmall.copyWith(
                        color: TmsColors.orange,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                children: [
                  Text(
                    job.bookingNo,
                    style: styles.labelSmall.copyWith(letterSpacing: 1.2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    job.customer,
                    style: styles.titleLarge.copyWith(fontSize: 20.sp),
                  ),
                  SizedBox(height: 14.h),
                  _routeCard(job, styles),
                  SizedBox(height: 12.h),
                  _infoCard(job, styles),
                  if (!job.isCompleted) ...[
                    SizedBox(height: 16.h),
                    TmsButton(
                      label: job.hasArrivedPickup
                          ? 'Pickup arrived'
                          : 'Navigate to pickup',
                      onPressed: job.hasArrivedPickup
                          ? null
                          : () => context.router.push(
                              DriverNavigationRoute(
                                jobId: job.id,
                                stop: DriverStop.pickup.name,
                              ),
                            ),
                    ),
                    SizedBox(height: 8.h),
                    TmsButton(
                      dark: true,
                      label: job.hasArrivedDelivery
                          ? 'Delivery arrived'
                          : 'Navigate to delivery',
                      onPressed: !job.hasArrivedPickup || job.hasArrivedDelivery
                          ? null
                          : () => context.router.push(
                              DriverNavigationRoute(
                                jobId: job.id,
                                stop: DriverStop.delivery.name,
                              ),
                            ),
                    ),
                    SizedBox(height: 10.h),
                    OutlinedButton(
                      onPressed: job.hasArrivedDelivery
                          ? null
                          : job.hasArrivedPickup
                          ? () => confirmArrival(DriverStop.delivery)
                          : () => confirmArrival(DriverStop.pickup),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        foregroundColor: TmsColors.ink,
                        side: const BorderSide(color: TmsColors.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        job.hasArrivedPickup && !job.hasArrivedDelivery
                            ? 'Confirm delivery arrival manually'
                            : 'Confirm pickup arrival manually',
                        style: styles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TmsButton(
                      label: 'Upload proof of delivery',
                      onPressed: job.canUploadProof
                          ? () => context.router.push(
                              DriverPodUploadRoute(jobId: job.id),
                            )
                          : null,
                    ),
                    if (!job.canUploadProof)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          job.hasArrivedDelivery
                              ? 'Upload proof to complete this job.'
                              : 'Confirm delivery arrival before uploading proof of delivery.',
                          style: styles.bodySmall,
                        ),
                      ),
                  ] else ...[
                    SizedBox(height: 16.h),
                    Text(
                      'PROOF OF DELIVERY',
                      style: styles.labelSmall.copyWith(letterSpacing: 1.1),
                    ),
                    SizedBox(height: 8.h),
                    ...job.proofs.map(
                      (proof) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _proofTile(proof, styles),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showArrivalConfirmDialog(
  BuildContext context,
  DriverJob job,
  DriverStop stop,
) {
  final isPickup = stop == DriverStop.pickup;
  final location = isPickup ? job.pickupName : job.deliveryName;
  final radius = isPickup
      ? job.pickupLocation.radiusMeters
      : job.deliveryLocation.radiusMeters;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isPickup ? 'Arrived at pickup?' : 'Arrived at delivery?'),
      content: Text(
        'Confirm that you have arrived at $location. The expected geofence radius is $radius m.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Not yet'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Confirm arrival'),
        ),
      ],
    ),
  );
}

Widget _routeCard(DriverJob job, dynamic styles) => Container(
  padding: EdgeInsets.all(16.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: TmsColors.line),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('ROUTE', style: styles.labelSmall.copyWith(letterSpacing: 1.1)),
      SizedBox(height: 12.h),
      Text(
        job.pickupName,
        style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(job.pickupAddress, style: styles.bodySmall),
      Text(job.requestedArrivalTime, style: styles.bodySmall),
      SizedBox(height: 12.h),
      Container(width: 2.w, height: 16.h, color: TmsColors.line),
      SizedBox(height: 12.h),
      Text(
        job.deliveryName,
        style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(job.deliveryAddress, style: styles.bodySmall),
      Text(job.requestedDeliveryTime, style: styles.bodySmall),
    ],
  ),
);

Widget _infoCard(DriverJob job, dynamic styles) => Container(
  padding: EdgeInsets.all(16.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: TmsColors.line),
  ),
  child: Column(
    children: [
      _infoLine('Customer', job.customer, styles),
      _infoLine('Vehicle', job.vehicleNo, styles),
      _infoLine(
        'Pickup geofence',
        '${job.pickupLocation.radiusMeters} m',
        styles,
      ),
      _infoLine(
        'Delivery geofence',
        '${job.deliveryLocation.radiusMeters} m',
        styles,
        isLast: true,
      ),
    ],
  ),
);

Widget _infoLine(
  String label,
  String value,
  dynamic styles, {
  bool isLast = false,
}) => Padding(
  padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
  child: Row(
    children: [
      Text(label, style: styles.bodySmall),
      const Spacer(),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    ],
  ),
);

Widget _proofTile(ProofOfDeliveryImage proof, dynamic styles) => Container(
  padding: EdgeInsets.all(12.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: TmsColors.line),
  ),
  child: Row(
    children: [
      Container(
        width: 42.w,
        height: 42.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TmsColors.green.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Icon(Icons.image_outlined, color: TmsColors.green),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proof.label,
              style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              proof.uploadedAt.toString().split('.').first,
              style: styles.bodySmall,
            ),
          ],
        ),
      ),
    ],
  ),
);
