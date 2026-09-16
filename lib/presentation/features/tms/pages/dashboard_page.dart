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

    Future<void> logout() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Log out?'),
          content: const Text('You will need to sign in again to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Log out'),
            ),
          ],
        ),
      );
      if (!context.mounted || confirmed != true) return;

      final refreshToken = await ref
          .read(sessionStorageProvider)
          .readRefreshToken();
      if (!context.mounted) return;
      if (refreshToken == null || refreshToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your sign-in session has expired.')),
        );
        return;
      }
      final result = await ref
          .read(authRepositoryProvider)
          .logout(refreshToken: refreshToken);
      if (!context.mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message))),
        (_) async {
          await ref.read(sessionStorageProvider).clear();
          ref.read(appStateNotifierProvider.notifier).clearSession();
          ref.invalidate(mobileUserProfileProvider);
          ref.invalidate(mobileDashboardProvider);
          ref.invalidate(transportBookingsProvider(null));
          if (context.mounted) context.router.replaceAll([const SignInRoute()]);
        },
      );
    }

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
                    : profile?.username ?? 'Nexus360fleet',
                department: profile?.department ?? 'TRANSPORTER',
                onLogout: logout,
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
                      _dashboardStatusCounts(
                        context,
                        dashboard.statusCounts,
                        styles,
                      ),
                      SizedBox(height: 12.h),
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
  required VoidCallback onLogout,
}) => Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 19.h),
  color: TmsColors.ink,
  child: Column(
    children: [
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
                  style: styles.headlineSmall20.copyWith(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onLogout,
                tooltip: 'Log out',
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
    ],
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

Widget _dashboardStatusCounts(
  BuildContext context,
  List<DashboardStatusCount> statusCounts,
  dynamic styles,
) => LayoutBuilder(
  builder: (_, constraints) {
    final cardWidth = (constraints.maxWidth - (12.w * 2)) / 3;
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: statusCounts
          .map(
            (status) => SizedBox(
              width: cardWidth,
              child: _metric(
                status.count.toString(),
                status.label,
                _statusColor(status.bucket),
                styles,
                onTap: () => context.router.push(
                  AllJobRequestsRoute(
                    initialFilter: _filterForBucket(status.bucket),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  },
);

Widget _metric(
  String value,
  String label,
  Color color,
  dynamic styles, {
  VoidCallback? onTap,
}) => Material(
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
          BoxShadow(color: Colors.black.withValues(alpha: .025), blurRadius: 5),
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
            label.toUpperCase(),
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
);

Color _statusColor(String bucket) => switch (bucket.toUpperCase()) {
  'PENDING' => TmsColors.orange,
  'COMPLETED' => TmsColors.green,
  'CANCELLED' => TmsColors.red,
  _ => TmsColors.ink,
};

String? _filterForBucket(String bucket) => switch (bucket.toUpperCase()) {
  'PENDING' => '1',
  'COMPLETED' => '8',
  'CANCELLED' => '101',
  _ => null,
};

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words.take(2).map((word) => word.isEmpty ? '' : word[0]).join();
}
