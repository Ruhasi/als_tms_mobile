import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';
import '../widgets/vehicle_assignment_sheet.dart';

@RoutePage()
class NewJobPage extends HookConsumerWidget {
  const NewJobPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryLocations = useState<List<TmsOption>>(const []);
    final vehicleType = useState('');
    final vehicle = useState('');
    final driver = useState('');

    Future<void> select(String type) async {
      final options = await ref.read(tmsRepositoryProvider).options(type);
      if (!context.mounted) return;
      final selected = await showOptionSheet(
        context,
        title: type,
        options: options,
      );
      if (selected == null) return;
    }

    Future<void> selectDeliveryLocations() async {
      final locations = await ref
          .read(tmsRepositoryProvider)
          .options('deliveryLocations');
      if (!context.mounted) return;
      final selected = await showMultiOptionSheet(
        context,
        title: 'Delivery locations',
        options: locations,
        initiallySelected: deliveryLocations.value,
      );
      if (selected != null) {
        deliveryLocations.value = selected;
      }
    }

    Future<void> assignVehicle() async {
      final result = await showVehicleAssignmentSheet(
        context,
        vehicleType: vehicleType.value,
        vehicle: vehicle.value,
        driver: driver.value,
        repository: ref.read(tmsRepositoryProvider),
      );
      if (result == null) return;
      vehicleType.value = result.vehicleType;
      vehicle.value = result.vehicle;
      driver.value = result.driver;
    }

    final assigned = !isVehicleUnassigned(vehicle.value);
    final deliveryLabel = deliveryLocations.value.isEmpty
        ? 'Select delivery locations'
        : deliveryLocations.value.length == 1
        ? deliveryLocations.value.first.title
        : '${deliveryLocations.value.length} delivery locations selected';

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
              child: Row(
                children: [
                  BackButton(onPressed: context.router.maybePop),
                  const Expanded(
                    child: Text(
                      'NEW JOB REQUEST',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _sectionLabel('PARTIES'),
                  SelectorTile(
                    label: 'Customer',
                    value: 'Ceylon Biscuits Ltd',
                    badge: 'OWN COMPANY',
                    locked: true,
                    onTap: null,
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Shipper',
                    value: 'CBL Ranala Plant',
                    badge: 'AUTO',
                    onTap: () => select('shipper'),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested arrival',
                    value: '6 Aug, 09:00',
                    onTap: () => select('arrival'),
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Delivery locations',
                    value: deliveryLabel,
                    badge: deliveryLocations.value.length > 1
                        ? '${deliveryLocations.value.length} SELECTED'
                        : null,
                    onTap: selectDeliveryLocations,
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested delivery',
                    value: '6 Aug, 16:30',
                    onTap: () => select('delivery'),
                  ),
                  _sectionLabel('VEHICLE & DRIVER (OPTIONAL)'),
                  if (assigned) ...[
                    SelectorTile(
                      label: 'Vehicle type',
                      value: vehicleType.value.isEmpty
                          ? '20 ft Container Truck'
                          : vehicleType.value,
                      onTap: assignVehicle,
                    ),
                    const SizedBox(height: 8),
                    SelectorTile(
                      label: 'Transport provider',
                      value: 'ALS Logistics (Pvt) Ltd',
                      badge: 'LOCKED',
                      locked: true,
                      onTap: null,
                    ),
                    const SizedBox(height: 8),
                    SelectorTile(
                      label: 'Vehicle number',
                      value: vehicle.value,
                      onTap: assignVehicle,
                    ),
                    const SizedBox(height: 8),
                    SelectorTile(
                      label: 'Driver',
                      value: driver.value,
                      onTap: assignVehicle,
                    ),
                  ] else
                    _optionalAssignCard(onTap: assignVehicle),
                  _sectionLabel('COMMENTS (OPTIONAL)'),
                  const TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Remarks for the transport provider — dock number, cold chain, escort, etc.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: TmsColors.line),
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TmsColors.line),
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'After submitting you can edit or cancel this request for 60 minutes.',
                    style: TextStyle(fontSize: 10, color: TmsColors.muted),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TmsButton(
                label: 'Submit job request',
                onPressed: () => context.router.replace(const DashboardRoute()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _optionalAssignCard({required VoidCallback onTap}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TmsColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No vehicle assigned',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'You can submit now and assign a vehicle later from the job details.',
            style: TextStyle(fontSize: 11, color: TmsColors.muted),
          ),
          SizedBox(height: 10),
          Text(
            'Assign vehicle',
            style: TextStyle(
              color: TmsColors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ),
);

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 8),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: TmsColors.muted,
    ),
  ),
);
