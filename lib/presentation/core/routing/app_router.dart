import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../features/tms/tms_pages.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SignInRoute.page, initial: true),
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: AllJobRequestsRoute.page),
    AutoRoute(page: NewJobRoute.page),
    AutoRoute(page: JobDetailRoute.page, path: '/job/:jobId'),
    AutoRoute(page: JobSummaryRoute.page),
    AutoRoute(page: WeeklyStatusRoute.page),
    AutoRoute(page: MonthlyStatusRoute.page),
  ];
}
