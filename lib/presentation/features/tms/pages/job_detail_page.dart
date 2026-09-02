import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../../domain/transport_booking/transport_booking.dart';
import '../../../../domain/transport_booking/vehicle_assignment.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
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
              final needsVehicle = booking.currentStatus == 3;
              final hasVehicleAssignment =
                  booking.currentStatus >= 4 && booking.currentStatus <= 13;
              final vehicle =
                  assignedVehicle.value ??
                  (needsVehicle ? 'Awaiting vehicle' : booking.vehicleTypeName);
              final driver =
                  assignedDriver.value ??
                  (needsVehicle ? 'Not assigned' : 'Assigned');

              Future<void> assignVehicle() async {
                final result = await context.router
                    .push<VehicleAssignmentResult>(
                      VehicleAssignmentRoute(
                        customerSeq: booking.customerSeq,
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
                    payableVehicleTypeSeq: result.payableVehicleTypeSeq,
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
                    title: const Text('Vehicle assigned'),
                    content: const Text(
                      'The vehicle assignment was saved successfully.',
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
                    builder: (_) =>
                        _vehicleAssignmentDetailsSheet(details, styles),
                  ),
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
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEE6),
                                borderRadius: BorderRadius.circular(11.r),
                                border: Border.all(
                                  color: const Color(0xFFF7DECF),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editable for 38 more minutes',
                                    style: styles.bodyMedium.copyWith(
                                      color: TmsColors.orange,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'Changes after the window need a dispatcher\namendment.',
                                    style: styles.bodySmall.copyWith(
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                            Text(
                              'ACTIVITY',
                              style: styles.labelSmall.copyWith(
                                fontSize: 11.sp,
                                letterSpacing: 1.4,
                              ),
                            ),
                            SizedBox(height: 9.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: job.comments
                                    .map(
                                      (comment) =>
                                          _activityRow(comment, styles),
                                    )
                                    .toList(),
                              ),
                            ),
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
                                Expanded(
                                  child: TmsButton(
                                    dark: true,
                                    label: 'Edit',
                                    onPressed: () => _showEditJobForm(
                                      context,
                                      styles,
                                      status,
                                      requestedArrival,
                                      requestedDelivery,
                                      (value) => workflowStatus.value = value,
                                      (value) => arrival.value = value,
                                      (value) => delivery.value = value,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: SizedBox(
                                    height: 48.h,
                                    child: OutlinedButton(
                                      onPressed: () => _showCancelReasonPicker(
                                        context,
                                        styles,
                                      ),
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
                                        'Cancel job',
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

Widget _vehicleAssignmentDetailsSheet(
  VehicleAssignmentDetails details,
  dynamic styles,
) => SafeArea(
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
            'Requested arrival',
            details.requestedArrivalTime,
            styles,
          ),
          _detailLine(
            'Requested delivery',
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
            onTap: changeStatus,
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
                  SizedBox(width: 4.w),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 10.sp,
                    color: _statusColor(workflowStatus),
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
                  'Arrival requested $arrival',
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
                  'Delivery requested $delivery',
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
        child: Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: styles.bodyMedium.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  ),
);

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
  dynamic styles,
  String workflowStatus,
  String arrival,
  String delivery,
  ValueChanged<String> onStatusChanged,
  ValueChanged<String> onArrivalChanged,
  ValueChanged<String> onDeliveryChanged,
) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: TmsColors.canvas,
  showDragHandle: true,
  builder: (sheetContext) {
    var status = workflowStatus;
    var arrivalValue = arrival;
    var deliveryValue = delivery;
    return StatefulBuilder(
      builder: (context, setModalState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            18.w,
            4.h,
            18.w,
            18.h + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EDIT JOB REQUEST', style: styles.titleLarge),
              SizedBox(height: 4.h),
              Text(
                'Update the activity status and requested schedule.',
                style: styles.bodySmall,
              ),
              SizedBox(height: 18.h),
              Text(
                'ACTIVITY STATUS',
                style: styles.labelSmall.copyWith(letterSpacing: 1.1),
              ),
              SizedBox(height: 7.h),
              DropdownButtonFormField<String>(
                initialValue: status,
                isExpanded: true,
                decoration: _formDecoration(),
                items: _workflowStatuses
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, style: styles.bodyMedium),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => status = value ?? status),
              ),
              SizedBox(height: 15.h),
              Text(
                'REQUESTED SCHEDULE',
                style: styles.labelSmall.copyWith(letterSpacing: 1.1),
              ),
              SizedBox(height: 7.h),
              _dateField(context, styles, 'Arrival', arrivalValue, () async {
                final date = await _pickDate(context, 'REQUESTED ARRIVAL DATE');
                if (date != null) {
                  setModalState(
                    () => arrivalValue = _formatDate(date, '09:00'),
                  );
                }
              }),
              SizedBox(height: 8.h),
              _dateField(context, styles, 'Delivery', deliveryValue, () async {
                final date = await _pickDate(
                  context,
                  'REQUESTED DELIVERY DATE',
                );
                if (date != null) {
                  setModalState(
                    () => deliveryValue = _formatDate(date, '16:30'),
                  );
                }
              }),
              SizedBox(height: 20.h),
              TmsButton(
                label: 'Save changes',
                onPressed: () {
                  onStatusChanged(status);
                  onArrivalChanged(arrivalValue);
                  onDeliveryChanged(deliveryValue);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  },
);

InputDecoration _formDecoration() => InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9.r),
    borderSide: const BorderSide(color: TmsColors.line),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(9.r),
    borderSide: const BorderSide(color: TmsColors.line),
  ),
);

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

Future<DateTime?> _pickDate(BuildContext context, String label) =>
    showDatePicker(
      context: context,
      initialDate: DateTime(2026, 8, 6),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027, 12),
      helpText: label,
    );

String _formatDate(DateTime date, String time) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}, $time';
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
