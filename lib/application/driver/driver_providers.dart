import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/driver/driver_job.dart';
import '../../infrastructure/driver/mock_driver_jobs.dart';

final driverJobsProvider =
    NotifierProvider<DriverJobsNotifier, List<DriverJob>>(DriverJobsNotifier.new);

final driverJobProvider = Provider.family<DriverJob?, int>((ref, jobId) {
  final jobs = ref.watch(driverJobsProvider);
  for (final job in jobs) {
    if (job.id == jobId) return job;
  }
  return null;
});

class DriverJobsNotifier extends Notifier<List<DriverJob>> {
  @override
  List<DriverJob> build() {
    ref.keepAlive();
    return seedMockDriverJobs();
  }

  void startNavigation(int jobId, DriverStop stop) {
    _update(jobId, (job) {
      if (stop == DriverStop.pickup && !job.hasArrivedPickup) {
        return job.copyWith(stage: DriverJobStage.navigatingPickup);
      }
      if (stop == DriverStop.delivery &&
          job.hasArrivedPickup &&
          !job.hasArrivedDelivery) {
        return job.copyWith(stage: DriverJobStage.navigatingDelivery);
      }
      return job;
    });
  }

  void confirmArrival(int jobId, DriverStop stop) {
    _update(jobId, (job) {
      if (stop == DriverStop.pickup) {
        return job.copyWith(stage: DriverJobStage.arrivedPickup);
      }
      return job.copyWith(stage: DriverJobStage.arrivedDelivery);
    });
  }

  void addProofs(int jobId, List<ProofOfDeliveryImage> images) {
    _update(jobId, (job) {
      return job.copyWith(
        stage: DriverJobStage.completed,
        proofs: [...job.proofs, ...images],
      );
    });
  }

  void _update(int jobId, DriverJob Function(DriverJob job) transform) {
    state = [
      for (final job in state)
        if (job.id == jobId) transform(job) else job,
    ];
  }
}
