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
