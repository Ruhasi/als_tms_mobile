import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/core/app_failure.dart';
import '../../domain/transport_booking/transport_booking.dart';
import '../../infrastructure/api_helpers/api_client.dart';
import '../../infrastructure/transport_booking/booking_lookup_repository.dart';
import '../../infrastructure/transport_booking/transport_booking_repository.dart';
import '../../infrastructure/transport_booking/vehicle_assignment_lookup_repository.dart';
import '../../infrastructure/transport_booking/vehicle_assignment_repository.dart';

final bookingLookupRepositoryProvider = Provider<BookingLookupRepository>(
  (ref) => BookingLookupRepository(ref.watch(apiClientProvider)),
);

final transportBookingRepositoryProvider = Provider<TransportBookingRepository>(
  (ref) => TransportBookingRepository(ref.watch(apiClientProvider)),
);

final vehicleAssignmentLookupRepositoryProvider =
    Provider<VehicleAssignmentLookupRepository>(
      (ref) => VehicleAssignmentLookupRepository(ref.watch(apiClientProvider)),
    );

final vehicleAssignmentRepositoryProvider =
    Provider<VehicleAssignmentRepository>(
      (ref) => VehicleAssignmentRepository(ref.watch(apiClientProvider)),
    );

/// Retrieves the first pagination page for the currently selected status.
///
/// The selected ID is passed to the API as `currentStatus`; null returns all
/// statuses. Pagination metadata remains available on [TransportBookingsPage]
/// for a subsequent "load more" interaction.
final transportBookingsProvider =
    FutureProvider.family<Either<NetworkFailure, TransportBookingsPage>, int?>(
      (ref, currentStatus) => ref
          .watch(transportBookingRepositoryProvider)
          .getBookings(currentStatus: currentStatus),
    );

final transportBookingDetailProvider =
    FutureProvider.family<Either<NetworkFailure, TransportBookingDetail>, int>(
      (ref, transportBookingSeq) => ref
          .watch(transportBookingRepositoryProvider)
          .getBookingById(transportBookingSeq),
    );
