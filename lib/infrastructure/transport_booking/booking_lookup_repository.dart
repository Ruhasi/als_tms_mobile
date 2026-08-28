import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/create_transport_booking_request.dart';
import '../../domain/transport_booking/lookup_item.dart';
import '../api_helpers/api_client.dart';

class BookingLookupRepository {
  const BookingLookupRepository(this._api);

  final ApiClient _api;
  static const _base = '/api/v1/mobile/transport-bookings/lookups';

  Future<Either<NetworkFailure, List<LookupItem>>> customers(String query) =>
      _lookup('$_base/customers', query);
  Future<Either<NetworkFailure, List<LookupItem>>> shippers(String query) =>
      _lookup('$_base/shippers', query);
  Future<Either<NetworkFailure, List<LookupItem>>> locations(String query) =>
      _lookup('$_base/locations', query);
  Future<Either<NetworkFailure, List<LookupItem>>> vehicleTypes(
    int customerSeq,
  ) => _lookup('$_base/customers/$customerSeq/vehicle-types', '');

  Future<Either<NetworkFailure, void>> createBooking(
    CreateTransportBookingRequest request,
  ) async {
    final result = await _api.request<void>(
      path: '/api/v1/mobile/transport-bookings',
      method: HttpMethod.post,
      data: request.toJson(),
      decode: (_) {},
    );
    return switch (result) {
      ApiSuccess() => right(null),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, List<LookupItem>>> _lookup(
    String path,
    String query,
  ) async {
    final result = await _api.request<List<LookupItem>>(
      path: path,
      queryParameters: query.isEmpty ? null : {'q': query},
      decode: (json) {
        final body = json as Map<String, dynamic>;
        final data = body['data'] as List? ?? const [];
        return data
            .map((item) => LookupItem.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    return switch (result) {
      ApiSuccess(data: final items) => right(items),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
