class TransportBooking {
  const TransportBooking({
    required this.transportBookingSeq,
    required this.bookingNo,
    required this.customerReferenceNo,
    required this.pickupLocationAddress,
    required this.deliveryLocationAddress,
    required this.requestedArrivalTime,
    required this.requestedDeliveryTime,
    required this.currentStatus,
    required this.vehicleTypeSeq,
  });

  final int transportBookingSeq;
  final String bookingNo;
  final String customerReferenceNo;
  final String pickupLocationAddress;
  final String deliveryLocationAddress;
  final String requestedArrivalTime;
  final String requestedDeliveryTime;
  final int currentStatus;
  final int? vehicleTypeSeq;

  factory TransportBooking.fromJson(Map<String, dynamic> json) {
    return TransportBooking(
      transportBookingSeq: _asInt(json['transportBookingSeq']),
      bookingNo: json['bookingNo'] as String? ?? '',
      customerReferenceNo: json['customerReferenceNo'] as String? ?? '',
      pickupLocationAddress: json['pickupLocationAddress'] as String? ?? '',
      deliveryLocationAddress: json['deliveryLocationAddress'] as String? ?? '',
      requestedArrivalTime: json['requestedArrivalTime'] as String? ?? '',
      requestedDeliveryTime: json['requestedDeliveryTime'] as String? ?? '',
      currentStatus: _asInt(json['currentStatus']),
      vehicleTypeSeq: _asNullableInt(json['vehicleTypeSeq']),
    );
  }
}

class TransportBookingsPage {
  const TransportBookingsPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<TransportBooking> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory TransportBookingsPage.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List? ?? const [];
    return TransportBookingsPage(
      content: content
          .map(
            (item) => TransportBooking.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: _asInt(json['page']),
      size: _asInt(json['size']),
      totalElements: _asInt(json['totalElements']),
      totalPages: _asInt(json['totalPages']),
    );
  }
}

int _asInt(Object? value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  String value => int.tryParse(value) ?? 0,
  _ => 0,
};

int? _asNullableInt(Object? value) => value == null ? null : _asInt(value);

class TransportBookingDetail {
  const TransportBookingDetail({
    required this.transportBookingSeq,
    required this.companyProfileSeq,
    required this.departmentSeq,
    required this.moduleSeq,
    required this.customerSeq,
    required this.shipperSeq,
    required this.invoiceCustomerSeq,
    required this.jobSeq,
    required this.vehicleTypeSeq,
    required this.pickupLocationSeq,
    required this.deliveryLocationSeq,
    required this.bookingNo,
    required this.companyProfileName,
    required this.departmentName,
    required this.moduleName,
    required this.customerName,
    required this.shipperName,
    required this.jobNo,
    required this.customerReferenceNo,
    required this.vehicleTypeName,
    required this.pickupLocationName,
    required this.pickupLocationAddress,
    required this.deliveryLocationName,
    required this.deliveryLocationAddress,
    required this.requestedArrivalTime,
    required this.requestedDeliveryTime,
    required this.currentStatus,
    required this.currentStatusDescription,
    required this.isFlagged,
    required this.viaLocations,
    required this.invoiceStatus,
    required this.paymentMode,
    required this.cashOrCredit,
    required this.paymentModeDescription,
    required this.cashOrCreditDescription,
    required this.invoiceStatusDescription,
    required this.pieces,
    required this.weight,
    required this.volume,
    required this.cbm,
    required this.createdDate,
    required this.createdBy,
    required this.lastModifiedDate,
  });

  final int transportBookingSeq;
  final int companyProfileSeq;
  final int departmentSeq;
  final int moduleSeq;
  final int customerSeq;
  final int shipperSeq;
  final int invoiceCustomerSeq;
  final int jobSeq;
  final int vehicleTypeSeq;
  final int pickupLocationSeq;
  final int deliveryLocationSeq;
  final String bookingNo;
  final String companyProfileName;
  final String departmentName;
  final String moduleName;
  final String customerName;
  final String shipperName;
  final String jobNo;
  final String customerReferenceNo;
  final String vehicleTypeName;
  final String pickupLocationName;
  final String pickupLocationAddress;
  final String deliveryLocationName;
  final String deliveryLocationAddress;
  final String requestedArrivalTime;
  final String requestedDeliveryTime;
  final int currentStatus;
  final String currentStatusDescription;
  final bool isFlagged;
  final List<ViaLocationDetail> viaLocations;
  final int invoiceStatus;
  final int paymentMode;
  final int cashOrCredit;
  final String paymentModeDescription;
  final String cashOrCreditDescription;
  final String invoiceStatusDescription;
  final int pieces;
  final double weight;
  final double volume;
  final double cbm;
  final String createdDate;
  final String createdBy;
  final String lastModifiedDate;

  factory TransportBookingDetail.fromJson(Map<String, dynamic> json) =>
      TransportBookingDetail(
        transportBookingSeq: _asInt(json['transportBookingSeq']),
        companyProfileSeq: _asInt(json['companyProfileSeq']),
        departmentSeq: _asInt(json['departmentSeq']),
        moduleSeq: _asInt(json['moduleSeq']),
        customerSeq: _asInt(json['customerSeq']),
        shipperSeq: _asInt(json['shipperSeq']),
        invoiceCustomerSeq: _asInt(json['invoiceCustomerSeq']),
        jobSeq: _asInt(json['jobSeq']),
        vehicleTypeSeq: _asInt(json['vehicleTypeSeq']),
        pickupLocationSeq: _asInt(json['pickupLocationSeq']),
        deliveryLocationSeq: _asInt(json['deliveryLocationSeq']),
        bookingNo: _text(json['bookingNo']),
        companyProfileName: _text(json['companyProfileName']),
        departmentName: _text(json['departmentName']),
        moduleName: _text(json['moduleName']),
        customerName: _text(json['customerName']),
        shipperName: _text(json['shipperName']),
        jobNo: _text(json['jobNo']),
        customerReferenceNo: _text(json['customerReferenceNo']),
        vehicleTypeName: _text(json['vehicleTypeName']),
        pickupLocationName: _text(json['pickupLocationName']),
        pickupLocationAddress: _text(json['pickupLocationAddress']),
        deliveryLocationName: _text(json['deliveryLocationName']),
        deliveryLocationAddress: _text(json['deliveryLocationAddress']),
        requestedArrivalTime: _text(json['requestedArrivalTime']),
        requestedDeliveryTime: _text(json['requestedDeliveryTime']),
        currentStatus: _asInt(json['currentStatus']),
        currentStatusDescription: _text(json['currentStatusDescription']),
        isFlagged: _isJobFlagged(
          json['jobFlag'] ?? json['isFlagged'] ?? json['isFlaged'],
        ),
        viaLocations: (json['viaLocations'] as List? ?? const [])
            .map(
              (item) =>
                  ViaLocationDetail.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        invoiceStatus: _asInt(json['invoiceStatus']),
        paymentMode: _asInt(json['paymentMode']),
        cashOrCredit: _asInt(json['cashOrCredit']),
        paymentModeDescription: _text(json['paymentModeDescription']),
        cashOrCreditDescription: _text(json['cashOrCreditDescription']),
        invoiceStatusDescription: _text(json['invoiceStatusDescription']),
        pieces: _asInt(json['pieces']),
        weight: _asDouble(json['weight']),
        volume: _asDouble(json['volume']),
        cbm: _asDouble(json['cbm']),
        createdDate: _text(json['createdDate']),
        createdBy: _text(json['createdBy']),
        lastModifiedDate: _text(json['lastModifiedDate']),
      );
}

class ViaLocationDetail {
  const ViaLocationDetail({
    required this.viaLocationName,
    required this.viaLocationAddress,
    required this.unloadingOrder,
    required this.requestedArrivalTime,
    required this.referenceNo,
    required this.contactPerson,
    required this.contactNo,
    required this.dropPickStatus,
    required this.dropPickStatusDescription,
    required this.pieces,
    required this.cbm,
    required this.volume,
    required this.weight,
    required this.packageTypeName,
    required this.volumeUnitName,
    required this.weightUnitName,
  });

  final String viaLocationName;
  final String viaLocationAddress;
  final int unloadingOrder;
  final String requestedArrivalTime;
  final String referenceNo;
  final String contactPerson;
  final String contactNo;
  final int dropPickStatus;
  final String dropPickStatusDescription;
  final int? pieces;
  final double? cbm;
  final double? volume;
  final double? weight;
  final String packageTypeName;
  final String volumeUnitName;
  final String weightUnitName;

  factory ViaLocationDetail.fromJson(Map<String, dynamic> json) =>
      ViaLocationDetail(
        viaLocationName: _text(json['viaLocationName'] ?? json['locationName']),
        viaLocationAddress: _text(json['viaLocationAddress']),
        unloadingOrder: _asInt(json['unloadingOrder']),
        requestedArrivalTime: _text(json['requestedArrivalTime']),
        referenceNo: _text(json['referenceNo']),
        contactPerson: _text(json['contactPerson']),
        contactNo: _text(json['contactNo']),
        dropPickStatus: _asInt(json['dropPickStatus']),
        dropPickStatusDescription: _text(json['dropPickStatusDescription']),
        pieces: _asNullableInt(json['pieces']),
        cbm: _asNullableDouble(json['cbm']),
        volume: _asNullableDouble(json['volume']),
        weight: _asNullableDouble(json['weight']),
        packageTypeName: _text(json['packageTypeName'] ?? json['packageType']),
        volumeUnitName: _text(
          json['uovName'] ?? json['volumeUnitName'] ?? json['volumeUnit'],
        ),
        weightUnitName: _text(
          json['uowName'] ?? json['weightUnitName'] ?? json['weightUnit'],
        ),
      );
}

String _text(Object? value) => value?.toString() ?? '';

double _asDouble(Object? value) => switch (value) {
  double value => value,
  num value => value.toDouble(),
  String value => double.tryParse(value) ?? 0,
  _ => 0,
};

double? _asNullableDouble(Object? value) =>
    value == null ? null : _asDouble(value);

bool _isJobFlagged(Object? value) => switch (value) {
  String value =>
    value.toLowerCase() == 'flag' || value.toLowerCase() == 'flagged',
  _ => _asBool(value),
};

bool _asBool(Object? value) => switch (value) {
  bool value => value,
  num value => value != 0,
  String value => value.toLowerCase() == 'true' || value == '1',
  _ => false,
};
