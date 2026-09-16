import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/dashboard/mobile_dashboard.dart';
import '../../infrastructure/api_helpers/api_client.dart';
import '../../infrastructure/dashboard/mobile_dashboard_repository.dart';

final mobileDashboardRepositoryProvider = Provider<MobileDashboardRepository>(
  (ref) => MobileDashboardRepository(ref.watch(apiClientProvider)),
);

final mobileDashboardProvider =
    FutureProvider<Either<NetworkFailure, MobileDashboard>>((ref) {
      final today = DateTime.now();
      return ref
          .watch(mobileDashboardRepositoryProvider)
          .getDashboard(
            fromDate: _dashboardDate(today.subtract(const Duration(days: 30))),
            toDate: _dashboardDate(today),
          );
    });

final mobileDashboardForPeriodProvider =
    FutureProvider.family<
      Either<NetworkFailure, MobileDashboard>,
      DashboardDateRange
    >(
      (ref, range) => ref
          .watch(mobileDashboardRepositoryProvider)
          .getDashboard(fromDate: range.fromDate, toDate: range.toDate),
    );

class DashboardDateRange {
  const DashboardDateRange({required this.fromDate, required this.toDate});

  final String fromDate;
  final String toDate;

  @override
  bool operator ==(Object other) =>
      other is DashboardDateRange &&
      other.fromDate == fromDate &&
      other.toDate == toDate;

  @override
  int get hashCode => Object.hash(fromDate, toDate);
}

String _dashboardDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
