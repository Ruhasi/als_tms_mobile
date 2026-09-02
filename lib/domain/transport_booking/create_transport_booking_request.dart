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
  };
}

String _formatDateTime(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
