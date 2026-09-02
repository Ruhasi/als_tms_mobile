class MobileDashboard {
  const MobileDashboard({
    required this.expenseVouchers,
    required this.pendingToInvoice,
    required this.pendingToEv,
    required this.transportBookings,
    required this.monthlyCostRevenue,
    required this.customerWiseJobCount,
    required this.customerWiseRevenue,
    required this.vehicleLocations,
    required this.invoiceVsExpense,
  });

  final DashboardValue expenseVouchers;
  final DashboardCount pendingToInvoice;
  final DashboardCount pendingToEv;
  final TransportBookingSummary transportBookings;
  final List<Object?> monthlyCostRevenue;
  final List<Object?> customerWiseJobCount;
  final List<Object?> customerWiseRevenue;
  final List<Object?> vehicleLocations;
  final List<Object?> invoiceVsExpense;

  factory MobileDashboard.fromJson(Map<String, dynamic> json) =>
      MobileDashboard(
        expenseVouchers: DashboardValue.fromJson(
          json['expenseVouchers'] as Map<String, dynamic>? ?? const {},
        ),
        pendingToInvoice: DashboardCount.fromJson(
          json['pendingToInvoice'] as Map<String, dynamic>? ?? const {},
        ),
        pendingToEv: DashboardCount.fromJson(
          json['pendingToEv'] as Map<String, dynamic>? ?? const {},
        ),
        transportBookings: TransportBookingSummary.fromJson(
          json['transportBookings'] as Map<String, dynamic>? ?? const {},
        ),
        monthlyCostRevenue: List<Object?>.from(
          json['monthlyCostRevenue'] as List? ?? const [],
        ),
        customerWiseJobCount: List<Object?>.from(
          json['customerWiseJobCount'] as List? ?? const [],
        ),
        customerWiseRevenue: List<Object?>.from(
          json['customerWiseRevenue'] as List? ?? const [],
        ),
        vehicleLocations: List<Object?>.from(
          json['vehicleLocations'] as List? ?? const [],
        ),
        invoiceVsExpense: List<Object?>.from(
          json['invoiceVsExpense'] as List? ?? const [],
        ),
      );
}

class DashboardCount {
  const DashboardCount({required this.count});

  final int count;

  factory DashboardCount.fromJson(Map<String, dynamic> json) =>
      DashboardCount(count: _asInt(json['count']));
}

class DashboardValue extends DashboardCount {
  const DashboardValue({required super.count, required this.value});

  final double value;

  factory DashboardValue.fromJson(Map<String, dynamic> json) => DashboardValue(
    count: _asInt(json['count']),
    value: _asDouble(json['value']),
  );
}

class TransportBookingSummary {
  const TransportBookingSummary({
    required this.onGoing,
    required this.pending,
    required this.completed,
    required this.cancelled,
  });

  final int onGoing;
  final int pending;
  final int completed;
  final int cancelled;

  factory TransportBookingSummary.fromJson(Map<String, dynamic> json) =>
      TransportBookingSummary(
        onGoing: _asInt(json['onGoing']),
        pending: _asInt(json['pending']),
        completed: _asInt(json['completed']),
        cancelled: _asInt(json['cancelled']),
      );
}

int _asInt(Object? value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  String value => int.tryParse(value) ?? 0,
  _ => 0,
};

double _asDouble(Object? value) => switch (value) {
  double value => value,
  num value => value.toDouble(),
  String value => double.tryParse(value) ?? 0,
  _ => 0,
};
