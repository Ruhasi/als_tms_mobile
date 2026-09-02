class VehicleAssignmentRequest {
  const VehicleAssignmentRequest({
    required this.transportBookingSeq,
    required this.transportCompanySeq,
    required this.vehicleSeq,
    required this.driverSeq,
    this.helperSeq,
    this.trailerSeq,
    this.payableVehicleTypeSeq,
    this.gpsTerminalKey = '',
    this.remarks = 'Assigned via mobile app',
  });

  final int transportBookingSeq;
  final int transportCompanySeq;
  final int vehicleSeq;
  final int driverSeq;
  final int? helperSeq;
  final int? trailerSeq;
  final int? payableVehicleTypeSeq;
  final String gpsTerminalKey;
  final String remarks;

  Map<String, dynamic> toJson() => {
    'transportBookingSeq': transportBookingSeq,
    'transportCompanySeq': transportCompanySeq,
    'vehicleSeq': vehicleSeq,
    'driverSeq': driverSeq,
    'helperSeq': helperSeq,
    'trailerSeq': trailerSeq,
    'payableVehicleTypeSeq': payableVehicleTypeSeq,
    'gpsTerminalKey': gpsTerminalKey,
    'remarks': remarks,
  };
}

class VehicleAssignmentDetails {
  const VehicleAssignmentDetails({
    required this.bookingNo,
    required this.jobNo,
    required this.customerName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.requestedArrivalTime,
    required this.requestedDeliveryTime,
    required this.estimatedKm,
    required this.vehicleTypeName,
    required this.viaLocationString,
    required this.customerReferenceNo,
  });

  final String bookingNo;
  final String jobNo;
  final String customerName;
  final String pickupLocation;
  final String deliveryLocation;
  final String requestedArrivalTime;
  final String requestedDeliveryTime;
  final double estimatedKm;
  final String vehicleTypeName;
  final String viaLocationString;
  final String customerReferenceNo;

  factory VehicleAssignmentDetails.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>? ?? const {};
    return VehicleAssignmentDetails(
      bookingNo: _text(booking['bookingNo']),
      jobNo: _text(booking['jobNo']),
      customerName: _text(booking['customerName']),
      pickupLocation: _text(booking['pickupLocation']),
      deliveryLocation: _text(booking['deliveryLocation']),
      requestedArrivalTime: _text(booking['requestedArrivalTime']),
      requestedDeliveryTime: _text(booking['requestedDeliveryTime']),
      estimatedKm: _asDouble(booking['estimatedKm']),
      vehicleTypeName: _text(booking['vehicleTypeName']),
      viaLocationString: _text(booking['viaLocationString']),
      customerReferenceNo: _text(booking['customerReferenceNo']),
    );
  }
}

String _text(Object? value) => value?.toString() ?? '';

double _asDouble(Object? value) => switch (value) {
  double value => value,
  num value => value.toDouble(),
  String value => double.tryParse(value) ?? 0,
  _ => 0,
};
