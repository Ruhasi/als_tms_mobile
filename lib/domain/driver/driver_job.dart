enum DriverStop { pickup, delivery }

enum DriverJobStage {
  assigned,
  navigatingPickup,
  arrivedPickup,
  navigatingDelivery,
  arrivedDelivery,
  completed,
}

class GeoLocation {
  const GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;
}

class ProofOfDeliveryImage {
  const ProofOfDeliveryImage({
    required this.id,
    required this.label,
    required this.uploadedAt,
  });

  final String id;
  final String label;
  final DateTime uploadedAt;
}

class DriverJob {
  const DriverJob({
    required this.id,
    required this.bookingNo,
    required this.customer,
    required this.pickupName,
    required this.pickupAddress,
    required this.deliveryName,
    required this.deliveryAddress,
    required this.requestedArrivalTime,
    required this.requestedDeliveryTime,
    required this.vehicleNo,
    required this.isToday,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.stage,
    this.proofs = const [],
  });

  final int id;
  final String bookingNo;
  final String customer;
  final String pickupName;
  final String pickupAddress;
  final String deliveryName;
  final String deliveryAddress;
  final String requestedArrivalTime;
  final String requestedDeliveryTime;
  final String vehicleNo;
  final bool isToday;
  final GeoLocation pickupLocation;
  final GeoLocation deliveryLocation;
  final DriverJobStage stage;
  final List<ProofOfDeliveryImage> proofs;

  bool get isCompleted => stage == DriverJobStage.completed;
  bool get hasArrivedPickup =>
      stage.index >= DriverJobStage.arrivedPickup.index;
  bool get hasArrivedDelivery =>
      stage.index >= DriverJobStage.arrivedDelivery.index;
  bool get canUploadProof =>
      hasArrivedDelivery && !isCompleted;

  String get stageLabel => switch (stage) {
    DriverJobStage.assigned => 'Assigned',
    DriverJobStage.navigatingPickup => 'To pickup',
    DriverJobStage.arrivedPickup => 'At pickup',
    DriverJobStage.navigatingDelivery => 'To delivery',
    DriverJobStage.arrivedDelivery => 'At delivery',
    DriverJobStage.completed => 'Completed',
  };

  DriverJob copyWith({
    DriverJobStage? stage,
    List<ProofOfDeliveryImage>? proofs,
  }) => DriverJob(
    id: id,
    bookingNo: bookingNo,
    customer: customer,
    pickupName: pickupName,
    pickupAddress: pickupAddress,
    deliveryName: deliveryName,
    deliveryAddress: deliveryAddress,
    requestedArrivalTime: requestedArrivalTime,
    requestedDeliveryTime: requestedDeliveryTime,
    vehicleNo: vehicleNo,
    isToday: isToday,
    pickupLocation: pickupLocation,
    deliveryLocation: deliveryLocation,
    stage: stage ?? this.stage,
    proofs: proofs ?? this.proofs,
  );
}
