import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus_360/presentation/features/tms/widgets/job_list_item.dart';

import '../../../../application/app_state/app_state_notifier_provider.dart';
import '../../../../application/auth/auth_providers.dart';
import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/dashboard/mobile_dashboard.dart';
import '../../../../domain/transport_booking/transport_booking.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final dashboardResult = ref.watch(mobileDashboardProvider);
    final recentBookingsResult = ref.watch(transportBookingsProvider(null));
    final profileResult = ref.watch(mobileUserProfileProvider);

    ref.listen(mobileUserProfileProvider, (_, next) {
      next.whenData(
        (result) => result.fold(
          (_) {},
          (profile) => ref
              .read(appStateNotifierProvider.notifier)
              .setUserProfile(profile),
        ),
      );
    });

    final profile = profileResult.when(
      data: (result) => result.fold((_) => null, (value) => value),
      loading: () => null,
      error: (_, _) => null,
    );
    final recentBookings =
        recentBookingsResult.asData?.value.fold(
          (_) => const <TransportBooking>[],
          (page) => page.content.take(3).toList(),
        ) ??
        const <TransportBooking>[];

    return dashboardResult.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Could not load dashboard'))),
      data: (result) => result.fold(
        (failure) => Scaffold(body: Center(child: Text(failure.message))),
        (dashboard) => Scaffold(
          backgroundColor: TmsColors.canvas,
          body: Column(
            children: [
              _dashboardHeader(
                styles: styles,
                name: profile?.companies.isNotEmpty == true
                    ? profile!.companies.first.name
                    : profile?.username ?? 'Nexus360',
                department: profile?.department ?? 'TRANSPORTER',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(mobileDashboardProvider);
                    ref.invalidate(transportBookingsProvider(null));
                    await ref.read(mobileDashboardProvider.future);
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 100.h),
                    children: [
                      Row(
                        children: [
                          _metric(
                            dashboard.transportBookings.onGoing.toString(),
                            'OPEN JOBS',
                            TmsColors.ink,
                            styles,
                            onTap: () =>
                                context.router.push(AllJobRequestsRoute()),
                          ),
                          SizedBox(width: 13.w),
                          _metric(
                            dashboard.transportBookings.completed.toString(),
                            'COMPLETED',
                            TmsColors.green,
                            styles,
                            onTap: () => context.router.push(
                              AllJobRequestsRoute(initialFilter: '8'),
                            ),
                          ),
                          SizedBox(width: 13.w),
                          _metric(
                            dashboard.transportBookings.pending.toString(),
                            'PENDING',
                            TmsColors.orange,
                            styles,
                            onTap: () => context.router.push(
                              AllJobRequestsRoute(initialFilter: '1'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _additionalDashboardStats(dashboard, styles),
                      SizedBox(height: 18.h),
                      _summaryCard(
                        styles,
                        onTap: () =>
                            context.router.push(const JobSummaryRoute()),
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
                      if (recentBookingsResult.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (recentBookings.isEmpty)
                        _noRecentBookings(styles)
                      else
                        ...recentBookings.map(
                          (booking) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: TransportBookingListItem(
                              booking: booking,
                              styles: styles,
                              onTap: () => context.router.push(
                                JobDetailRoute(
                                  jobId: booking.transportBookingSeq,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _newJobButton(context, styles),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _dashboardHeader({
  required dynamic styles,
  required String name,
  required String department,
}) => Container(
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
                  'MOBILE DASHBOARD',
                  style: styles.bodySmall.copyWith(
                    color: TmsColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  name,
                  style: styles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 11.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h.toDouble(),
                        decoration: const BoxDecoration(
                          color: TmsColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        department,
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
            height: 62.h.toDouble(),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1D232D),
              border: Border.all(color: const Color(0xFF2E3540), width: 2),
            ),
            child: Text(
              _initials(name),
              style: styles.titleMedium.copyWith(
                color: const Color(0xFFC8CCD1),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
);

Widget _additionalDashboardStats(MobileDashboard dashboard, dynamic styles) =>
    Row(
      children: [
        _smallStat(
          'Cancelled',
          dashboard.transportBookings.cancelled.toString(),
          TmsColors.red,
          styles,
        ),
        SizedBox(width: 8.w),
        _smallStat(
          'Pending invoice',
          dashboard.pendingToInvoice.count.toString(),
          TmsColors.blue,
          styles,
        ),
        SizedBox(width: 8.w),
        _smallStat(
          'Pending EV',
          dashboard.pendingToEv.count.toString(),
          TmsColors.gold,
          styles,
        ),
        SizedBox(width: 8.w),
        _smallStat(
          'Expense vouchers',
          '${dashboard.expenseVouchers.count}',
          TmsColors.orange,
          styles,
          subtitle: dashboard.expenseVouchers.value.toStringAsFixed(2),
        ),
      ],
    );

Widget _smallStat(
  String label,
  String value,
  Color color,
  dynamic styles, {
  String? subtitle,
}) => Expanded(
  child: Container(
    height: 62.h.toDouble(),
    padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: TmsColors.line),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: styles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subtitle != null)
          Text(subtitle, style: styles.labelSmall.copyWith(fontSize: 8.sp)),
        const Spacer(),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.labelSmall.copyWith(fontSize: 7.sp, letterSpacing: .4),
        ),
      ],
    ),
  ),
);

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
            height: 38.h.toDouble(),
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

Widget _noRecentBookings(dynamic styles) => Padding(
  padding: EdgeInsets.symmetric(vertical: 24.h),
  child: Center(child: Text('No recent job requests', style: styles.bodySmall)),
);

Widget _newJobButton(BuildContext context, dynamic styles) => Container(
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
    height: 42.h.toDouble(),
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
        height: 72.h.toDouble(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 12.h),
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

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words.take(2).map((word) => word.isEmpty ? '' : word[0]).join();
}
