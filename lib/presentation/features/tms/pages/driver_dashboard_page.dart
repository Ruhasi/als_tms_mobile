import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/app_state/app_state_notifier_provider.dart';
import '../../../../application/auth/auth_providers.dart';
import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../application/driver/driver_providers.dart';
import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/auth/app_access_role.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../widgets/driver_job_list_item.dart';

enum _DriverJobTab { today, upcoming }

@RoutePage()
class DriverDashboardPage extends HookConsumerWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final tab = useState(_DriverJobTab.today);
    final jobs = ref.watch(driverJobsProvider);
    final appState = ref.watch(appStateNotifierProvider);
    final canDispatch = appState.accessRoles.canDispatch;
    final openJobs = jobs.where((job) => !job.isCompleted).toList();
    final visibleJobs = openJobs
        .where(
          (job) =>
              tab.value == _DriverJobTab.today ? job.isToday : !job.isToday,
        )
        .toList();
    final todayCount = openJobs.where((job) => job.isToday).length;
    final upcomingCount = openJobs.where((job) => !job.isToday).length;

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
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await ref
            .read(authRepositoryProvider)
            .logout(refreshToken: refreshToken);
      }
      await ref.read(sessionStorageProvider).clear();
      ref.read(appStateNotifierProvider.notifier).clearSession();
      ref.invalidate(mobileUserProfileProvider);
      ref.invalidate(mobileDashboardProvider);
      ref.invalidate(transportBookingsProvider(null));
      ref.invalidate(driverJobsProvider);
      if (context.mounted) context.router.replaceAll([const SignInRoute()]);
    }

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: Column(
        children: [
          _header(
            styles: styles,
            name: appState.signedInUsername.isEmpty
                ? 'Driver'
                : appState.signedInUsername,
            canDispatch: canDispatch,
            onBack: () => context.router.maybePop(),
            onHistory: () => context.router.push(const DriverJobHistoryRoute()),
            onLogout: logout,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 10.h),
            child: Row(
              children: [
                _tabChip(
                  styles,
                  label: 'Today ($todayCount)',
                  selected: tab.value == _DriverJobTab.today,
                  onTap: () => tab.value = _DriverJobTab.today,
                ),
                SizedBox(width: 8.w),
                _tabChip(
                  styles,
                  label: 'Upcoming ($upcomingCount)',
                  selected: tab.value == _DriverJobTab.upcoming,
                  onTap: () => tab.value = _DriverJobTab.upcoming,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 8.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tab.value == _DriverJobTab.today
                    ? 'Assigned jobs for today'
                    : 'Jobs scheduled after today',
                style: styles.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: visibleJobs.isEmpty
                ? Center(
                    child: Text(
                      tab.value == _DriverJobTab.today
                          ? 'No assigned jobs for today'
                          : 'No upcoming jobs',
                      style: styles.bodySmall,
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                    itemCount: visibleJobs.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) {
                      final job = visibleJobs[index];
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
    );
  }
}

Widget _header({
  required dynamic styles,
  required String name,
  required bool canDispatch,
  required VoidCallback onBack,
  required VoidCallback onHistory,
  required VoidCallback onLogout,
}) => Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 18.h),
  color: TmsColors.ink,
  child: SafeArea(
    bottom: false,
    child: Row(
      children: [
        if (canDispatch)
          IconButton(
            onPressed: onBack,
            icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white),
          )
        else
          IconButton(
            onPressed: onLogout,
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DRIVER DASHBOARD',
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
            ],
          ),
        ),
        IconButton(
          onPressed: onHistory,
          tooltip: 'Job history',
          icon: const Icon(Icons.history_rounded, color: Colors.white),
        ),
      ],
    ),
  ),
);

Widget _tabChip(
  dynamic styles, {
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) => Expanded(
  child: Material(
    color: selected ? TmsColors.orange : Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: TmsColors.line),
        ),
        child: Text(
          label.toUpperCase(),
          style: styles.labelSmall.copyWith(
            color: selected ? Colors.white : Colors.black,
            fontSize: 10.sp,
            letterSpacing: .55,
          ),
        ),
      ),
    ),
  ),
);
