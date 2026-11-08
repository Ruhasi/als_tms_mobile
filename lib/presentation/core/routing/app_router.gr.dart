// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AllJobRequestsPage]
class AllJobRequestsRoute extends PageRouteInfo<AllJobRequestsRouteArgs> {
  AllJobRequestsRoute({
    Key? key,
    String? initialFilter,
    List<PageRouteInfo>? children,
  }) : super(
         AllJobRequestsRoute.name,
         args: AllJobRequestsRouteArgs(key: key, initialFilter: initialFilter),
         rawQueryParams: {'filter': initialFilter},
         initialChildren: children,
       );

  static const String name = 'AllJobRequestsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<AllJobRequestsRouteArgs>(
        orElse: () => AllJobRequestsRouteArgs(
          initialFilter: queryParams.optString('filter'),
        ),
      );
      return AllJobRequestsPage(
        key: args.key,
        initialFilter: args.initialFilter,
      );
    },
  );
}

class AllJobRequestsRouteArgs {
  const AllJobRequestsRouteArgs({this.key, this.initialFilter});

  final Key? key;

  final String? initialFilter;

  @override
  String toString() {
    return 'AllJobRequestsRouteArgs{key: $key, initialFilter: $initialFilter}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AllJobRequestsRouteArgs) return false;
    return key == other.key && initialFilter == other.initialFilter;
  }

  @override
  int get hashCode => key.hashCode ^ initialFilter.hashCode;
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [DriverDashboardPage]
class DriverDashboardRoute extends PageRouteInfo<void> {
  const DriverDashboardRoute({List<PageRouteInfo>? children})
    : super(DriverDashboardRoute.name, initialChildren: children);

  static const String name = 'DriverDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DriverDashboardPage();
    },
  );
}

/// generated route for
/// [DriverJobDetailPage]
class DriverJobDetailRoute extends PageRouteInfo<DriverJobDetailRouteArgs> {
  DriverJobDetailRoute({
    Key? key,
    required int jobId,
    List<PageRouteInfo>? children,
  }) : super(
         DriverJobDetailRoute.name,
         args: DriverJobDetailRouteArgs(key: key, jobId: jobId),
         rawPathParams: {'jobId': jobId},
         initialChildren: children,
       );

  static const String name = 'DriverJobDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DriverJobDetailRouteArgs>(
        orElse: () =>
            DriverJobDetailRouteArgs(jobId: pathParams.getInt('jobId')),
      );
      return DriverJobDetailPage(key: args.key, jobId: args.jobId);
    },
  );
}

class DriverJobDetailRouteArgs {
  const DriverJobDetailRouteArgs({this.key, required this.jobId});

  final Key? key;

  final int jobId;

  @override
  String toString() {
    return 'DriverJobDetailRouteArgs{key: $key, jobId: $jobId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DriverJobDetailRouteArgs) return false;
    return key == other.key && jobId == other.jobId;
  }

  @override
  int get hashCode => key.hashCode ^ jobId.hashCode;
}

/// generated route for
/// [DriverJobHistoryPage]
class DriverJobHistoryRoute extends PageRouteInfo<void> {
  const DriverJobHistoryRoute({List<PageRouteInfo>? children})
    : super(DriverJobHistoryRoute.name, initialChildren: children);

  static const String name = 'DriverJobHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DriverJobHistoryPage();
    },
  );
}

/// generated route for
/// [DriverNavigationPage]
class DriverNavigationRoute extends PageRouteInfo<DriverNavigationRouteArgs> {
  DriverNavigationRoute({
    Key? key,
    required int jobId,
    String stop = 'pickup',
    List<PageRouteInfo>? children,
  }) : super(
         DriverNavigationRoute.name,
         args: DriverNavigationRouteArgs(key: key, jobId: jobId, stop: stop),
         rawPathParams: {'jobId': jobId},
         rawQueryParams: {'stop': stop},
         initialChildren: children,
       );

  static const String name = 'DriverNavigationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<DriverNavigationRouteArgs>(
        orElse: () => DriverNavigationRouteArgs(
          jobId: pathParams.getInt('jobId'),
          stop: queryParams.getString('stop', 'pickup'),
        ),
      );
      return DriverNavigationPage(
        key: args.key,
        jobId: args.jobId,
        stop: args.stop,
      );
    },
  );
}

class DriverNavigationRouteArgs {
  const DriverNavigationRouteArgs({
    this.key,
    required this.jobId,
    this.stop = 'pickup',
  });

  final Key? key;

  final int jobId;

  final String stop;

  @override
  String toString() {
    return 'DriverNavigationRouteArgs{key: $key, jobId: $jobId, stop: $stop}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DriverNavigationRouteArgs) return false;
    return key == other.key && jobId == other.jobId && stop == other.stop;
  }

  @override
  int get hashCode => key.hashCode ^ jobId.hashCode ^ stop.hashCode;
}

/// generated route for
/// [DriverPodUploadPage]
class DriverPodUploadRoute extends PageRouteInfo<DriverPodUploadRouteArgs> {
  DriverPodUploadRoute({
    Key? key,
    required int jobId,
    List<PageRouteInfo>? children,
  }) : super(
         DriverPodUploadRoute.name,
         args: DriverPodUploadRouteArgs(key: key, jobId: jobId),
         rawPathParams: {'jobId': jobId},
         initialChildren: children,
       );

  static const String name = 'DriverPodUploadRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DriverPodUploadRouteArgs>(
        orElse: () =>
            DriverPodUploadRouteArgs(jobId: pathParams.getInt('jobId')),
      );
      return DriverPodUploadPage(key: args.key, jobId: args.jobId);
    },
  );
}

class DriverPodUploadRouteArgs {
  const DriverPodUploadRouteArgs({this.key, required this.jobId});

  final Key? key;

  final int jobId;

  @override
  String toString() {
    return 'DriverPodUploadRouteArgs{key: $key, jobId: $jobId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DriverPodUploadRouteArgs) return false;
    return key == other.key && jobId == other.jobId;
  }

  @override
  int get hashCode => key.hashCode ^ jobId.hashCode;
}

/// generated route for
/// [JobDetailPage]
class JobDetailRoute extends PageRouteInfo<JobDetailRouteArgs> {
  JobDetailRoute({Key? key, required int jobId, List<PageRouteInfo>? children})
    : super(
        JobDetailRoute.name,
        args: JobDetailRouteArgs(key: key, jobId: jobId),
        rawPathParams: {'jobId': jobId},
        initialChildren: children,
      );

  static const String name = 'JobDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<JobDetailRouteArgs>(
        orElse: () => JobDetailRouteArgs(jobId: pathParams.getInt('jobId')),
      );
      return JobDetailPage(key: args.key, jobId: args.jobId);
    },
  );
}

class JobDetailRouteArgs {
  const JobDetailRouteArgs({this.key, required this.jobId});

  final Key? key;

  final int jobId;

  @override
  String toString() {
    return 'JobDetailRouteArgs{key: $key, jobId: $jobId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JobDetailRouteArgs) return false;
    return key == other.key && jobId == other.jobId;
  }

  @override
  int get hashCode => key.hashCode ^ jobId.hashCode;
}

/// generated route for
/// [JobSummaryPage]
class JobSummaryRoute extends PageRouteInfo<void> {
  const JobSummaryRoute({List<PageRouteInfo>? children})
    : super(JobSummaryRoute.name, initialChildren: children);

  static const String name = 'JobSummaryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const JobSummaryPage();
    },
  );
}

/// generated route for
/// [MonthlyStatusPage]
class MonthlyStatusRoute extends PageRouteInfo<void> {
  const MonthlyStatusRoute({List<PageRouteInfo>? children})
    : super(MonthlyStatusRoute.name, initialChildren: children);

  static const String name = 'MonthlyStatusRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MonthlyStatusPage();
    },
  );
}

/// generated route for
/// [NewJobPage]
class NewJobRoute extends PageRouteInfo<void> {
  const NewJobRoute({List<PageRouteInfo>? children})
    : super(NewJobRoute.name, initialChildren: children);

  static const String name = 'NewJobRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NewJobPage();
    },
  );
}

/// generated route for
/// [SignInPage]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInPage();
    },
  );
}

/// generated route for
/// [VehicleAssignmentPage]
class VehicleAssignmentRoute extends PageRouteInfo<VehicleAssignmentRouteArgs> {
  VehicleAssignmentRoute({
    Key? key,
    int? customerSeq,
    String vehicleType = '',
    bool showVehicleTypeSelector = true,
    String vehicle = '',
    String driver = '',
    String driverHelper = '',
    List<PageRouteInfo>? children,
  }) : super(
         VehicleAssignmentRoute.name,
         args: VehicleAssignmentRouteArgs(
           key: key,
           customerSeq: customerSeq,
           vehicleType: vehicleType,
           showVehicleTypeSelector: showVehicleTypeSelector,
           vehicle: vehicle,
           driver: driver,
           driverHelper: driverHelper,
         ),
         initialChildren: children,
       );

  static const String name = 'VehicleAssignmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VehicleAssignmentRouteArgs>(
        orElse: () => const VehicleAssignmentRouteArgs(),
      );
      return VehicleAssignmentPage(
        key: args.key,
        customerSeq: args.customerSeq,
        vehicleType: args.vehicleType,
        showVehicleTypeSelector: args.showVehicleTypeSelector,
        vehicle: args.vehicle,
        driver: args.driver,
        driverHelper: args.driverHelper,
      );
    },
  );
}

class VehicleAssignmentRouteArgs {
  const VehicleAssignmentRouteArgs({
    this.key,
    this.customerSeq,
    this.vehicleType = '',
    this.showVehicleTypeSelector = true,
    this.vehicle = '',
    this.driver = '',
    this.driverHelper = '',
  });

  final Key? key;

  final int? customerSeq;

  final String vehicleType;

  final bool showVehicleTypeSelector;

  final String vehicle;

  final String driver;

  final String driverHelper;

  @override
  String toString() {
    return 'VehicleAssignmentRouteArgs{key: $key, customerSeq: $customerSeq, vehicleType: $vehicleType, showVehicleTypeSelector: $showVehicleTypeSelector, vehicle: $vehicle, driver: $driver, driverHelper: $driverHelper}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VehicleAssignmentRouteArgs) return false;
    return key == other.key &&
        customerSeq == other.customerSeq &&
        vehicleType == other.vehicleType &&
        showVehicleTypeSelector == other.showVehicleTypeSelector &&
        vehicle == other.vehicle &&
        driver == other.driver &&
        driverHelper == other.driverHelper;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      customerSeq.hashCode ^
      vehicleType.hashCode ^
      showVehicleTypeSelector.hashCode ^
      vehicle.hashCode ^
      driver.hashCode ^
      driverHelper.hashCode;
}

/// generated route for
/// [ViaLocationPage]
class ViaLocationRoute extends PageRouteInfo<ViaLocationRouteArgs> {
  ViaLocationRoute({
    Key? key,
    required int unloadingOrder,
    List<PageRouteInfo>? children,
  }) : super(
         ViaLocationRoute.name,
         args: ViaLocationRouteArgs(key: key, unloadingOrder: unloadingOrder),
         initialChildren: children,
       );

  static const String name = 'ViaLocationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViaLocationRouteArgs>();
      return ViaLocationPage(
        key: args.key,
        unloadingOrder: args.unloadingOrder,
      );
    },
  );
}

class ViaLocationRouteArgs {
  const ViaLocationRouteArgs({this.key, required this.unloadingOrder});

  final Key? key;

  final int unloadingOrder;

  @override
  String toString() {
    return 'ViaLocationRouteArgs{key: $key, unloadingOrder: $unloadingOrder}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ViaLocationRouteArgs) return false;
    return key == other.key && unloadingOrder == other.unloadingOrder;
  }

  @override
  int get hashCode => key.hashCode ^ unloadingOrder.hashCode;
}

/// generated route for
/// [WeeklyStatusPage]
class WeeklyStatusRoute extends PageRouteInfo<void> {
  const WeeklyStatusRoute({List<PageRouteInfo>? children})
    : super(WeeklyStatusRoute.name, initialChildren: children);

  static const String name = 'WeeklyStatusRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WeeklyStatusPage();
    },
  );
}
