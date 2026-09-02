import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../domain/core/app_failure.dart';
import '../../../domain/transport_booking/lookup_item.dart';
import '../theme/tms_theme.dart';

typedef LookupSearch =
    Future<Either<NetworkFailure, List<LookupItem>>> Function(String query);

Future<LookupItem?> showBookingLookupSheet(
  BuildContext context, {
  required String title,
  required LookupSearch search,
  required List<LookupItem> initialItems,
  bool searchLocally = false,
}) {
  return showModalBottomSheet<LookupItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TmsColors.canvas,
    showDragHandle: true,
    builder: (_) => _BookingLookupSheet(
      title: title,
      search: search,
      initialItems: initialItems,
      searchLocally: searchLocally,
    ),
  );
}

class _BookingLookupSheet extends StatefulWidget {
  const _BookingLookupSheet({
    required this.title,
    required this.search,
    required this.initialItems,
    required this.searchLocally,
  });
  final String title;
  final LookupSearch search;
  final List<LookupItem> initialItems;
  final bool searchLocally;
  @override
  State<_BookingLookupSheet> createState() => _BookingLookupSheetState();
}

class _BookingLookupSheetState extends State<_BookingLookupSheet> {
  Timer? _debounce;
  late List<LookupItem> _items;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.search(query);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (items) => setState(() {
        _loading = false;
        _items = items;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
            CupertinoSearchTextField(
              onChanged: (value) {
                _debounce?.cancel();
                if (widget.searchLocally) {
                  final query = value.trim().toLowerCase();
                  setState(() {
                    _error = null;
                    _items = query.isEmpty
                        ? widget.initialItems
                        : widget.initialItems
                              .where(
                                (item) =>
                                    item.name.toLowerCase().contains(query) ||
                                    item.code.toLowerCase().contains(query),
                              )
                              .toList();
                  });
                  return;
                }
                if (value.trim().length < 3) {
                  setState(() => _items = widget.initialItems);
                  return;
                }
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => _load(value.trim()),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final item = _items[index];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          child: ListTile(
                            onTap: () => Navigator.pop(context, item),
                            title: Text(item.name),
                            subtitle: item.code.isEmpty
                                ? null
                                : Text(item.code),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
