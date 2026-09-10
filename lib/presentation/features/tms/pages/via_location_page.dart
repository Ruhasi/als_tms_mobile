import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/transport_booking/create_transport_booking_request.dart';
import '../../../../domain/transport_booking/lookup_item.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/booking_lookup_sheet.dart';
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class ViaLocationPage extends HookConsumerWidget {
  const ViaLocationPage({super.key, required this.unloadingOrder});

  final int unloadingOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookups = ref.read(bookingLookupRepositoryProvider);
    final location = useState<LookupItem?>(null);
    final locations = useState<List<LookupItem>>(const []);
    final arrival = useState<DateTime?>(null);
    final referenceNo = useTextEditingController();
    final contactPerson = useTextEditingController();
    final contactNo = useTextEditingController();
    final showErrors = useState(false);

    useEffect(() {
      Future<void> preload() async {
        final results = await Future.wait([lookups.locations('')]);
        if (!context.mounted) return;
        results[0].fold((_) {}, (items) {
          locations.value = items;
          if (items.length == 1) location.value = items.first;
        });
      }

      preload();
      return null;
    }, const []);

    Future<LookupItem?> selectLookup({
      required String title,
      required LookupSearch search,
      required List<LookupItem> initialItems,
      bool searchLocally = false,
    }) => showBookingLookupSheet(
      context,
      title: title,
      search: search,
      initialItems: initialItems,
      searchLocally: searchLocally,
    );

    Future<void> selectArrival() async {
      final value = await _showDateTimeWheel(
        context,
        initialDate: arrival.value,
      );
      if (value != null) arrival.value = value;
    }

    void save() {
      if (location.value == null || arrival.value == null) {
        showErrors.value = true;
        return;
      }
      context.router.pop(
        ViaLocationRequest(
          viaLocationSeq: location.value!.seq,
          locationName: location.value!.name,
          viaLocationAddress: location.value!.name,
          unloadingOrder: unloadingOrder,
          requestedArrivalTime: arrival.value!,
          referenceNo: referenceNo.text.trim(),
          contactPerson: contactPerson.text.trim(),
          contactNo: contactNo.text.trim(),
        ),
      );
    }

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
                  Expanded(
                    child: Text(
                      'ADD VIA LOCATION #$unloadingOrder',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
                  _sectionLabel('ROUTE DETAILS'),
                  SelectorTile(
                    label: 'Location',
                    value: location.value?.name ?? 'Search and select location',
                    hasError: showErrors.value && location.value == null,
                    onTap: () async {
                      final selected = await selectLookup(
                        title: 'Location',
                        search: lookups.locations,
                        initialItems: locations.value,
                      );
                      if (selected != null) location.value = selected;
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectorTile(
                    label: 'Requested arrival date & time',
                    value: _dateTimeLabel(context, arrival.value),
                    hasError: showErrors.value && arrival.value == null,
                    onTap: selectArrival,
                  ),
                  _sectionLabel('CONTACT DETAILS'),
                  _FormTextField(
                    controller: referenceNo,
                    label: 'Reference number',
                  ),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: contactPerson,
                    label: 'Contact person',
                  ),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: contactNo,
                    label: 'Contact number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TmsButton(label: 'Add via location', onPressed: save),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 54),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: TmsColors.line),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: TmsColors.muted,
          ),
        ),
        const SizedBox(height: 1),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TmsColors.muted,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
}

Widget _sectionLabel(String value) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 8),
  child: Text(
    value,
    style: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w900,
      color: TmsColors.muted,
      letterSpacing: .6,
    ),
  ),
);

Future<DateTime?> _showDateTimeWheel(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  var selected = initialDate ?? DateTime.now();
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Done'),
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: selected,
              onDateTimeChanged: (value) => selected = value,
            ),
          ),
        ],
      ),
    ),
  );
}

String _dateTimeLabel(BuildContext context, DateTime? value) {
  if (value == null) return 'Select date and time';
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatMediumDate(value)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}
