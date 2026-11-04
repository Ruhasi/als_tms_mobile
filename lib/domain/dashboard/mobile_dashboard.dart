class MobileDashboard {
  const MobileDashboard({
    required this.fromDate,
    required this.toDate,
    required this.statusCounts,
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

  final String fromDate;
  final String toDate;
  final List<DashboardStatusCount> statusCounts;
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
        fromDate: _text(json['fromDate']),
        toDate: _text(json['toDate']),
        statusCounts: (json['statusCounts'] as List? ?? const [])
            .map(
              (item) =>
                  DashboardStatusCount.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        expenseVouchers: const DashboardValue(count: 0, value: 0),
        pendingToInvoice: const DashboardCount(count: 0),
        pendingToEv: const DashboardCount(count: 0),
        transportBookings: TransportBookingSummary(
          onGoing: _statusCount(json, 'OPEN_JOBS'),
          pending: _statusCount(json, 'PENDING'),
          completed: _statusCount(json, 'COMPLETED'),
          cancelled: _statusCount(json, 'CANCELLED'),
        ),
        monthlyCostRevenue: const [],
        customerWiseJobCount: const [],
        customerWiseRevenue: const [],
        vehicleLocations: const [],
        invoiceVsExpense: const [],
      );
}

class DashboardStatusCount {
  const DashboardStatusCount({
    required this.bucket,
    required this.label,
    required this.count,
    required this.statuses,
  });

  final String bucket;
  final String label;
  final int count;
  final List<DashboardStatusBreakdown> statuses;

  factory DashboardStatusCount.fromJson(Map<String, dynamic> json) =>
      DashboardStatusCount(
        bucket: _text(json['bucket']),
        label: _text(json['label']),
        count: _asInt(json['count']),
        statuses: (json['statuses'] as List? ?? const [])
            .map(
              (item) => DashboardStatusBreakdown.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
}

class DashboardStatusBreakdown {
  const DashboardStatusBreakdown({
    required this.id,
    required this.description,
    required this.count,
  });

  final int id;
  final String description;
  final int count;

  factory DashboardStatusBreakdown.fromJson(Map<String, dynamic> json) =>
      DashboardStatusBreakdown(
        id: _asInt(json['id']),
        description: _text(json['description']),
        count: _asInt(json['count']),
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

int _statusCount(Map<String, dynamic> json, String bucket) {
  final statusCounts = json['statusCounts'] as List? ?? const [];
  final status = statusCounts
      .cast<Map>()
      .cast<Map<String, dynamic>>()
      .firstWhere(
        (item) => _text(item['bucket']).toUpperCase() == bucket,
        orElse: () => const {},
      );
  return _asInt(status['count']);
}

String _text(Object? value) => value?.toString() ?? '';

double _asDouble(Object? value) => switch (value) {
  double value => value,
  num value => value.toDouble(),
  String value => double.tryParse(value) ?? 0,
  _ => 0,
};
