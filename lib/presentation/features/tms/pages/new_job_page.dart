import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../../infrastructure/tms/mock_tms_repository.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';
import '../widgets/vehicle_assignment_sheet.dart';

@RoutePage()
class NewJobPage extends HookConsumerWidget {
  const NewJobPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropLocations = useState<List<_DropLocation>>(const []);
    final finalDestination = useState('');
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

    Future<void> addDropLocation() async {
      final location = await showModalBottomSheet<_DropLocation>(
        context: context,
        isScrollControlled: true,
        backgroundColor: TmsColors.canvas,
        showDragHandle: true,
        builder: (_) => _AddDropLocationSheet(
          repository: ref.read(tmsRepositoryProvider),
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

    Future<void> selectFinalDestination() async {
      final destinations = await ref
          .read(tmsRepositoryProvider)
          .options('destination');
      if (!context.mounted) return;
      final selected = await showOptionSheet(
        context,
        title: 'Final destination',
        options: destinations,
      );
      if (selected == null) return;
      finalDestination.value = selected.title;
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
                  const SizedBox(height: 12),
                  _DropLocationsField(
                    locations: dropLocations.value,
                    onAdd: addDropLocation,
                    onRemove: removeDropLocation,
                  ),
                  const SizedBox(height: 12),
                  SelectorTile(
                    label: 'Final destination',
                    value: finalDestination.value.isEmpty
                        ? 'Select final destination'
                        : finalDestination.value,
                    onTap: selectFinalDestination,
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested arrival',
                    value: '6 Aug, 09:00',
                    onTap: () => select('arrival'),
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
    required this.repository,
    required this.selectedLocationIds,
  });

  final MockTmsRepository repository;
  final Set<String> selectedLocationIds;

  @override
  State<_AddDropLocationSheet> createState() => _AddDropLocationSheetState();
}

class _AddDropLocationSheetState extends State<_AddDropLocationSheet> {
  TmsOption? _location;
  DateTime? _date;
  TimeOfDay? _time;

  Future<void> _selectLocation() async {
    final locations = await widget.repository.options('deliveryLocations');
    if (!mounted) return;
    final location = await showOptionSheet(
      context,
      title: 'Drop location',
      options: locations
          .where((item) => !widget.selectedLocationIds.contains(item.id))
          .toList(),
    );
    if (!mounted || location == null) return;
    setState(() => _location = location);
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
