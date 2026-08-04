// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

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
/// [JobDetailPage]
class JobDetailRoute extends PageRouteInfo<JobDetailRouteArgs> {
  JobDetailRoute({
    Key? key,
    required String jobId,
    List<PageRouteInfo>? children,
  }) : super(
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
        orElse: () => JobDetailRouteArgs(jobId: pathParams.getString('jobId')),
      );
      return JobDetailPage(key: args.key, jobId: args.jobId);
    },
  );
}

class JobDetailRouteArgs {
  const JobDetailRouteArgs({this.key, required this.jobId});

  final Key? key;

  final String jobId;

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
