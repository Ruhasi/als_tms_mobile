class CreateTransportBookingRequest {
  const CreateTransportBookingRequest({
    required this.departmentSeq,
    required this.customerSeq,
    required this.shipperSeq,
    required this.invoiceCustomerSeq,
    required this.invoiceStatus,
    required this.vehicleTypeSeq,
    required this.pickupLocationSeq,
    required this.pickupLocationAddress,
    required this.requestedArrivalTime,
    required this.deliveryLocationSeq,
    required this.deliveryLocationAddress,
    required this.requestedDeliveryTime,
    required this.paymentMode,
    required this.cashOrCredit,
    required this.comments,
    this.viaLocations = const [],
    this.vehicleAssignment,
  });

  final int departmentSeq;
  final int customerSeq;
  final int shipperSeq;
  final int invoiceCustomerSeq;
  final int invoiceStatus;
  final int vehicleTypeSeq;
  final DateTime requestedArrivalTime;
  final int pickupLocationSeq;
  final String pickupLocationAddress;
  final int deliveryLocationSeq;
  final String deliveryLocationAddress;
  final DateTime requestedDeliveryTime;
  final int paymentMode;
  final int cashOrCredit;
  final String comments;
  final List<ViaLocationRequest> viaLocations;
  final CreateVehicleAssignmentRequest? vehicleAssignment;

  Map<String, dynamic> toJson() => {
    'departmentSeq': departmentSeq,
    'customerSeq': customerSeq,
    'shipperSeq': shipperSeq,
    'invoiceCustomerSeq': invoiceCustomerSeq,
    'invoiceStatus': invoiceStatus,
    'vehicleTypeSeq': vehicleTypeSeq,
    'pickupLocationSeq': pickupLocationSeq,
    'requestedArrivalTime': _formatDateTime(requestedArrivalTime),
    'deliveryLocationSeq': deliveryLocationSeq,
    'requestedDeliveryTime': _formatDateTime(requestedDeliveryTime),
    'pickupLocationAddress': pickupLocationAddress,
    'deliveryLocationAddress': deliveryLocationAddress,
    'paymentMode': paymentMode,
    'cashOrCredit': cashOrCredit,
    'comments': comments,
    'viaLocations': viaLocations.map((location) => location.toJson()).toList(),
    'vehicleAssignment': vehicleAssignment?.toJson(),
  };
}

class CreateVehicleAssignmentRequest {
  const CreateVehicleAssignmentRequest({
    required this.transportCompanySeq,
    required this.vehicleSeq,
    required this.driverSeq,
    this.helperSeq,
    this.secondaryDriverSeq,
    this.secondaryHelperSeq,
    this.trailerSeq,
    this.payableVehicleTypeSeq,
    this.gpsTerminalKey = '',
    this.remarks = 'Assigned via mobile app',
  });

  final int transportCompanySeq;
  final int vehicleSeq;
  final int driverSeq;
  final int? helperSeq;
  final int? secondaryDriverSeq;
  final int? secondaryHelperSeq;
  final int? trailerSeq;
  final int? payableVehicleTypeSeq;
  final String gpsTerminalKey;
  final String remarks;

  Map<String, dynamic> toJson() => {
    'transportCompanySeq': transportCompanySeq,
    'vehicleSeq': vehicleSeq,
    'driverSeq': driverSeq,
    'helperSeq': helperSeq,
    'secondaryDriverSeq': secondaryDriverSeq,
    'secondaryHelperSeq': secondaryHelperSeq,
    'trailerSeq': trailerSeq,
    'payableVehicleTypeSeq': payableVehicleTypeSeq,
    'gpsTerminalKey': gpsTerminalKey,
    'remarks': remarks,
  };
}

class ViaLocationRequest {
  const ViaLocationRequest({
    required this.viaLocationSeq,
    required this.locationName,
    required this.viaLocationAddress,
    required this.unloadingOrder,
    required this.requestedArrivalTime,
    required this.referenceNo,
    required this.contactPerson,
    required this.contactNo,
    this.pieces,
    this.cbm,
    this.volume,
    this.weight,
    this.packageTypeSeq,
    this.uovSeq,
    this.uowSeq,
  });

  final int viaLocationSeq;
  final String locationName;
  final String viaLocationAddress;
  final int unloadingOrder;
  final DateTime requestedArrivalTime;
  final String referenceNo;
  final String contactPerson;
  final String contactNo;
  final int? pieces;
  final double? cbm;
  final double? volume;
  final double? weight;
  final int? packageTypeSeq;
  final int? uovSeq;
  final int? uowSeq;

  Map<String, dynamic> toJson() => {
    'viaLocationSeq': viaLocationSeq,
    'viaLocationAddress': viaLocationAddress,
    'unloadingOrder': unloadingOrder,
    'requestedArrivalTime': _formatDateTime(requestedArrivalTime),
    'dropPickStatus': 1,
    if (referenceNo.isNotEmpty) 'referenceNo': referenceNo,
    if (contactPerson.isNotEmpty) 'contactPerson': contactPerson,
    if (contactNo.isNotEmpty) 'contactNo': contactNo,
    if (pieces != null) 'pieces': pieces,
    if (cbm != null) 'cbm': cbm,
    if (volume != null) 'volume': volume,
    if (weight != null) 'weight': weight,
    if (packageTypeSeq != null) 'packageTypeSeq': packageTypeSeq,
    if (uovSeq != null) 'uovSeq': uovSeq,
    if (uowSeq != null) 'uowSeq': uowSeq,
  };

  ViaLocationRequest withUnloadingOrder(int value) => ViaLocationRequest(
    viaLocationSeq: viaLocationSeq,
    locationName: locationName,
    viaLocationAddress: viaLocationAddress,
    unloadingOrder: value,
    requestedArrivalTime: requestedArrivalTime,
    referenceNo: referenceNo,
    contactPerson: contactPerson,
    contactNo: contactNo,
    pieces: pieces,
    cbm: cbm,
    volume: volume,
    weight: weight,
    packageTypeSeq: packageTypeSeq,
    uovSeq: uovSeq,
    uowSeq: uowSeq,
  );
}

String _formatDateTime(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
