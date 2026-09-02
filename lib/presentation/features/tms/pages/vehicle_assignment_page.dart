import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/transport_booking/lookup_item.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/booking_lookup_sheet.dart';
import '../../../core/widgets/tms_widgets.dart';
import '../widgets/vehicle_assignment_sheet.dart';

@RoutePage()
class VehicleAssignmentPage extends HookConsumerWidget {
  const VehicleAssignmentPage({
    super.key,
    this.customerSeq,
    this.vehicleType = '',
    this.vehicle = '',
    this.driver = '',
    this.driverHelper = '',
  });

  final int? customerSeq;
  final String vehicleType;
  final String vehicle;
  final String driver;
  final String driverHelper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookups = ref.read(vehicleAssignmentLookupRepositoryProvider);
    final bookingLookups = ref.read(bookingLookupRepositoryProvider);
    final transporter = useState<LookupItem?>(null);
    final selectedVehicle = useState<LookupItem?>(null);
    final transporterItems = useState<List<LookupItem>>(const []);
    final vehicleItems = useState<List<LookupItem>>(const []);
    final vehicleTypeItems = useState<List<LookupItem>>(const []);
    final driverItems = useState<List<LookupItem>>(const []);
    final helperItems = useState<List<LookupItem>>(const []);
    final secondaryDriverItems = useState<List<LookupItem>>(const []);
    final secondaryHelperItems = useState<List<LookupItem>>(const []);
    final trailerItems = useState<List<LookupItem>>(const []);
    final selectedDriver = useState<LookupItem?>(null);
    final selectedHelper = useState<LookupItem?>(null);
    final selectedSecondaryDriver = useState<LookupItem?>(null);
    final selectedSecondaryHelper = useState<LookupItem?>(null);
    final selectedTrailer = useState<LookupItem?>(null);
    final selectedVehicleTypeLookup = useState<LookupItem?>(null);
    final isLoadingTransporterOptions = useState(false);
    final isLoadingVehicleTypes = useState(false);
    final selectedVehicleType = useState(
      vehicleType.isEmpty ? 'Select vehicle type' : vehicleType,
    );
    Future<void> loadVehicleTypes() async {
      final selectedCustomer = customerSeq;
      if (selectedCustomer == null) return;
      isLoadingVehicleTypes.value = true;
      final result = await bookingLookups.vehicleTypes(selectedCustomer);
      if (!context.mounted) return;
      isLoadingVehicleTypes.value = false;
      result.fold(
        (failure) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message))),
        (items) {
          vehicleTypeItems.value = items;
          if (items.length == 1 && vehicleType.isEmpty) {
            selectedVehicleType.value = items.first.name;
            selectedVehicleTypeLookup.value = items.first;
          }
        },
      );
    }

    Future<void> loadTransporterOptions(
      int transporterSeq, {
      bool autoSelect = false,
    }) async {
      isLoadingTransporterOptions.value = true;
      final results = await Future.wait([
        lookups.vehicles(transporterSeq),
        lookups.drivers(transporterSeq),
        lookups.helpers(transporterSeq),
        lookups.secondaryDrivers(transporterSeq),
        lookups.secondaryHelpers(transporterSeq),
        lookups.trailers(transporterSeq),
      ]);
      if (!context.mounted) return;
      isLoadingTransporterOptions.value = false;
      results[0].fold((_) {}, (items) {
        vehicleItems.value = items;
        if (autoSelect && items.length == 1) {
          selectedVehicle.value = items.first;
        }
      });
      results[1].fold((_) {}, (items) => driverItems.value = items);
      results[2].fold((_) {}, (items) => helperItems.value = items);
      results[3].fold((_) {}, (items) => secondaryDriverItems.value = items);
      results[4].fold((_) {}, (items) => secondaryHelperItems.value = items);
      results[5].fold((_) {}, (items) => trailerItems.value = items);
    }

    useEffect(() {
      Future<void> preload() async {
        final result = await lookups.transporters('');
        if (!context.mounted) return;
        result.fold((_) {}, (items) {
          transporterItems.value = items;
          if (items.length == 1) {
            transporter.value = items.first;
            loadTransporterOptions(items.first.seq, autoSelect: true);
          }
        });
      }

      preload();
      return null;
    }, const []);

    useEffect(() {
      loadVehicleTypes();
      return null;
    }, [customerSeq]);

    Future<void> selectTransporter() async {
      final selected = await showBookingLookupSheet(
        context,
        title: 'Transporter',
        search: lookups.transporters,
        initialItems: transporterItems.value,
      );
      if (selected == null) return;
      transporter.value = selected;
      selectedVehicle.value = null;
      vehicleItems.value = const [];
      selectedDriver.value = null;
      selectedHelper.value = null;
      selectedSecondaryDriver.value = null;
      selectedSecondaryHelper.value = null;
      selectedTrailer.value = null;
      await loadTransporterOptions(selected.seq, autoSelect: true);
    }

    Future<void> selectVehicle() async {
      final selectedTransporter = transporter.value;
      if (selectedTransporter == null) return;
      final selected = await showBookingLookupSheet(
        context,
        title: 'Vehicle',
        search: (_) => lookups.vehicles(selectedTransporter.seq),
        initialItems: vehicleItems.value,
        searchLocally: true,
      );
      if (selected != null) {
        selectedVehicle.value = selected;
        if (selected.code.isNotEmpty) selectedVehicleType.value = selected.code;
      }
    }

    Future<LookupItem?> selectLocalLookup(
      String title,
      List<LookupItem> items,
    ) {
      final selectedTransporter = transporter.value;
      if (selectedTransporter == null) return Future.value(null);
      return showBookingLookupSheet(
        context,
        title: title,
        // Local search is enabled, so the callback is not invoked while typing.
        search: (_) => lookups.drivers(selectedTransporter.seq),
        initialItems: items,
        searchLocally: true,
      );
    }

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      appBar: AppBar(
        backgroundColor: TmsColors.canvas,
        surfaceTintColor: Colors.transparent,
        title: const Text('ASSIGN VEHICLE'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Select a transporter and one of its vehicles.',
              style: TextStyle(fontSize: 12, color: TmsColors.muted),
            ),
            const SizedBox(height: 18),
            SelectorTile(
              label: 'Transporter',
              value: transporter.value?.name ?? 'Select transporter',
              onTap: selectTransporter,
            ),
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Vehicle',
              value:
                  selectedVehicle.value?.name ??
                  (transporter.value == null
                      ? 'Select transporter first'
                      : 'Select vehicle'),
              onTap:
                  transporter.value == null || isLoadingTransporterOptions.value
                  ? null
                  : selectVehicle,
            ),
            if (isLoadingTransporterOptions.value) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Vehicle type',
              value: selectedVehicleType.value,
              onTap: customerSeq == null || isLoadingVehicleTypes.value
                  ? null
                  : () async {
                      final selected = await showBookingLookupSheet(
                        context,
                        title: 'Vehicle type',
                        search: (_) =>
                            bookingLookups.vehicleTypes(customerSeq!),
                        initialItems: vehicleTypeItems.value,
                        searchLocally: true,
                      );
                      if (selected != null) {
                        selectedVehicleType.value = selected.name;
                        selectedVehicleTypeLookup.value = selected;
                      }
                    },
            ),
            if (isLoadingVehicleTypes.value)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Driver',
              value:
                  selectedDriver.value?.name ??
                  (driver.isEmpty ? 'Select driver' : driver),
              onTap: transporter.value == null
                  ? null
                  : () async {
                      final selected = await selectLocalLookup(
                        'Driver',
                        driverItems.value,
                      );
                      if (selected != null) selectedDriver.value = selected;
                    },
            ),
            if (selectedDriver.value != null || driver.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectorTile(
                label: 'Helper (optional)',
                value:
                    selectedHelper.value?.name ??
                    (driverHelper.isEmpty ? 'Select helper' : driverHelper),
                onTap: transporter.value == null
                    ? null
                    : () async {
                        final selected = await selectLocalLookup(
                          'Helper',
                          helperItems.value,
                        );
                        if (selected != null) selectedHelper.value = selected;
                      },
              ),
            ],
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Secondary driver (optional)',
              value:
                  selectedSecondaryDriver.value?.name ??
                  'Select secondary driver',
              onTap: transporter.value == null
                  ? null
                  : () async {
                      final selected = await selectLocalLookup(
                        'Secondary driver',
                        secondaryDriverItems.value,
                      );
                      if (selected != null) {
                        selectedSecondaryDriver.value = selected;
                      }
                    },
            ),
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Secondary helper (optional)',
              value:
                  selectedSecondaryHelper.value?.name ??
                  'Select secondary helper',
              onTap: transporter.value == null
                  ? null
                  : () async {
                      final selected = await selectLocalLookup(
                        'Secondary helper',
                        secondaryHelperItems.value,
                      );
                      if (selected != null) {
                        selectedSecondaryHelper.value = selected;
                      }
                    },
            ),
            const SizedBox(height: 10),
            SelectorTile(
              label: 'Trailer (optional)',
              value: selectedTrailer.value?.name ?? 'Select trailer',
              onTap: transporter.value == null
                  ? null
                  : () async {
                      final selected = await selectLocalLookup(
                        'Trailer',
                        trailerItems.value,
                      );
                      if (selected != null) selectedTrailer.value = selected;
                    },
            ),
            const SizedBox(height: 24),
            TmsButton(
              label: 'Save assignment',
              onPressed: () {
                if (selectedVehicle.value == null ||
                    (selectedDriver.value == null && driver.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Select both a vehicle and a driver to assign.',
                      ),
                    ),
                  );
                  return;
                }
                context.router.pop(
                  VehicleAssignmentResult(
                    vehicleType:
                        selectedVehicleType.value == 'Select vehicle type'
                        ? selectedVehicle.value!.code
                        : selectedVehicleType.value,
                    vehicle: selectedVehicle.value!.name,
                    driver: selectedDriver.value?.name ?? driver,
                    driverHelper: selectedHelper.value?.name ?? driverHelper,
                    secondaryDriver: selectedSecondaryDriver.value?.name ?? '',
                    secondaryHelper: selectedSecondaryHelper.value?.name ?? '',
                    trailer: selectedTrailer.value?.name ?? '',
                    transportCompanySeq: transporter.value?.seq,
                    vehicleSeq: selectedVehicle.value?.seq,
                    driverSeq: selectedDriver.value?.seq,
                    helperSeq: selectedHelper.value?.seq,
                    trailerSeq: selectedTrailer.value?.seq,
                    payableVehicleTypeSeq: selectedVehicleTypeLookup.value?.seq,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
