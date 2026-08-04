import '../../domain/tms/models/tms_models.dart';

class MockTmsRepository {
  MockTmsRepository();

  final List<TmsJob> _jobs = [
    TmsJob(
      id: 'JOB-4471',
      status: JobStatus.inTransit,
      pickup: 'Colombo DC — Orugodawatta',
      destination: 'Kandy Hub — Pallekele',
      pickupTime: 'Today 09:00 — 16:30',
      deliveryTime: '6 Aug, 16:30',
      customer: 'Ceylon Biscuits Ltd',
      shipper: 'CBL Ranala Plant',
      invoiceTo: 'Ceylon Biscuits Ltd',
      provider: 'ALS Logistics (Pvt) Ltd',
      vehicle: 'LP-4471 · 20 ft Container Truck',
      driver: 'K. Wijesinghe',
      comments: [
        JobComment(
          author: 'Nuwan Perera',
          message: 'Dock 4 only. Driver must carry gate pass.',
          createdAt: DateTime(2026, 8, 4, 9, 12),
        ),
        JobComment(
          author: 'Sanjeewa R. — dispatcher',
          message: 'Acknowledged. Vehicle reassigned to LP-4471.',
          createdAt: DateTime(2026, 8, 4, 9, 25),
          isDispatcher: true,
        ),
      ],
    ),
    TmsJob(
      id: 'JOB-4488',
      status: JobStatus.accepted,
      pickup: 'Katunayake FTZ Warehouse',
      destination: 'Colombo DC — Orugodawatta',
      pickupTime: 'Today 13:00 — 15:00',
      deliveryTime: '6 Aug, 18:00',
      customer: 'Ceylon Biscuits Ltd',
      shipper: 'CBL Ranala Plant',
      invoiceTo: 'Ceylon Biscuits Ltd',
      provider: 'ALS Logistics (Pvt) Ltd',
      vehicle: 'NC-8820 · 20 ft Container Truck',
      driver: 'S. Perera',
    ),
    TmsJob(
      id: 'JOB-4433',
      status: JobStatus.requested,
      pickup: 'Galle Depot',
      destination: 'Colombo DC — Orugodawatta',
      pickupTime: 'Tomorrow 07:30 — 11:00',
      deliveryTime: '7 Aug, 14:00',
      customer: 'Ceylon Biscuits Ltd',
      shipper: 'CBL Ranala Plant',
      invoiceTo: 'Ceylon Biscuits Ltd',
      provider: 'ALS Logistics (Pvt) Ltd',
      vehicle: 'LP-4471 · 20 ft Container Truck',
      driver: 'K. Wijesinghe',
    ),
    TmsJob(
      id: 'JOB-4459',
      status: JobStatus.delivered,
      pickup: 'Trincomalee Port',
      destination: 'Kandy Hub — Pallekele',
      pickupTime: '2 Aug 09:00',
      deliveryTime: '2 Aug 15:30',
      customer: 'Ceylon Biscuits Ltd',
      shipper: 'CBL Ranala Plant',
      invoiceTo: 'Ceylon Biscuits Ltd',
      provider: 'ALS Logistics (Pvt) Ltd',
      vehicle: 'LP-4471 · 20 ft Container Truck',
      driver: 'K. Wijesinghe',
    ),
  ];

  Future<DashboardData> dashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return DashboardData(
      user: const AppUser(
        name: 'Nuwan Perera',
        initials: 'NP',
        role: UserRole.transporter,
        company: 'ALS Logistics',
      ),
      openJobs: 6,
      deliveredThisMonth: 18,
      flaggedJobs: 2,
      jobs: List.unmodifiable(_jobs),
    );
  }

  Future<TmsJob> job(String id) async =>
      _jobs.firstWhere((item) => item.id == id);
  Future<List<TmsOption>> options(String type) async {
    final data = <String, List<TmsOption>>{
      'destination': const [
        TmsOption(
          id: 'kandy',
          title: 'Kandy Hub — Pallekele',
          subtitle: '134 km · approx. 3 h 10 m',
        ),
        TmsOption(
          id: 'galle',
          title: 'Galle Depot',
          subtitle: '126 km · approx. 2 h 40 m',
        ),
        TmsOption(
          id: 'jaffna',
          title: 'Jaffna Yard',
          subtitle: '396 km · approx. 8 h 05 m',
        ),
        TmsOption(
          id: 'port',
          title: 'Trincomalee Port',
          subtitle: '257 km · approx. 5 h 30 m',
        ),
      ],
      'vehicle': const [
        TmsOption(
          id: 'lp',
          title: 'LP-4471',
          subtitle: '20 ft Container Truck · available',
          isAuto: true,
        ),
        TmsOption(
          id: 'nc',
          title: 'NC-8820',
          subtitle: '20 ft Container Truck · available',
        ),
      ],
      'driver': const [
        TmsOption(
          id: 'wij',
          title: 'K. Wijesinghe',
          subtitle: 'Licence B1 · available',
          isAuto: true,
        ),
        TmsOption(
          id: 'per',
          title: 'S. Perera',
          subtitle: 'Licence B1 · available',
        ),
      ],
    };
    return data[type] ?? const [];
  }
}
