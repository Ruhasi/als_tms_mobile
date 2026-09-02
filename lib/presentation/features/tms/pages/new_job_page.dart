import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../../domain/transport_booking/create_transport_booking_request.dart';
import '../../../../domain/transport_booking/lookup_item.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';
import '../../../core/widgets/booking_lookup_sheet.dart';
import '../widgets/vehicle_assignment_sheet.dart';

@RoutePage()
class NewJobPage extends HookConsumerWidget {
  const NewJobPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookups = ref.read(bookingLookupRepositoryProvider);
    final dropLocations = useState<List<_DropLocation>>(const []);
    final customer = useState<LookupItem?>(null);
    final department = useState<LookupItem?>(null);
    final invoiceTo = useState<LookupItem?>(null);
    final shipper = useState<LookupItem?>(null);
    final pickup = useState<LookupItem?>(null);
    final destination = useState<LookupItem?>(null);
    final customerItems = useState<List<LookupItem>>(const []);
    final departmentItems = useState<List<LookupItem>>(const []);
    final shipperItems = useState<List<LookupItem>>(const []);
    final locationItems = useState<List<LookupItem>>(const []);
    final finalDestination = useState('');
    final vehicleType = useState('');
    final vehicleTypeLookup = useState<LookupItem?>(null);
    final vehicle = useState('');
    final driver = useState('');
    final paymentMode = useState<int?>(null);
    final cashOrCredit = useState<int?>(null);
    final invoiceStatus = useState<int?>(null);
    final requestedArrival = useState<DateTime?>(null);
    final requestedDelivery = useState<DateTime?>(null);
    final comments = useTextEditingController();
    final isSubmitting = useState(false);
    final showValidationErrors = useState(false);

    Future<LookupItem?> lookup(
      String title,
      LookupSearch search,
      List<LookupItem> initialItems,
    ) async {
      return showBookingLookupSheet(
        context,
        title: title,
        search: search,
        initialItems: initialItems,
      );
    }

    useEffect(() {
      Future<void> preload() async {
        final results = await Future.wait([
          lookups.departments(),
          lookups.customers(''),
          lookups.shippers(''),
          lookups.locations(''),
        ]);
        if (!context.mounted) return;
        results[0].fold((_) {}, (items) {
          departmentItems.value = items;
          if (items.length == 1) department.value = items.first;
        });
        results[1].fold((_) {}, (items) {
          customerItems.value = items;
          if (items.length == 1) {
            customer.value = items.first;
            invoiceTo.value = items.first;
          }
        });
        results[2].fold((_) {}, (items) {
          shipperItems.value = items;
          if (items.length == 1) shipper.value = items.first;
        });
        results[3].fold((_) {}, (items) {
          locationItems.value = items;
        });
      }

      preload();
      return null;
    }, const []);

    Future<void> addDropLocation() async {
      final location = await showModalBottomSheet<_DropLocation>(
        context: context,
        isScrollControlled: true,
        backgroundColor: TmsColors.canvas,
        showDragHandle: true,
        builder: (_) => _AddDropLocationSheet(
          locationSearch: lookups.locations,
          initialLocations: locationItems.value,
          selectedLocationIds: dropLocations.value
              .map((dropLocation) => dropLocation.location.id)
              .toSet(),
        ),
      );
      if (!context.mounted) return;
      if (location == null) return;
      dropLocations.value = [...dropLocations.value, location];
    }

    void removeDropLocation(_DropLocation location) {
      dropLocations.value = dropLocations.value
          .where((dropLocation) => dropLocation != location)
          .toList();
    }

    Future<void> assignVehicle() async {
      final result = await context.router.push<VehicleAssignmentResult>(
        VehicleAssignmentRoute(
          customerSeq: customer.value?.seq,
          vehicleType: vehicleType.value,
          vehicle: vehicle.value,
          driver: driver.value,
        ),
      );
      if (result == null) return;
      vehicleType.value = result.vehicleType;
      vehicle.value = result.vehicle;
      driver.value = result.driver;
    }

    final assigned = !isVehicleUnassigned(vehicle.value);

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
                    label: 'Department',
                    value: department.value?.name ?? 'Select department',
                    hasError:
                        showValidationErrors.value && department.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Department',
                        (_) => lookups.departments(),
                        departmentItems.value,
                      );
                      if (selected != null) department.value = selected;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Customer',
                    value: customer.value?.name ?? 'Select customer',
                    hasError:
                        showValidationErrors.value && customer.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Customer',
                        lookups.customers,
                        customerItems.value,
                      );
                      if (selected == null) return;
                      customer.value = selected;
                      vehicleType.value = '';
                      vehicleTypeLookup.value = null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Shipper',
                    value: shipper.value?.name ?? 'Select shipper',
                    hasError:
                        showValidationErrors.value && shipper.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Shipper',
                        lookups.shippers,
                        shipperItems.value,
                      );
                      if (selected != null) shipper.value = selected;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Invoice to',
                    value: invoiceTo.value?.name ?? 'Select invoice customer',
                    hasError:
                        showValidationErrors.value && invoiceTo.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Invoice to',
                        lookups.customers,
                        customerItems.value,
                      );
                      if (selected != null) invoiceTo.value = selected;
                    },
                  ),
                  _sectionLabel('ROUTE'),
                  SelectorTile(
                    label: 'Pickup location',
                    value: pickup.value?.name ?? 'Select pickup location',
                    hasError:
                        showValidationErrors.value && pickup.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Pickup location',
                        lookups.locations,
                        locationItems.value,
                      );
                      if (selected != null) pickup.value = selected;
                    },
                  ),
                  // const SizedBox(height: 12),
                  // _DropLocationsField(
                  //   locations: dropLocations.value,
                  //   onAdd: addDropLocation,
                  //   onRemove: removeDropLocation,
                  // ),
                  const SizedBox(height: 12),
                  SelectorTile(
                    label: 'Final destination',
                    value:
                        destination.value?.name ??
                        (finalDestination.value.isEmpty
                            ? 'Select final destination'
                            : finalDestination.value),
                    hasError:
                        showValidationErrors.value && destination.value == null,
                    onTap: () async {
                      final selected = await lookup(
                        'Final destination',
                        lookups.locations,
                        locationItems.value,
                      );
                      if (selected != null) destination.value = selected;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested arrival',
                    value: _dateTimeLabel(context, requestedArrival.value),
                    hasError:
                        showValidationErrors.value &&
                        requestedArrival.value == null,
                    onTap: () async {
                      final value = await _showDateTimeWheel(
                        context,
                        initialDate: requestedArrival.value,
                      );
                      if (value != null) requestedArrival.value = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested delivery',
                    value: _dateTimeLabel(context, requestedDelivery.value),
                    hasError:
                        showValidationErrors.value &&
                        requestedDelivery.value == null,
                    onTap: () async {
                      final value = await _showDateTimeWheel(
                        context,
                        initialDate: requestedDelivery.value,
                      );
                      if (value != null) requestedDelivery.value = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Payment mode',
                    value: _paymentModeLabel(paymentMode.value),
                    hasError:
                        showValidationErrors.value && paymentMode.value == null,
                    onTap: () async {
                      final option = await showOptionSheet(
                        context,
                        title: 'Payment mode',
                        options: _paymentModes,
                      );
                      if (option != null) {
                        paymentMode.value = int.parse(option.id);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Cash or credit',
                    value: _cashOrCreditLabel(cashOrCredit.value),
                    hasError:
                        showValidationErrors.value &&
                        cashOrCredit.value == null,
                    onTap: () async {
                      final option = await showOptionSheet(
                        context,
                        title: 'Cash or credit',
                        options: _cashOrCreditOptions,
                      );
                      if (option != null) {
                        cashOrCredit.value = int.parse(option.id);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Invoice status',
                    value: _invoiceStatusLabel(invoiceStatus.value),
                    hasError:
                        showValidationErrors.value &&
                        invoiceStatus.value == null,
                    onTap: () async {
                      final option = await showOptionSheet(
                        context,
                        title: 'Invoice status',
                        options: _invoiceStatusOptions,
                      );
                      if (option != null) {
                        invoiceStatus.value = int.parse(option.id);
                      }
                    },
                  ),
                  _sectionLabel('VEHICLE & DRIVER (OPTIONAL)'),
                  SelectorTile(
                    label: 'Vehicle type',
                    value: vehicleType.value.isEmpty
                        ? 'Select vehicle type'
                        : vehicleType.value,
                    hasError:
                        showValidationErrors.value &&
                        vehicleTypeLookup.value == null,
                    onTap: customer.value == null
                        ? null
                        : () async {
                            final result = await lookups.vehicleTypes(
                              customer.value!.seq,
                            );
                            final initialItems = result.fold(
                              (_) => <LookupItem>[],
                              (items) => items,
                            );
                            final selected = await lookup(
                              'Vehicle type',
                              (_) => lookups.vehicleTypes(customer.value!.seq),
                              initialItems,
                            );
                            if (selected != null) {
                              vehicleType.value = selected.name;
                              vehicleTypeLookup.value = selected;
                            }
                          },
                  ),
                  const SizedBox(height: 8),
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
                  TextField(
                    controller: comments,
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
                label: isSubmitting.value
                    ? 'Submitting...'
                    : 'Submit job request',
                onPressed: isSubmitting.value
                    ? null
                    : () async {
                        if (customer.value == null ||
                            department.value == null ||
                            shipper.value == null ||
                            invoiceTo.value == null ||
                            invoiceStatus.value == null ||
                            vehicleTypeLookup.value == null ||
                            pickup.value == null ||
                            requestedArrival.value == null ||
                            destination.value == null ||
                            requestedDelivery.value == null ||
                            paymentMode.value == null ||
                            cashOrCredit.value == null) {
                          showValidationErrors.value = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Complete all required fields.'),
                            ),
                          );
                          return;
                        }
                        isSubmitting.value = true;
                        final result = await lookups.createBooking(
                          CreateTransportBookingRequest(
                            departmentSeq: department.value!.seq,
                            customerSeq: customer.value!.seq,
                            shipperSeq: shipper.value!.seq,
                            invoiceCustomerSeq: invoiceTo.value!.seq,
                            invoiceStatus: invoiceStatus.value!,
                            vehicleTypeSeq: vehicleTypeLookup.value!.seq,
                            pickupLocationSeq: pickup.value!.seq,
                            pickupLocationAddress: pickup.value!.name,
                            requestedArrivalTime: requestedArrival.value!,
                            deliveryLocationSeq: destination.value!.seq,
                            deliveryLocationAddress: destination.value!.name,
                            requestedDeliveryTime: requestedDelivery.value!,
                            paymentMode: paymentMode.value!,
                            cashOrCredit: cashOrCredit.value!,
                            comments: comments.text.trim(),
                          ),
                        );
                        if (!context.mounted) return;
                        isSubmitting.value = false;
                        result.fold(
                          (failure) =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              ),
                          (bookingSeq) async {
                            ref.invalidate(transportBookingsProvider);
                            ref.invalidate(mobileDashboardProvider);
                            await showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Job request created'),
                                content: Text(
                                  'Transport booking #$bookingSeq was created successfully.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            if (!context.mounted) return;
                            context.router.replace(const DashboardRoute());
                          },
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropLocation {
  const _DropLocation({required this.location, required this.dropAt});

  final TmsOption location;
  final DateTime dropAt;
}

class _DropLocationsField extends StatelessWidget {
  const _DropLocationsField({
    required this.locations,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_DropLocation> locations;
  final VoidCallback onAdd;
  final ValueChanged<_DropLocation> onRemove;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: TmsColors.line),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'DROP LOCATIONS (OPTIONAL)',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: TmsColors.muted,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: TmsColors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        if (locations.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Add one or more delivery locations',
              style: TextStyle(fontSize: 12, color: TmsColors.muted),
            ),
          )
        else ...[
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: locations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final dropLocation = locations[index];
              final date = MaterialLocalizations.of(
                context,
              ).formatMediumDate(dropLocation.dropAt);
              final time = MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(TimeOfDay.fromDateTime(dropLocation.dropAt));

              return Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                decoration: BoxDecoration(
                  color: TmsColors.orange.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: TmsColors.orange,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dropLocation.location.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$date · $time',
                            style: const TextStyle(
                              fontSize: 10,
                              color: TmsColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(dropLocation),
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 18,
                      ),
                      color: TmsColors.muted,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Remove drop location',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    ),
  );
}

class _AddDropLocationSheet extends StatefulWidget {
  const _AddDropLocationSheet({
    required this.locationSearch,
    required this.initialLocations,
    required this.selectedLocationIds,
  });

  final LookupSearch locationSearch;
  final List<LookupItem> initialLocations;
  final Set<String> selectedLocationIds;

  @override
  State<_AddDropLocationSheet> createState() => _AddDropLocationSheetState();
}

class _AddDropLocationSheetState extends State<_AddDropLocationSheet> {
  TmsOption? _location;
  DateTime? _date;
  TimeOfDay? _time;

  Future<void> _selectLocation() async {
    final selected = await showBookingLookupSheet(
      context,
      title: 'Drop location',
      search: widget.locationSearch,
      initialItems: widget.initialLocations,
    );
    if (!mounted || selected == null) return;
    if (widget.selectedLocationIds.contains('${selected.seq}')) return;
    setState(
      () => _location = TmsOption(
        id: '${selected.seq}',
        title: selected.name,
        subtitle: selected.code,
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await _showDateWheel(context, initialDate: _date);
    if (!mounted || date == null) return;
    setState(() => _date = date);
  }

  Future<void> _selectTime() async {
    final time = await _showTimeWheel(context, initialTime: _time);
    if (!mounted || time == null) return;
    setState(() => _time = time);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _location != null && _date != null && _time != null;
    final dateText = _date == null
        ? 'Select date'
        : MaterialLocalizations.of(context).formatMediumDate(_date!);
    final timeText = _time == null
        ? 'Select time'
        : MaterialLocalizations.of(context).formatTimeOfDay(_time!);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          4,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ADD DROP LOCATION',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select the location, then schedule its date and time.',
              style: TextStyle(fontSize: 12, color: TmsColors.muted),
            ),
            const SizedBox(height: 14),
            SelectorTile(
              label: 'Location',
              value: _location?.title ?? 'Search and select location',
              onTap: _selectLocation,
            ),
            const SizedBox(height: 8),
            SelectorTile(
              label: 'Drop date',
              value: dateText,
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),
            SelectorTile(
              label: 'Drop time',
              value: timeText,
              onTap: _selectTime,
            ),
            const SizedBox(height: 18),
            TmsButton(
              label: 'Add drop location',
              onPressed: canSave
                  ? () {
                      final dropAt = DateTime(
                        _date!.year,
                        _date!.month,
                        _date!.day,
                        _time!.hour,
                        _time!.minute,
                      );
                      Navigator.pop(
                        context,
                        _DropLocation(location: _location!, dropAt: dropAt),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> _showDateWheel(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  var selectedDate = initialDate ?? DateTime.now();
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => _DateTimeWheel(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: selectedDate,
      onChanged: (value) => selectedDate = value,
      onDone: () => Navigator.pop(context, selectedDate),
    ),
  );
}

Future<DateTime?> _showDateTimeWheel(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  var selectedDate = initialDate ?? DateTime.now();
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => _DateTimeWheel(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: selectedDate,
      onChanged: (value) => selectedDate = value,
      onDone: () => Navigator.pop(context, selectedDate),
    ),
  );
}

Future<TimeOfDay?> _showTimeWheel(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  final now = DateTime.now();
  var selectedTime = initialTime ?? TimeOfDay.fromDateTime(now);
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (context) => _DateTimeWheel(
      mode: CupertinoDatePickerMode.time,
      initialDateTime: DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      onChanged: (value) => selectedTime = TimeOfDay.fromDateTime(value),
      onDone: () => Navigator.pop(context, selectedTime),
    ),
  );
}

class _DateTimeWheel extends StatelessWidget {
  const _DateTimeWheel({
    required this.mode,
    required this.initialDateTime,
    required this.onChanged,
    required this.onDone,
  });

  final CupertinoDatePickerMode mode;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Container(
    height: 300,
    color: Colors.white,
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onDone,
            child: const Text(
              'Done',
              style: TextStyle(
                color: TmsColors.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Expanded(
          child: CupertinoDatePicker(
            mode: mode,
            initialDateTime: initialDateTime,
            onDateTimeChanged: onChanged,
          ),
        ),
      ],
    ),
  );
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

const _paymentModes = [
  TmsOption(id: '0', title: 'Other', subtitle: ''),
  TmsOption(id: '1', title: 'Monthly Commitment', subtitle: ''),
  TmsOption(id: '2', title: 'KM Commitment', subtitle: ''),
  TmsOption(id: '3', title: 'Point to Point', subtitle: ''),
  TmsOption(id: '4', title: 'Cargo in Hand Km', subtitle: ''),
  TmsOption(id: '5', title: 'Round Trip Km', subtitle: ''),
  TmsOption(id: '6', title: 'Actual GPS Km', subtitle: ''),
  TmsOption(id: '7', title: 'Meter Reading Km', subtitle: ''),
];
const _cashOrCreditOptions = [
  TmsOption(id: '0', title: 'Cash', subtitle: ''),
  TmsOption(id: '1', title: 'Credit', subtitle: ''),
];
const _invoiceStatusOptions = [
  TmsOption(id: '0', title: 'No', subtitle: ''),
  TmsOption(id: '1', title: 'Yes', subtitle: ''),
];

String _paymentModeLabel(int? value) =>
    value == null ? 'Select payment mode' : _paymentModes[value].title;
String _cashOrCreditLabel(int? value) =>
    value == null ? 'Select cash or credit' : _cashOrCreditOptions[value].title;
String _invoiceStatusLabel(int? value) => value == null
    ? 'Select invoice status'
    : _invoiceStatusOptions[value].title;

String _dateTimeLabel(BuildContext context, DateTime? value) {
  if (value == null) return 'Select date and time';
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatMediumDate(value)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}
