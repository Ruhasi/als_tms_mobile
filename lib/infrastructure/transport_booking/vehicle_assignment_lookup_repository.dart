import 'package:dartz/dartz.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/lookup_item.dart';
import '../api_helpers/api_client.dart';

class VehicleAssignmentLookupRepository {
  const VehicleAssignmentLookupRepository(this._api);

  final ApiClient _api;
  static const _base = '/api/v1/mobile/vehicle-assignments/lookups';

  Future<Either<NetworkFailure, List<LookupItem>>> transporters(String query) =>
      _lookup('$_base/transporters', query);

  Future<Either<NetworkFailure, List<LookupItem>>> vehicles(
    int transporterSeq,
  ) async {
    final result = await _api.request<List<LookupItem>>(
      path: '$_base/transporters/$transporterSeq/vehicles',
      decode: (json) {
        final body = json as Map<String, dynamic>;
        final data = body['data'] as List? ?? const [];
        return data.map((item) {
          final vehicle = item as Map<String, dynamic>;
          final seq = _asInt(vehicle['seq']);
          final vehicleNo = _firstText(vehicle, const [
            'vehicleNo',
            'vehicle_no',
            'vehicleNumber',
            'registrationNo',
            'name',
          ]);
          return LookupItem(
            seq: seq,
            name: vehicleNo.isEmpty ? 'Vehicle #$seq' : vehicleNo,
            code: _firstText(vehicle, const [
              'vehicleType',
              'vehicle_type',
              'type',
              'vehicleTypeSeq',
              'vehicle_type_seq',
            ]),
          );
        }).toList();
      },
    );
    return switch (result) {
      ApiSuccess(data: final items) => right(items),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, List<LookupItem>>> drivers(
    int transporterSeq,
  ) => _lookup('$_base/transporters/$transporterSeq/drivers', '');

  Future<Either<NetworkFailure, List<LookupItem>>> helpers(
    int transporterSeq,
  ) => _lookup('$_base/transporters/$transporterSeq/helpers', '');

  Future<Either<NetworkFailure, List<LookupItem>>> secondaryDrivers(
    int transporterSeq,
  ) => _lookup('$_base/transporters/$transporterSeq/secondary-drivers', '');

  Future<Either<NetworkFailure, List<LookupItem>>> secondaryHelpers(
    int transporterSeq,
  ) => _lookup('$_base/transporters/$transporterSeq/secondary-helpers', '');

  /// Trailer response fields have not yet been finalized by the backend.
  /// The standard `seq`/`name`/`code` lookup shape is supported meanwhile.
  Future<Either<NetworkFailure, List<LookupItem>>> trailers(
    int transporterSeq,
  ) => _lookup('$_base/transporters/$transporterSeq/trailers', '');

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

int _asInt(Object? value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  String value => int.tryParse(value) ?? 0,
  _ => 0,
};

String _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}
