import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/dashboard/mobile_dashboard.dart';
import '../api_helpers/api_client.dart';

class MobileDashboardRepository {
  const MobileDashboardRepository(this._api);

  final ApiClient _api;

  Future<Either<NetworkFailure, MobileDashboard>> getDashboard({
    String? fromDate,
    String? toDate,
  }) async {
    final result = await _api.request<MobileDashboard>(
      path: '/api/v1/mobile/dashboard',
      queryParameters: {'fromData': fromDate, 'toDate': toDate}
        ..removeWhere((_, value) => value == null),
      decode: (json) {
        final body = json as Map<String, dynamic>;
        return MobileDashboard.fromJson(body['data'] as Map<String, dynamic>);
      },
    );

    return switch (result) {
      ApiSuccess(data: final dashboard) => right(dashboard),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
