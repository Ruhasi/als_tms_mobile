import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/vehicle_assignment.dart';
import '../api_helpers/api_client.dart';

class VehicleAssignmentRepository {
  const VehicleAssignmentRepository(this._api);

  final ApiClient _api;
  static const _path = '/api/v1/mobile/vehicle-assignments';

  Future<Either<NetworkFailure, void>> assign(
    VehicleAssignmentRequest request,
  ) async {
    final result = await _api.request<void>(
      path: _path,
      method: HttpMethod.post,
      data: request.toJson(),
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, VehicleAssignmentDetails>> details(
    int transportBookingSeq,
  ) async {
    final result = await _api.request<VehicleAssignmentDetails>(
      path: '$_path/$transportBookingSeq',
      decode: (json) {
        final body = json as Map<String, dynamic>;
        return VehicleAssignmentDetails.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      },
    );
    return switch (result) {
      ApiSuccess(data: final details) => right(details),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
