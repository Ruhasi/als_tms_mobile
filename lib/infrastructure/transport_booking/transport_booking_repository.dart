import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/create_transport_booking_request.dart';
import '../../domain/transport_booking/lookup_item.dart';
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

  Future<Either<NetworkFailure, void>> updateSchedule({
    required TransportBookingDetail booking,
    required LookupItem department,
    required LookupItem customer,
    required LookupItem shipper,
    required LookupItem invoiceCustomer,
    required int invoiceStatus,
    required LookupItem vehicleType,
    required LookupItem pickupLocation,
    required String requestedArrivalTime,
    required LookupItem deliveryLocation,
    required String requestedDeliveryTime,
  }) async {
    final result = await _api.request<void>(
      path: '$_path/${booking.transportBookingSeq}',
      method: HttpMethod.put,
      data: {
        'departmentSeq': department.seq,
        'customerSeq': customer.seq,
        'shipperSeq': shipper.seq,
        'invoiceCustomerSeq': invoiceCustomer.seq,
        'invoiceStatus': invoiceStatus,
        'vehicleTypeSeq': vehicleType.seq,
        'pickupLocationSeq': pickupLocation.seq,
        'requestedArrivalTime': requestedArrivalTime,
        'deliveryLocationSeq': deliveryLocation.seq,
        'requestedDeliveryTime': requestedDeliveryTime,
        'pickupLocationAddress': pickupLocation.name,
        'deliveryLocationAddress': deliveryLocation.name,
        'paymentMode': booking.paymentMode,
        'cashOrCredit': booking.cashOrCredit,
      },
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, void>> deleteBooking(
    int transportBookingSeq,
  ) async {
    final result = await _api.request<void>(
      path: '$_path/$transportBookingSeq',
      method: HttpMethod.delete,
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, void>> addViaLocations({
    required int transportBookingSeq,
    required List<ViaLocationRequest> viaLocations,
  }) async {
    final result = await _api.request<void>(
      path: '$_path/$transportBookingSeq/via-locations',
      method: HttpMethod.post,
      data: {
        'viaLocations': viaLocations
            .map((location) => location.toJson())
            .toList(),
      },
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, void>> deleteViaLocations(
    int transportBookingSeq,
  ) async {
    final result = await _api.request<void>(
      path: '$_path/$transportBookingSeq/via-locations',
      method: HttpMethod.delete,
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
