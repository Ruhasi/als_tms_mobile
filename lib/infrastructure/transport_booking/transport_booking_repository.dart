import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/transport_booking.dart';
import '../api_helpers/api_client.dart';

class TransportBookingRepository {
  const TransportBookingRepository(this._api);

  final ApiClient _api;
  static const _path = '/api/v1/mobile/transport-bookings';

  Future<Either<NetworkFailure, TransportBookingsPage>> getBookings({
    int? companyProfileSeq,
    int? departmentSeq,
    int? customerSeq,
    int? currentStatus,
    int? vehicleTypeSeq,
    int? pickupLocationSeq,
    int? deliveryLocationSeq,
    String? customerReferenceNo,
    String? jobNo,
    String? startDate,
    String? endDate,
    int page = 0,
    int size = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'companyProfileSeq': companyProfileSeq,
      'departmentSeq': departmentSeq,
      'customerSeq': customerSeq,
      'currentStatus': currentStatus,
      'vehicleTypeSeq': vehicleTypeSeq,
      'pickupLocationSeq': pickupLocationSeq,
      'deliveryLocationSeq': deliveryLocationSeq,
      'customerReferenceNo': customerReferenceNo?.isNotEmpty == true
          ? customerReferenceNo
          : null,
      'jobNo': jobNo?.isNotEmpty == true ? jobNo : null,
      'startDate': startDate?.isNotEmpty == true ? startDate : null,
      'endDate': endDate?.isNotEmpty == true ? endDate : null,
      'page': page,
      'size': size,
    }..removeWhere((_, value) => value == null);

    final result = await _api.request<TransportBookingsPage>(
      path: _path,
      queryParameters: queryParameters,
      decode: (json) {
        final body = json as Map<String, dynamic>;
        return TransportBookingsPage.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      },
    );

    return switch (result) {
      ApiSuccess(data: final bookings) => right(bookings),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, TransportBookingDetail>> getBookingById(
    int transportBookingSeq,
  ) async {
    final result = await _api.request<TransportBookingDetail>(
      path: '$_path/$transportBookingSeq',
      decode: (json) {
        final body = json as Map<String, dynamic>;
        return TransportBookingDetail.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      },
    );

    return switch (result) {
      ApiSuccess(data: final booking) => right(booking),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, void>> updateFlagStatus({
    required int transportBookingSeq,
    required bool isFlagged,
  }) async {
    final result = await _api.request<void>(
      path: '$_path/$transportBookingSeq/flag',
      method: HttpMethod.post,
      data: {'flag': isFlagged ? 'Flag' : 'Resolved'},
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
