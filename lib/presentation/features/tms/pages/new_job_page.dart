import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class NewJobPage extends HookConsumerWidget {
  const NewJobPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);
    final destination = useState('Select destination');
    final vehicle = useState('LP-4471 · 20 ft Container Truck');
    final driver = useState('K. Wijesinghe');
    Future<void> select(String type) async {
      final options = await ref.read(tmsRepositoryProvider).options(type);
      if (!context.mounted) return;
      final selected = await showOptionSheet(
        context,
        title: type,
        options: options,
      );
      if (selected == null) return;
      if (type == 'destination') {
        destination.value = selected.title;
      }
      if (type == 'vehicle') {
        vehicle.value = '${selected.title} · 20 ft Container Truck';
      }
      if (type == 'driver') {
        driver.value = selected.title;
      }
    }

    final values = step.value == 0
        ? _partyFields(destination.value, select)
        : step.value == 1
        ? _assetFields(vehicle.value, driver.value, select)
        : _reviewFields(destination.value, vehicle.value, driver.value);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      BackButton(onPressed: context.router.maybePop),
                      Expanded(
                        child: Text(
                          [
                            'NEW JOB REQUEST',
                            'VEHICLE & DRIVER',
                            'REVIEW & SUBMIT',
                          ][step.value],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text('${step.value + 1}/3'),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: (step.value + 1) / 3,
                    color: TmsColors.orange,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: values,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TmsButton(
                dark: step.value < 2,
                label: step.value == 2
                    ? 'Submit job request'
                    : step.value == 0
                    ? 'Continue to vehicle'
                    : 'Review request',
                onPressed: () => step.value < 2
                    ? step.value++
                    : context.router.replace(const DashboardRoute()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _partyFields(
  String destination,
  Future<void> Function(String) select,
) => [
  _sectionLabel('PARTIES'),
  SelectorTile(
    label: 'Customer',
    value: 'Ceylon Biscuits Ltd',
    badge: 'OWN COMPANY',
    locked: true,
    onTap: null,
  ),
  SelectorTile(
    label: 'Shipper',
    value: 'CBL Ranala Plant',
    badge: 'AUTO',
    onTap: () => select('shipper'),
  ),
  SelectorTile(
    label: 'Invoice to',
    value: 'Ceylon Biscuits Ltd',
    badge: 'LOCKED',
    locked: true,
    onTap: null,
  ),
  _sectionLabel('ROUTE'),
  SelectorTile(
    label: 'Pickup location',
    value: 'Colombo DC — Orugodawatta',
    badge: 'AUTO',
    onTap: () => select('pickup'),
  ),
  SelectorTile(
    label: 'Requested arrival',
    value: '6 Aug, 09:00',
    onTap: () => select('arrival'),
  ),
  SelectorTile(
    label: 'Destination',
    value: destination,
    onTap: () => select('destination'),
  ),
  SelectorTile(
    label: 'Requested delivery',
    value: '6 Aug, 16:30',
    onTap: () => select('delivery'),
  ),
];

List<Widget> _assetFields(
  String vehicle,
  String driver,
  Future<void> Function(String) select,
) => [
  _sectionLabel('VEHICLE & DRIVER'),
  SelectorTile(
    label: 'Vehicle type',
    value: '20 ft Container Truck',
    badge: 'AUTO',
    onTap: () => select('vehicleType'),
  ),
  SelectorTile(
    label: 'Transport provider',
    value: 'ALS Logistics (Pvt) Ltd',
    badge: 'LOCKED',
    locked: true,
    onTap: null,
  ),
  SelectorTile(
    label: 'Vehicle number',
    value: vehicle,
    badge: 'AUTO',
    onTap: () => select('vehicle'),
  ),
  SelectorTile(
    label: 'Driver',
    value: driver,
    badge: 'AUTO',
    onTap: () => select('driver'),
  ),
  _sectionLabel('COMMENTS (OPTIONAL)'),
  const TextField(
    maxLines: 5,
    decoration: InputDecoration(
      hintText:
          'Remarks for the transport provider — dock number, cold chain, escort, etc.',
      filled: true,
      fillColor: Colors.white,
    ),
  ),
];

List<Widget> _reviewFields(
  String destination,
  String vehicle,
  String driver,
) => [
  Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: TmsColors.ink,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '○  Colombo DC — Orugodawatta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '■  $destination',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Divider(color: Color(0xFF343942), height: 22),
        const Text(
          'ARRIVAL          DELIVERY\n6 Aug, 09:00     6 Aug, 16:30',
          style: TextStyle(color: Color(0xFFCBD0D5), fontSize: 10, height: 1.5),
        ),
      ],
    ),
  ),
  _sectionLabel('DETAILS'),
  SelectorTile(
    label: 'Customer',
    value: 'Ceylon Biscuits Ltd',
    locked: true,
    onTap: null,
  ),
  SelectorTile(
    label: 'Shipper',
    value: 'CBL Ranala Plant',
    locked: true,
    onTap: null,
  ),
  SelectorTile(
    label: 'Invoice to',
    value: 'Ceylon Biscuits Ltd',
    locked: true,
    onTap: null,
  ),
  SelectorTile(
    label: 'Transport provider',
    value: 'ALS Logistics (Pvt) Ltd',
    locked: true,
    onTap: null,
  ),
  SelectorTile(label: 'Vehicle', value: vehicle, locked: true, onTap: null),
  SelectorTile(label: 'Driver', value: driver, locked: true, onTap: null),
  _sectionLabel('COMMENTS'),
  const SelectorTile(
    label: 'Comment',
    value: 'Dock 4 only. Driver must carry gate pass.',
    locked: true,
    onTap: null,
  ),
  const Padding(
    padding: EdgeInsets.only(top: 8),
    child: Text(
      'After submitting you can edit or cancel this request for 60 minutes.',
      style: TextStyle(fontSize: 10, color: TmsColors.muted),
    ),
  ),
];

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(top: 12, bottom: 8),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: TmsColors.muted,
    ),
  ),
);
