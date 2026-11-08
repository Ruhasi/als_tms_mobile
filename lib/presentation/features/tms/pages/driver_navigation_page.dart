import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/driver/driver_providers.dart';
import '../../../../domain/driver/driver_job.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';
import 'driver_job_detail_page.dart';

@RoutePage()
class DriverNavigationPage extends HookConsumerWidget {
  const DriverNavigationPage({
    super.key,
    @PathParam('jobId') required this.jobId,
    @QueryParam('stop') this.stop = 'pickup',
  });

  final int jobId;
  final String stop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final job = ref.watch(driverJobProvider(jobId));
    final selectedStop = stop == DriverStop.delivery.name
        ? DriverStop.delivery
        : DriverStop.pickup;
    final remainingMeters = useState(2400);
    final promptShown = useRef(false);
    final radius = job == null
        ? 150
        : selectedStop == DriverStop.pickup
        ? job.pickupLocation.radiusMeters
        : job.deliveryLocation.radiusMeters;

    useEffect(() {
      if (job == null) return null;
      ref.read(driverJobsProvider.notifier).startNavigation(job.id, selectedStop);
      final timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
        if (remainingMeters.value <= radius) return;
        remainingMeters.value = (remainingMeters.value - 180).clamp(
          radius,
          remainingMeters.value,
        );
      });
      return timer.cancel;
    }, const []);

    useEffect(() {
      if (job == null || promptShown.value) return null;
      if (remainingMeters.value > radius) return null;
      promptShown.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        final confirmed = await showArrivalConfirmDialog(
          context,
          job,
          selectedStop,
        );
        if (confirmed == true && context.mounted) {
          ref
              .read(driverJobsProvider.notifier)
              .confirmArrival(job.id, selectedStop);
          context.router.maybePop();
        }
      });
      return null;
    }, [remainingMeters.value]);

    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job unavailable')));
    }

    final destination = selectedStop == DriverStop.pickup
        ? job.pickupName
        : job.deliveryName;
    final address = selectedStop == DriverStop.pickup
        ? job.pickupAddress
        : job.deliveryAddress;
    final insideRadius = remainingMeters.value <= radius;

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(CupertinoIcons.chevron_back),
                  ),
                  Expanded(
                    child: Text(
                      selectedStop == DriverStop.pickup
                          ? 'NAVIGATE TO PICKUP'
                          : 'NAVIGATE TO DELIVERY',
                      style: styles.titleMedium.copyWith(
                        fontSize: 15.sp,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: TmsColors.ink,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.navigation_rounded,
                          color: TmsColors.orange,
                          size: 72,
                        ),
                      ),
                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        top: 16.h,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination,
                                style: styles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                address,
                                style: styles.bodySmall.copyWith(
                                  color: const Color(0xFFB8BEC7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.h,
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insideRadius
                                    ? 'Inside ${radius}m geofence'
                                    : '${(remainingMeters.value / 1000).toStringAsFixed(1)} km remaining',
                                style: styles.titleMedium.copyWith(
                                  color: insideRadius
                                      ? TmsColors.green
                                      : TmsColors.ink,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Live location is being tracked. Arrival prompt appears inside the ${radius}m radius.',
                                style: styles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              TmsButton(
                label: insideRadius
                    ? 'Confirm arrival'
                    : 'I have arrived — confirm manually',
                onPressed: () async {
                  final confirmed = await showArrivalConfirmDialog(
                    context,
                    job,
                    selectedStop,
                  );
                  if (confirmed == true && context.mounted) {
                    ref
                        .read(driverJobsProvider.notifier)
                        .confirmArrival(job.id, selectedStop);
                    context.router.maybePop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
