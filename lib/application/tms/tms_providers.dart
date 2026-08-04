import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/tms/models/tms_models.dart';
import '../../infrastructure/tms/mock_tms_repository.dart';

final tmsRepositoryProvider = Provider<MockTmsRepository>(
  (ref) => MockTmsRepository(),
);

final dashboardProvider = FutureProvider<DashboardData>(
  (ref) => ref.watch(tmsRepositoryProvider).dashboard(),
);

final jobProvider = FutureProvider.family<TmsJob, String>(
  (ref, id) => ref.watch(tmsRepositoryProvider).job(id),
);

/// Session-only job updates used by the mobile mock until the backend API is wired.
