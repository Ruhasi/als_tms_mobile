import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../infrastructure/tms/mock_tms_repository.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';

class VehicleAssignmentResult {
  const VehicleAssignmentResult({
    required this.vehicleType,
    required this.vehicle,
    required this.driver,
    required this.driverHelper,
    this.secondaryDriver = '',
    this.secondaryHelper = '',
    this.trailer = '',
    this.transportCompanySeq,
    this.vehicleSeq,
    this.driverSeq,
    this.helperSeq,
    this.trailerSeq,
    this.payableVehicleTypeSeq,
  });

  final String vehicleType;
  final String vehicle;
  final String driver;
  final String driverHelper;
  final String secondaryDriver;
  final String secondaryHelper;
  final String trailer;
  final int? transportCompanySeq;
  final int? vehicleSeq;
  final int? driverSeq;
  final int? helperSeq;
  final int? trailerSeq;
  final int? payableVehicleTypeSeq;
}

/// Shared assign-vehicle form used by new job request and job details.
Future<VehicleAssignmentResult?> showVehicleAssignmentSheet(
  BuildContext context, {
  String vehicleType = '',
  String vehicle = '',
  String driver = '',
  String driverHelper = '',
  MockTmsRepository? repository,
}) {
  final repo = repository ?? MockTmsRepository();
  return showModalBottomSheet<VehicleAssignmentResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TmsColors.canvas,
    showDragHandle: true,
    builder: (sheetContext) {
      var typeValue = vehicleType.isEmpty ? 'Select vehicle type' : vehicleType;
      var vehicleValue = vehicle.isEmpty ? 'Select vehicle' : vehicle;
      var driverValue = driver.isEmpty ? 'Select driver' : driver;
      var driverHelperValue = driverHelper;

      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pick(String type) async {
            final options = await repo.options(type);
            if (!context.mounted) return;
            final selected = await showOptionSheet(
              context,
              title: type,
              options: options,
            );
            if (selected == null) return;
            setModalState(() {
              if (type == 'vehicleType') {
                typeValue = selected.title;
              }
              if (type == 'vehicle') {
                vehicleValue =
                    '${selected.title} · ${selected.subtitle.split(' · ').first}';
                if (typeValue == 'Select vehicle type' &&
                    selected.subtitle.contains('ft')) {
                  typeValue = selected.subtitle.split(' · ').first;
                }
              }
              if (type == 'driver') {
                driverValue = selected.title;
                driverHelperValue = '';
              }
              if (type == 'driverHelper') {
                driverHelperValue = selected.title;
              }
            });
          }

          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASSIGN VEHICLE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4.h),
                  const Text(
                    'Vehicle assignment is optional until a truck is available.',
                    style: TextStyle(fontSize: 12, color: TmsColors.muted),
                  ),
                  SizedBox(height: 14.h),
                  SelectorTile(
                    label: 'Vehicle type',
                    value: typeValue,
                    onTap: () => pick('vehicleType'),
                  ),
                  SizedBox(height: 8.h),
                  SelectorTile(
                    label: 'Vehicle number',
                    value: vehicleValue,
                    onTap: () => pick('vehicle'),
                  ),
                  SizedBox(height: 8.h),
                  SelectorTile(
                    label: 'Driver',
                    value: driverValue,
                    onTap: () => pick('driver'),
                  ),
                  if (driverValue != 'Select driver') ...[
                    SizedBox(height: 8.h),
                    SelectorTile(
                      label: 'Driver helper (optional)',
                      value: driverHelperValue.isEmpty
                          ? 'Add driver helper'
                          : driverHelperValue,
                      onTap: () => pick('driverHelper'),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  TmsButton(
                    label: 'Save assignment',
                    onPressed: () {
                      final hasVehicle =
                          vehicleValue != 'Select vehicle' &&
                          vehicleValue.isNotEmpty;
                      final hasDriver =
                          driverValue != 'Select driver' &&
                          driverValue.isNotEmpty;
                      if (!hasVehicle || !hasDriver) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Select both a vehicle and a driver to assign.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(
                        sheetContext,
                        VehicleAssignmentResult(
                          vehicleType: typeValue == 'Select vehicle type'
                              ? '20 ft Container Truck'
                              : typeValue,
                          vehicle: vehicleValue,
                          driver: driverValue,
                          driverHelper: driverHelperValue,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: TmsColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

bool isVehicleUnassigned(String vehicle) {
  final value = vehicle.trim().toLowerCase();
  return value.isEmpty ||
      value == 'not assigned' ||
      value == 'awaiting vehicle' ||
      value == 'select vehicle';
}
