import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../../application/dashboard/mobile_dashboard_providers.dart';
import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../../domain/transport_booking/create_transport_booking_request.dart';
import '../../../../domain/transport_booking/lookup_item.dart';
import '../../../../domain/transport_booking/transport_booking.dart';
import '../../../../domain/transport_booking/vehicle_assignment.dart';
import '../../../../infrastructure/transport_booking/booking_lookup_repository.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/booking_lookup_sheet.dart';
import '../../../core/widgets/tms_widgets.dart';
import '../widgets/vehicle_assignment_sheet.dart';

@RoutePage()
class JobDetailPage extends HookConsumerWidget {
  const JobDetailPage({super.key, @PathParam('jobId') required this.jobId});
  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final workflowStatus = useState<String?>(null);
    final arrival = useState<String?>(null);
    final delivery = useState<String?>(null);
    final assignedVehicle = useState<String?>(null);
    final assignedDriver = useState<String?>(null);
    final isAssigningVehicle = useState(false);
    final isLoadingAssignmentDetails = useState(false);
    final vehicleAssignments = ref.read(vehicleAssignmentRepositoryProvider);
    final bookingRepository = ref.read(transportBookingRepositoryProvider);
    final isUpdatingFlag = useState(false);
    final isDeleting = useState(false);
    final isAddingViaLocations = useState(false);

    return ref
        .watch(transportBookingDetailProvider(jobId))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) =>
              const Scaffold(body: Center(child: Text('Job unavailable'))),
          data: (result) => result.fold(
            (failure) => Scaffold(body: Center(child: Text(failure.message))),
            (booking) {
              final job = _asDisplayJob(booking);
              final status =
                  workflowStatus.value ?? booking.currentStatusDescription;
              final requestedArrival =
                  arrival.value ?? booking.requestedArrivalTime;
              final requestedDelivery =
                  delivery.value ?? booking.requestedDeliveryTime;
              final canEdit =
                  booking.currentStatus == 3 || booking.currentStatus == 4;
              final needsVehicle = booking.currentStatus == 3;
              final hasVehicleAssignment =
                  booking.currentStatus >= 4 && booking.currentStatus <= 13;
              final vehicle =
                  assignedVehicle.value ??
                  (needsVehicle ? 'Awaiting vehicle' : booking.vehicleTypeName);
              final driver =
                  assignedDriver.value ??
                  (needsVehicle ? 'Not assigned' : 'Assigned');

              Future<void> assignVehicle({bool isEditing = false}) async {
                final result = await context.router
                    .push<VehicleAssignmentResult>(
                      VehicleAssignmentRoute(
                        customerSeq: booking.customerSeq,
                        vehicleType: booking.vehicleTypeName,
                        vehicle: isVehicleUnassigned(vehicle) ? '' : vehicle,
                        driver: driver.isEmpty || driver == 'Not assigned'
                            ? ''
                            : driver,
                      ),
                    );
                if (!context.mounted) return;
                if (result == null) return;
                if (result.transportCompanySeq == null ||
                    result.vehicleSeq == null ||
                    result.driverSeq == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Select a transporter, vehicle, and driver before saving.',
                      ),
                    ),
                  );
                  return;
                }
                isAssigningVehicle.value = true;
                final assignmentResult = await vehicleAssignments.assign(
                  VehicleAssignmentRequest(
                    transportBookingSeq: booking.transportBookingSeq,
                    transportCompanySeq: result.transportCompanySeq!,
                    vehicleSeq: result.vehicleSeq!,
                    driverSeq: result.driverSeq!,
                    helperSeq: result.helperSeq,
                    trailerSeq: result.trailerSeq,
                    payableVehicleTypeSeq: booking.vehicleTypeSeq,
                  ),
                );
                if (!context.mounted) return;
                isAssigningVehicle.value = false;
                final assigned = assignmentResult.fold((failure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message)));
                  return false;
                }, (_) => true);
                if (!assigned) return;
                assignedVehicle.value = result.vehicle;
                assignedDriver.value = result.driver;
                ref.invalidate(transportBookingDetailProvider(jobId));
                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      isEditing
                          ? 'Vehicle assignment updated'
                          : 'Vehicle assigned',
                    ),
                    content: Text(
                      isEditing
                          ? 'The vehicle and driver were updated successfully.'
                          : 'The vehicle assignment was saved successfully.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }

              Future<void> viewVehicleAssignment() async {
                isLoadingAssignmentDetails.value = true;
                final result = await vehicleAssignments.details(
                  booking.transportBookingSeq,
                );
                if (!context.mounted) return;
                isLoadingAssignmentDetails.value = false;
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
                  (details) => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: TmsColors.canvas,
                    showDragHandle: true,
                    builder: (sheetContext) => _vehicleAssignmentDetailsSheet(
                      details,
                      styles,
                      onEdit: () {
                        Navigator.pop(sheetContext);
                        assignVehicle(isEditing: true);
                      },
                    ),
                  ),
                );
              }

              void viewViaLocations() {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: TmsColors.canvas,
                  showDragHandle: true,
                  builder: (sheetContext) => _viaLocationDetailsSheet(
                    booking.viaLocations,
                    styles,
                    onDelete: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete all via locations?'),
                          content: const Text(
                            'This will remove every via location from this job request.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: TmsColors.red,
                              ),
                              child: const Text('Delete all'),
                            ),
                          ],
                        ),
                      );
                      if (!context.mounted || confirmed != true) return false;

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const PopScope(
                          canPop: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                      final result = await bookingRepository.deleteViaLocations(
                        booking.transportBookingSeq,
                      );
                      if (!context.mounted) return false;
                      Navigator.of(context, rootNavigator: true).pop();
                      return result.fold(
                        (failure) async {
                          await showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text(
                                'Unable to delete via locations',
                              ),
                              content: Text(failure.message),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return false;
                        },
                        (_) async {
                          ref.invalidate(transportBookingDetailProvider(jobId));
                          ref.invalidate(transportBookingsProvider);
                          await showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Via locations deleted'),
                              content: const Text(
                                'All via locations were removed successfully.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          return true;
                        },
                      );
                    },
                  ),
                );
              }

              Future<void> addViaLocation() async {
                final viaLocation = await context.router
                    .push<ViaLocationRequest>(
                      ViaLocationRoute(
                        unloadingOrder: booking.viaLocations.length + 1,
                      ),
                    );
                if (!context.mounted || viaLocation == null) return;

                isAddingViaLocations.value = true;
                final result = await bookingRepository.addViaLocations(
                  transportBookingSeq: booking.transportBookingSeq,
                  viaLocations: [viaLocation],
                );
                if (!context.mounted) return;
                isAddingViaLocations.value = false;
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
                  (_) {
                    ref.invalidate(transportBookingDetailProvider(jobId));
                    ref.invalidate(transportBookingsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Via location added.')),
                    );
                  },
                );
              }

              Future<void> updateFlag() async {
                final nextIsFlagged = !booking.isFlagged;
                final action = nextIsFlagged ? 'flag' : 'resolve the flag on';
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      nextIsFlagged ? 'Flag job request?' : 'Resolve flag?',
                    ),
                    content: Text(
                      'Do you want to $action ${booking.bookingNo}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(nextIsFlagged ? 'Flag' : 'Resolve'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted || confirmed != true) return;

                isUpdatingFlag.value = true;
                final result = await bookingRepository.updateFlagStatus(
                  transportBookingSeq: booking.transportBookingSeq,
                  isFlagged: nextIsFlagged,
                );
                if (!context.mounted) return;
                isUpdatingFlag.value = false;
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
                  (_) {
                    ref.invalidate(transportBookingDetailProvider(jobId));
                    ref.invalidate(transportBookingsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          nextIsFlagged
                              ? 'Job request flagged.'
                              : 'Job request flag resolved.',
                        ),
                      ),
                    );
                  },
                );
              }

              Future<void> deleteBooking() async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete job request?'),
                    content: Text(
                      'This will permanently delete ${booking.bookingNo}.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: TmsColors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted || confirmed != true) return;

                isDeleting.value = true;
                final result = await bookingRepository.deleteBooking(
                  booking.transportBookingSeq,
                );
                if (!context.mounted) return;
                isDeleting.value = false;
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
                  (_) {
                    ref.invalidate(transportBookingsProvider);
                    ref.invalidate(mobileDashboardProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job request deleted.')),
                    );
                    context.router.maybePop();
                  },
                );
              }

              return Scaffold(
                backgroundColor: TmsColors.canvas,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: 116.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        color: TmsColors.ink,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _headerAction(
                              context,
                              CupertinoIcons.chevron_back,
                              () => context.router.maybePop(),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.id,
                                    style: styles.labelSmall.copyWith(
                                      color: TmsColors.textGray,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'JOB REQUEST',
                                    style: styles.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      letterSpacing: .4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isUpdatingFlag.value
                                ? SizedBox(
                                    width: 42.w,
                                    height: 42.h.toDouble(),
                                    child: const Center(
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : _headerAction(
                                    context,
                                    booking.isFlagged
                                        ? CupertinoIcons.flag_fill
                                        : CupertinoIcons.flag,
                                    updateFlag,
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 94.h),
                          children: [
                            // Container(
                            //   padding: EdgeInsets.all(14.w),
                            //   decoration: BoxDecoration(
                            //     color: const Color(0xFFFFEEE6),
                            //     borderRadius: BorderRadius.circular(11.r),
                            //     border: Border.all(
                            //       color: const Color(0xFFF7DECF),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text(
                            //         'Editable for 38 more minutes',
                            //         style: styles.bodyMedium.copyWith(
                            //           color: TmsColors.orange,
                            //           fontWeight: FontWeight.w900,
                            //         ),
                            //       ),
                            //       SizedBox(height: 3.h),
                            //       Text(
                            //         'Changes after the window need a dispatcher\namendment.',
                            //         style: styles.bodySmall.copyWith(
                            //           fontSize: 11.sp,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            if (needsVehicle) ...[
                              SizedBox(height: 13.h),
                              _assignVehicleBanner(
                                styles,
                                isLoading: isAssigningVehicle.value,
                                onAssign: assignVehicle,
                              ),
                            ] else if (hasVehicleAssignment) ...[
                              SizedBox(height: 13.h),
                              _viewVehicleAssignmentBanner(
                                styles,
                                isLoading: isLoadingAssignmentDetails.value,
                                onView: viewVehicleAssignment,
                              ),
                            ],
                            if (booking.viaLocations.isNotEmpty) ...[
                              SizedBox(height: 13.h),
                              _viewViaLocationsBanner(
                                styles,
                                count: booking.viaLocations.length,
                                onView: viewViaLocations,
                              ),
                            ] else if (canEdit) ...[
                              SizedBox(height: 13.h),
                              _addViaLocationsBanner(
                                styles,
                                isLoading: isAddingViaLocations.value,
                                onAdd: addViaLocation,
                              ),
                            ],
                            SizedBox(height: 13.h),
                            _routeCard(
                              job,
                              styles,
                              status,
                              requestedArrival,
                              requestedDelivery,
                              () => _showStatusPicker(
                                context,
                                styles,
                                status,
                                (value) => workflowStatus.value = value,
                              ),
                            ),
                            SizedBox(height: 13.h),
                            _detailCard(
                              booking,
                              styles,
                              vehicle: needsVehicle
                                  ? 'Awaiting vehicle'
                                  : vehicle,
                              driver: needsVehicle ? 'Not assigned' : driver,
                            ),
                            SizedBox(height: 15.h),
                            // Text(
                            //   'ACTIVITY',
                            //   style: styles.labelSmall.copyWith(
                            //     fontSize: 11.sp,
                            //     letterSpacing: 1.4,
                            //   ),
                            // ),
                            // SizedBox(height: 9.h),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: 14.w,
                            //     vertical: 12.h,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(12.r),
                            //   ),
                            //   child: Column(
                            //     children: job.comments
                            //         .map(
                            //           (comment) =>
                            //               _activityRow(comment, styles),
                            //         )
                            //         .toList(),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
                        color: TmsColors.canvas,
                        child: Column(
                          children: [
                            // if (needsVehicle) ...[
                            //   TmsButton(
                            //     label: 'Assign vehicle',
                            //     onPressed: assignVehicle,
                            //   ),
                            //   SizedBox(height: 10.h),
                            // ],
                            Row(
                              children: [
                                if (canEdit)
                                  Expanded(
                                    child: TmsButton(
                                      dark: true,
                                      label: 'Edit',
                                      onPressed: () => _showEditJobForm(
                                        context,
                                        styles,
                                        booking: booking,
                                        lookups: ref.read(
                                          bookingLookupRepositoryProvider,
                                        ),
                                        onSave: (update) async {
                                          final result = await bookingRepository
                                              .updateSchedule(
                                                booking: booking,
                                                department: update.department,
                                                customer: update.customer,
                                                shipper: update.shipper,
                                                invoiceCustomer:
                                                    update.invoiceCustomer,
                                                invoiceStatus:
                                                    update.invoiceStatus,
                                                vehicleType: update.vehicleType,
                                                pickupLocation:
                                                    update.pickupLocation,
                                                requestedArrivalTime:
                                                    update.requestedArrivalTime,
                                                deliveryLocation:
                                                    update.deliveryLocation,
                                                requestedDeliveryTime: update
                                                    .requestedDeliveryTime,
                                              );
                                          if (!context.mounted) return false;
                                          return result.fold(
                                            (failure) async {
                                              await showDialog<void>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Unable to update job',
                                                      ),
                                                      content: Text(
                                                        failure.message,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                              ),
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              return false;
                                            },
                                            (_) async {
                                              arrival.value =
                                                  update.requestedArrivalTime;
                                              delivery.value =
                                                  update.requestedDeliveryTime;
                                              ref.invalidate(
                                                transportBookingDetailProvider(
                                                  jobId,
                                                ),
                                              );
                                              ref.invalidate(
                                                transportBookingsProvider,
                                              );
                                              ref.invalidate(
                                                mobileDashboardProvider,
                                              );
                                              await showDialog<void>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Job request updated',
                                                      ),
                                                      content: const Text(
                                                        'The job request was updated successfully.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                              ),
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              return true;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                if (canEdit) SizedBox(width: 10.w),
                                Expanded(
                                  child: SizedBox(
                                    height: 48.h,
                                    child: OutlinedButton(
                                      onPressed: isDeleting.value
                                          ? null
                                          : deleteBooking,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: TmsColors.red,
                                        side: const BorderSide(
                                          color: TmsColors.line,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            9.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isDeleting.value
                                            ? 'Cancelling...'
                                            : 'Cancel job',
                                        style: styles.bodyMedium.copyWith(
                                          color: TmsColors.red,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}

Widget _assignVehicleBanner(
  dynamic styles, {
  required VoidCallback onAssign,
  required bool isLoading,
}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  child: InkWell(
    onTap: isLoading ? null : onAssign,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF7DECF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle not assigned',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Assign a vehicle and driver to continue this request.',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: TmsColors.orange,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CupertinoActivityIndicator(color: Colors.white),
                  )
                : Text(
                    'Assign',
                    style: styles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
          ),
        ],
      ),
    ),
  ),
);

Widget _viewVehicleAssignmentBanner(
  dynamic styles, {
  required VoidCallback onView,
  required bool isLoading,
}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  child: InkWell(
    onTap: isLoading ? null : onView,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TmsColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: TmsColors.green),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle assignment available',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'View assignment and route details.',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          isLoading
              ? const CupertinoActivityIndicator()
              : const Icon(Icons.chevron_right, color: TmsColors.muted),
        ],
      ),
    ),
  ),
);

Widget _viewViaLocationsBanner(
  dynamic styles, {
  required int count,
  required VoidCallback onView,
}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  child: InkWell(
    onTap: onView,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TmsColors.line),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.map_pin_ellipse, color: TmsColors.orange),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Via locations available',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '$count scheduled ${count == 1 ? 'drop' : 'drops'}. Tap to view details.',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: TmsColors.muted),
        ],
      ),
    ),
  ),
);

Widget _addViaLocationsBanner(
  dynamic styles, {
  required bool isLoading,
  required VoidCallback onAdd,
}) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  child: InkWell(
    onTap: isLoading ? null : onAdd,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TmsColors.line),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.map_pin_ellipse, color: TmsColors.orange),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add via location',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Add an intermediate delivery or collection stop.',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          isLoading
              ? const CupertinoActivityIndicator()
              : const Icon(Icons.add_circle_outline, color: TmsColors.orange),
        ],
      ),
    ),
  ),
);

Widget _viaLocationDetailsSheet(
  List<ViaLocationDetail> locations,
  dynamic styles, {
  required Future<bool> Function() onDelete,
}) => SafeArea(
  child: Padding(
    padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('VIA LOCATIONS', style: styles.titleMedium)),
              IconButton(
                tooltip: 'Delete all via locations',
                onPressed: () async => onDelete(),
                icon: const Icon(CupertinoIcons.delete, color: TmsColors.red),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${locations.length} scheduled via ${locations.length == 1 ? 'location' : 'locations'}',
            style: styles.bodySmall,
          ),
          SizedBox(height: 16.h),
          ...locations.map(
            (location) => Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: TmsColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIA ${location.unloadingOrder}',
                    style: styles.labelSmall.copyWith(
                      color: TmsColors.orange,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _detailLine(
                    'Location',
                    location.viaLocationName.isEmpty
                        ? location.viaLocationAddress
                        : location.viaLocationName,
                    styles,
                  ),
                  if (location.viaLocationAddress.isNotEmpty &&
                      location.viaLocationAddress != location.viaLocationName)
                    _detailLine('Address', location.viaLocationAddress, styles),
                  _detailLine(
                    'Requested arrival date & time',
                    location.requestedArrivalTime,
                    styles,
                  ),
                  if (location.dropPickStatusDescription.isNotEmpty)
                    _detailLine(
                      'Drop / pick status',
                      location.dropPickStatusDescription,
                      styles,
                    ),
                  if (location.contactPerson.isNotEmpty)
                    _detailLine(
                      'Contact person',
                      location.contactPerson,
                      styles,
                    ),
                  if (location.contactNo.isNotEmpty)
                    _detailLine('Contact number', location.contactNo, styles),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

Widget _vehicleAssignmentDetailsSheet(
  VehicleAssignmentDetails details,
  dynamic styles, {
  required VoidCallback onEdit,
}) => SafeArea(
  child: Padding(
    padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VEHICLE ASSIGNMENT', style: styles.titleMedium),
          SizedBox(height: 16.h),
          _detailLine('Booking', details.bookingNo, styles),
          _detailLine('Job number', details.jobNo, styles),
          _detailLine('Customer', details.customerName, styles),
          _detailLine('Vehicle type', details.vehicleTypeName, styles),
          _detailLine('Pickup', details.pickupLocation, styles),
          _detailLine('Delivery', details.deliveryLocation, styles),
          _detailLine(
            'Requested arrival date & time',
            details.requestedArrivalTime,
            styles,
          ),
          _detailLine(
            'Requested delivery date & time',
            details.requestedDeliveryTime,
            styles,
          ),
          _detailLine(
            'Estimated distance',
            '${details.estimatedKm} km',
            styles,
          ),
          _detailLine(
            'Customer reference',
            details.customerReferenceNo,
            styles,
          ),
          if (details.viaLocationString.isNotEmpty)
            _detailLine('Via locations', details.viaLocationString, styles),
          SizedBox(height: 24.h),
          TmsButton(label: 'Edit assignment', onPressed: onEdit),
        ],
      ),
    ),
  ),
);

TmsJob _asDisplayJob(TransportBookingDetail booking) => TmsJob(
  id: booking.bookingNo,
  status: switch (booking.currentStatus) {
    1 => JobStatus.requested,
    2 || 3 => JobStatus.accepted,
    4 || 5 || 6 || 7 => JobStatus.inTransit,
    8 || 9 || 10 || 11 || 12 || 13 => JobStatus.delivered,
    101 => JobStatus.cancelled,
    _ => JobStatus.requested,
  },
  pickup: booking.pickupLocationName.isEmpty
      ? booking.pickupLocationAddress
      : booking.pickupLocationName,
  destination: booking.deliveryLocationName.isEmpty
      ? booking.deliveryLocationAddress
      : booking.deliveryLocationName,
  pickupTime: booking.requestedArrivalTime,
  deliveryTime: booking.requestedDeliveryTime,
  customer: booking.customerName,
  shipper: booking.shipperName,
  invoiceTo: '',
  provider: '',
  vehicle: '',
  driver: '',
);

Widget _headerAction(BuildContext context, IconData icon, VoidCallback onTap) =>
    Material(
      color: const Color(0xFF202631),
      borderRadius: BorderRadius.circular(11.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(11.r),
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(icon, color: Colors.white, size: 18.sp),
        ),
      ),
    );

Widget _routeCard(
  TmsJob job,
  dynamic styles,
  String workflowStatus,
  String arrival,
  String delivery,
  VoidCallback changeStatus,
) => Container(
  padding: EdgeInsets.all(15.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            'ROUTE',
            style: styles.labelSmall.copyWith(
              fontSize: 11.sp,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _statusColor(workflowStatus).withValues(alpha: .13),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workflowStatus.toUpperCase(),
                    style: styles.labelSmall.copyWith(
                      fontSize: 8.sp,
                      color: _statusColor(workflowStatus),
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 15.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(CupertinoIcons.circle, size: 14.sp, color: TmsColors.muted),
              Container(width: 2.w, height: 39.h, color: TmsColors.line),
              Container(width: 9.w, height: 9.w, color: TmsColors.orange),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.pickup,
                  style: styles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Requested arrival date & time: $arrival',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
                SizedBox(height: 14.h),
                Text(
                  job.destination,
                  style: styles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Requested delivery date & time: $delivery',
                  style: styles.bodySmall.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);

Widget _detailCard(
  TransportBookingDetail booking,
  dynamic styles, {
  required String vehicle,
  required String driver,
}) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: Column(
    children: [
      _detailLine('Company', booking.companyProfileName, styles),
      _detailLine('Department', booking.departmentName, styles),
      _detailLine('Module', booking.moduleName, styles),
      _detailLine('Customer', booking.customerName, styles),
      _detailLine('Shipper', booking.shipperName, styles),
      _detailLine('Job number', booking.jobNo, styles),
      _detailLine('Customer reference', booking.customerReferenceNo, styles),
      _detailLine('Vehicle type', booking.vehicleTypeName, styles),
      _detailLine('Vehicle', vehicle, styles),
      _detailLine('Driver', driver, styles),
      _detailLine('Payment mode', booking.paymentModeDescription, styles),
      _detailLine('Cash / credit', booking.cashOrCreditDescription, styles),
      _detailLine('Invoice status', booking.invoiceStatusDescription, styles),
      _detailLine('Pieces', booking.pieces.toString(), styles),
      _detailLine('Weight', booking.weight.toString(), styles),
      _detailLine('Volume', booking.volume.toString(), styles),
      _detailLine('CBM', booking.cbm.toString(), styles),
      _detailLine('Created by', booking.createdBy, styles),
      _detailLine('Created date', booking.createdDate, styles),
      _detailLine(
        'Last modified',
        booking.lastModifiedDate,
        styles,
        isLast: true,
      ),
    ],
  ),
);

Widget _detailLine(
  String label,
  String value,
  dynamic styles, {
  bool isLast = false,
}) => Container(
  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
  decoration: BoxDecoration(
    border: isLast
        ? null
        : Border(
            bottom: BorderSide(color: TmsColors.line.withValues(alpha: .7)),
          ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        flex: 3,
        child: Text(label, style: styles.bodySmall.copyWith(fontSize: 12.sp)),
      ),

      Expanded(
        flex: 2,
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: styles.bodyMedium.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  ),
);

// ignore: unused_element
Widget _activityRow(JobComment comment, dynamic styles) => Padding(
  padding: EdgeInsets.only(bottom: 12.h),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 15.r,
        backgroundColor: TmsColors.canvas,
        child: Text(
          comment.author.substring(0, 2).toUpperCase(),
          style: styles.labelSmall.copyWith(fontSize: 8.sp),
        ),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.author,
              style: styles.bodyMedium.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              comment.message,
              style: styles.bodySmall.copyWith(
                fontSize: 12.sp,
                color: TmsColors.ink,
              ),
            ),
            SizedBox(height: 2.h),
            Text('09:12', style: styles.bodySmall.copyWith(fontSize: 10.sp)),
          ],
        ),
      ),
    ],
  ),
);

const _workflowStatuses = [
  'All',
  'Pending for Approval',
  'Approved',
  'Accepted',
  'Attended',
  'In transit',
  'Arrived At Pickup',
  'Departed From Pickup',
  'Arrived at Delivery',
  'Job Completed',
  'Km Confirmed',
  'Charged Submitted',
  'Job Confirmed',
  'Finance Confirmed',
  'Job Closed',
  'Cancelled',
];

// Legacy cancellation UI retained pending removal of unused mock activity code.
// ignore: unused_element
Future<void> _showCancelReasonPicker(BuildContext context, dynamic styles) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: TmsColors.canvas,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CANCEL WITH A REASON', style: styles.titleMedium),
            SizedBox(height: 5.h),
            Text(
              'Select why this job request should be cancelled.',
              style: styles.bodySmall,
            ),
            SizedBox(height: 12.h),
            ...[
              'Customer requested',
              'Vehicle unavailable',
              'Duplicate request',
              'Schedule conflict',
              'Other',
            ].map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(reason, style: styles.bodyMedium),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job cancelled: $reason')),
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

Future<void> _showStatusPicker(
  BuildContext context,
  dynamic styles,
  String selected,
  ValueChanged<String> onChanged,
) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: TmsColors.canvas,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UPDATE JOB STATUS', style: styles.titleMedium),
            SizedBox(height: 10.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _workflowStatuses.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: TmsColors.line),
                itemBuilder: (_, index) {
                  final status = _workflowStatuses[index];
                  final isSelected =
                      status.toLowerCase() == selected.toLowerCase();
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 6.w),
                    title: Text(
                      status,
                      style: styles.bodyMedium.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w500,
                        color: isSelected ? TmsColors.orange : TmsColors.ink,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: TmsColors.orange,
                          )
                        : null,
                    onTap: () {
                      onChanged(status);
                      Navigator.pop(sheetContext);
                    },
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

Future<void> _showEditJobForm(
  BuildContext context,
  dynamic styles, {
  required TransportBookingDetail booking,
  required BookingLookupRepository lookups,
  required Future<bool> Function(_EditJobUpdate update) onSave,
}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: TmsColors.canvas,
  showDragHandle: true,
  builder: (_) => _EditJobForm(
    styles: styles,
    booking: booking,
    lookups: lookups,
    onSave: onSave,
  ),
);

class _EditJobUpdate {
  const _EditJobUpdate({
    required this.department,
    required this.customer,
    required this.shipper,
    required this.invoiceCustomer,
    required this.invoiceStatus,
    required this.vehicleType,
    required this.pickupLocation,
    required this.requestedArrivalTime,
    required this.deliveryLocation,
    required this.requestedDeliveryTime,
  });

  final LookupItem department;
  final LookupItem customer;
  final LookupItem shipper;
  final LookupItem invoiceCustomer;
  final int invoiceStatus;
  final LookupItem vehicleType;
  final LookupItem pickupLocation;
  final String requestedArrivalTime;
  final LookupItem deliveryLocation;
  final String requestedDeliveryTime;
}

class _EditJobForm extends StatefulWidget {
  const _EditJobForm({
    required this.styles,
    required this.booking,
    required this.lookups,
    required this.onSave,
  });

  final dynamic styles;
  final TransportBookingDetail booking;
  final BookingLookupRepository lookups;
  final Future<bool> Function(_EditJobUpdate update) onSave;

  @override
  State<_EditJobForm> createState() => _EditJobFormState();
}

class _EditJobFormState extends State<_EditJobForm> {
  late LookupItem _department;
  late LookupItem _customer;
  late LookupItem _shipper;
  late LookupItem _invoiceCustomer;
  late LookupItem _vehicleType;
  late LookupItem _pickupLocation;
  late LookupItem _deliveryLocation;
  late String _arrival;
  late String _delivery;
  late int _invoiceStatus;
  List<LookupItem> _departments = const [];
  List<LookupItem> _customers = const [];
  List<LookupItem> _shippers = const [];
  List<LookupItem> _locations = const [];
  List<LookupItem> _vehicleTypes = const [];
  var _isLoading = true;
  var _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final booking = widget.booking;
    _department = LookupItem(
      seq: booking.departmentSeq,
      name: booking.departmentName,
      code: '',
    );
    _customer = LookupItem(
      seq: booking.customerSeq,
      name: booking.customerName,
      code: '',
    );
    _shipper = LookupItem(
      seq: booking.shipperSeq,
      name: booking.shipperName,
      code: '',
    );
    _invoiceCustomer = LookupItem(
      seq: booking.invoiceCustomerSeq,
      name: booking.customerName,
      code: '',
    );
    _vehicleType = LookupItem(
      seq: booking.vehicleTypeSeq,
      name: booking.vehicleTypeName,
      code: '',
    );
    _pickupLocation = LookupItem(
      seq: booking.pickupLocationSeq,
      name: booking.pickupLocationName.isEmpty
          ? booking.pickupLocationAddress
          : booking.pickupLocationName,
      code: '',
    );
    _deliveryLocation = LookupItem(
      seq: booking.deliveryLocationSeq,
      name: booking.deliveryLocationName.isEmpty
          ? booking.deliveryLocationAddress
          : booking.deliveryLocationName,
      code: '',
    );
    _arrival = booking.requestedArrivalTime;
    _delivery = booking.requestedDeliveryTime;
    _invoiceStatus = booking.invoiceStatus;
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final results = await Future.wait([
      widget.lookups.departments(),
      widget.lookups.customers(''),
      widget.lookups.shippers(''),
      widget.lookups.locations(''),
      widget.lookups.vehicleTypes(_customer.seq),
    ]);
    if (!mounted) return;
    String? error;
    for (final result in results) {
      result.fold((failure) => error ??= failure.message, (_) {});
    }
    if (error != null) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      return;
    }
    setState(() {
      _departments = results[0].getOrElse(() => const []);
      _customers = results[1].getOrElse(() => const []);
      _shippers = results[2].getOrElse(() => const []);
      _locations = results[3].getOrElse(() => const []);
      _vehicleTypes = results[4].getOrElse(() => const []);
      _department = _fromItems(_departments, _department);
      _customer = _fromItems(_customers, _customer);
      _shipper = _fromItems(_shippers, _shipper);
      _invoiceCustomer = _fromItems(_customers, _invoiceCustomer);
      _vehicleType = _fromItems(_vehicleTypes, _vehicleType);
      _pickupLocation = _fromItems(_locations, _pickupLocation);
      _deliveryLocation = _fromItems(_locations, _deliveryLocation);
      _isLoading = false;
    });
  }

  LookupItem _fromItems(List<LookupItem> items, LookupItem current) {
    for (final item in items) {
      if (item.seq == current.seq) return item;
    }
    return current;
  }

  Future<void> _select(
    String title,
    LookupSearch search,
    List<LookupItem> initialItems,
    ValueChanged<LookupItem> onSelected,
  ) async {
    final selected = await showBookingLookupSheet(
      context,
      title: title,
      search: search,
      initialItems: initialItems,
    );
    if (!mounted || selected == null) return;
    onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeArea(
        child: SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 16.h),
                TmsButton(label: 'Try again', onPressed: _loadLookups),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18.w,
          4.h,
          18.w,
          18.h + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDIT JOB REQUEST',
                          style: widget.styles.titleLarge,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Update the job request details.',
                          style: widget.styles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: ListView(
                  children: [
                    _editSectionLabel('PARTIES'),
                    SelectorTile(
                      label: 'Department *',
                      value: _department.name,
                      onTap: () => _select(
                        'Department',
                        (_) => widget.lookups.departments(),
                        _departments,
                        (value) => setState(() => _department = value),
                      ),
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Customer *',
                      value: _customer.name,
                      onTap: () => _select(
                        'Customer',
                        widget.lookups.customers,
                        _customers,
                        (value) => setState(() {
                          _customer = value;
                          _vehicleType = LookupItem(
                            seq: 0,
                            name: 'Select vehicle type',
                            code: '',
                          );
                          _vehicleTypes = const [];
                        }),
                      ),
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Shipper *',
                      value: _shipper.name,
                      onTap: () => _select(
                        'Shipper',
                        widget.lookups.shippers,
                        _shippers,
                        (value) => setState(() => _shipper = value),
                      ),
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Invoice customer *',
                      value: _invoiceCustomer.name,
                      onTap: () => _select(
                        'Invoice customer',
                        widget.lookups.customers,
                        _customers,
                        (value) => setState(() => _invoiceCustomer = value),
                      ),
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Invoice status *',
                      value: _invoiceStatus == 1 ? 'Yes' : 'No',
                      onTap: () async {
                        final option = await showOptionSheet(
                          context,
                          title: 'Invoice status',
                          options: const [
                            TmsOption(id: '0', title: 'No', subtitle: ''),
                            TmsOption(id: '1', title: 'Yes', subtitle: ''),
                          ],
                        );
                        if (option != null) {
                          setState(() => _invoiceStatus = int.parse(option.id));
                        }
                      },
                    ),
                    _editSectionLabel('ROUTE'),
                    SelectorTile(
                      label: 'Vehicle type *',
                      value: _vehicleType.name,
                      onTap: () async {
                        final result = await widget.lookups.vehicleTypes(
                          _customer.seq,
                        );
                        if (!mounted) return;
                        final items = result.getOrElse(() => const []);
                        setState(() => _vehicleTypes = items);
                        await _select(
                          'Vehicle type',
                          (_) => widget.lookups.vehicleTypes(_customer.seq),
                          items,
                          (value) => setState(() => _vehicleType = value),
                        );
                      },
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Pickup location *',
                      value: _pickupLocation.name,
                      onTap: () => _select(
                        'Pickup location',
                        widget.lookups.locations,
                        _locations,
                        (value) => setState(() => _pickupLocation = value),
                      ),
                    ),
                    _editGap(),
                    _dateField(
                      context,
                      widget.styles,
                      'Requested arrival date & time *',
                      _arrival,
                      () async {
                        final value = await _pickDateTime(
                          context,
                          initialValue: _arrival,
                        );
                        if (value != null) setState(() => _arrival = value);
                      },
                    ),
                    _editGap(),
                    SelectorTile(
                      label: 'Delivery location *',
                      value: _deliveryLocation.name,
                      onTap: () => _select(
                        'Delivery location',
                        widget.lookups.locations,
                        _locations,
                        (value) => setState(() => _deliveryLocation = value),
                      ),
                    ),
                    _editGap(),
                    _dateField(
                      context,
                      widget.styles,
                      'Requested delivery date & time *',
                      _delivery,
                      () async {
                        final value = await _pickDateTime(
                          context,
                          initialValue: _delivery,
                        );
                        if (value != null) setState(() => _delivery = value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              TmsButton(
                label: _isSaving ? 'Saving...' : 'Save changes',
                onPressed: _isSaving || _vehicleType.seq == 0
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        final navigator = Navigator.of(context);
                        final saved = await widget.onSave(
                          _EditJobUpdate(
                            department: _department,
                            customer: _customer,
                            shipper: _shipper,
                            invoiceCustomer: _invoiceCustomer,
                            invoiceStatus: _invoiceStatus,
                            vehicleType: _vehicleType,
                            pickupLocation: _pickupLocation,
                            requestedArrivalTime: _arrival,
                            deliveryLocation: _deliveryLocation,
                            requestedDeliveryTime: _delivery,
                          ),
                        );
                        if (!mounted) return;
                        if (saved) navigator.pop();
                        if (mounted) setState(() => _isSaving = false);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _editSectionLabel(String label) => Padding(
  padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
  child: Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: TmsColors.muted,
    ),
  ),
);

Widget _editGap() => SizedBox(height: 8.h);

Widget _dateField(
  BuildContext context,
  dynamic styles,
  String label,
  String value,
  VoidCallback onTap,
) => Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(9.r),
  child: InkWell(
    borderRadius: BorderRadius.circular(9.r),
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        border: Border.all(color: TmsColors.line),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: styles.labelSmall.copyWith(fontSize: 9.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.calendar, color: TmsColors.muted),
        ],
      ),
    ),
  ),
);

Future<String?> _pickDateTime(
  BuildContext context, {
  required String initialValue,
}) async {
  final initialDate =
      DateTime.tryParse(initialValue.replaceFirst(' ', 'T')) ?? DateTime.now();
  final now = DateTime.now();
  final value = await showOmniDateTimePicker(
    context: context,
    type: OmniDateTimePickerType.dateAndTime,
    initialDate: initialDate,
    // Existing bookings may predate the current date and must remain editable.
    firstDate: DateTime(2020),
    lastDate: now.add(const Duration(days: 365)),
    is24HourMode: true,
    isShowSeconds: false,
  );
  if (value == null) return null;
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

Color _statusColor(String status) {
  final value = status.toLowerCase();
  if (value.contains('cancel')) {
    return TmsColors.red;
  }
  if (value.contains('completed') ||
      value.contains('closed') ||
      value.contains('finance')) {
    return TmsColors.green;
  }
  if (value.contains('transit') ||
      value.contains('departed') ||
      value.contains('arrived')) {
    return TmsColors.blue;
  }
  if (value.contains('request') || value.contains('pending')) {
    return TmsColors.gold;
  }
  return TmsColors.orange;
}
