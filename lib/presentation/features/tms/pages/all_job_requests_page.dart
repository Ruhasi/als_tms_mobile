import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus_360/presentation/core/routing/app_router.dart';
import 'package:nexus_360/presentation/features/tms/widgets/job_list_item.dart';

import '../../../../application/transport_booking/booking_lookup_providers.dart';
import '../../../../domain/transport_booking/transport_booking.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';

class JobStatusFilter {
  const JobStatusFilter({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Database `current_status` value to send to the filter API.
  final int? id;
  final String name;
  final Color color;
}

const _allStatusFilter = JobStatusFilter(
  id: null,
  name: 'All',
  color: TmsColors.ink,
);

const _statusFilters = <JobStatusFilter>[
  _allStatusFilter,
  JobStatusFilter(
    id: 1,
    name: 'Pending for Approval',
    color: Color(0xFFFFFFCC),
  ),
  JobStatusFilter(id: 2, name: 'Approved', color: Color(0xFFFF0000)),
  JobStatusFilter(id: 3, name: 'Accepted', color: Color(0xFFFF9999)),
  JobStatusFilter(id: 4, name: 'Attended', color: Color(0xFF00BFFF)),
  JobStatusFilter(id: 5, name: 'Arrived At Pickup', color: Color(0xFFFFFF00)),
  JobStatusFilter(
    id: 6,
    name: 'Departed From Pickup',
    color: Color(0xFFFFCC00),
  ),
  JobStatusFilter(id: 7, name: 'Arrived at Delivery', color: Color(0xFF66FF00)),
  JobStatusFilter(id: 8, name: 'Job Completed', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 9, name: 'Km Confirmed', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 10, name: 'Charged Submitted', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 11, name: 'Job Confirmed', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 12, name: 'Finance Confirmed', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 13, name: 'Job Closed', color: Color(0xFF33CC33)),
  JobStatusFilter(id: 101, name: 'Cancelled', color: Color(0xFFFFEEEE)),
  JobStatusFilter(id: 102, name: 'Rejected', color: Color(0xFFFFEEEE)),
  JobStatusFilter(id: 103, name: 'Job Dispute', color: Color(0xFFFF0000)),
  JobStatusFilter(id: 104, name: 'Finance Dispute', color: Color(0xFFFF0000)),
];

@RoutePage()
class AllJobRequestsPage extends HookConsumerWidget {
  const AllJobRequestsPage({
    super.key,
    @QueryParam('filter') this.initialFilter,
  });

  /// Dashboard metric deep-link: `open`, `delivered`, or `flagged`.
  final String? initialFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final query = useState('');
    final selectedFilter = useState(_parseFilter(initialFilter));
    final bookingPage = useState<TransportBookingsPage?>(null);
    final isLoading = useState(false);
    final isLoadingMore = useState(false);
    final loadError = useState<String?>(null);
    final repository = ref.read(transportBookingRepositoryProvider);

    Future<void> loadFirstPage(int? currentStatus) async {
      isLoading.value = true;
      isLoadingMore.value = false;
      loadError.value = null;
      final result = await repository.getBookings(currentStatus: currentStatus);
      if (!context.mounted || selectedFilter.value.id != currentStatus) return;
      isLoading.value = false;
      result.fold((failure) {
        bookingPage.value = null;
        loadError.value = failure.message;
      }, (page) => bookingPage.value = page);
    }

    Future<void> loadNextPage() async {
      final currentPage = bookingPage.value;
      final currentStatus = selectedFilter.value.id;
      if (currentPage == null ||
          isLoading.value ||
          isLoadingMore.value ||
          currentPage.page + 1 >= currentPage.totalPages) {
        return;
      }

      isLoadingMore.value = true;
      final result = await repository.getBookings(
        currentStatus: currentStatus,
        page: currentPage.page + 1,
        size: currentPage.size,
      );
      if (!context.mounted || selectedFilter.value.id != currentStatus) return;
      isLoadingMore.value = false;
      result.fold(
        (failure) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message))),
        (nextPage) {
          final existing = currentPage.content
              .map((booking) => booking.transportBookingSeq)
              .toSet();
          bookingPage.value = TransportBookingsPage(
            content: [
              ...currentPage.content,
              ...nextPage.content.where(
                (booking) => existing.add(booking.transportBookingSeq),
              ),
            ],
            page: nextPage.page,
            size: nextPage.size,
            totalElements: nextPage.totalElements,
            totalPages: nextPage.totalPages,
          );
        },
      );
    }

    useEffect(() {
      loadFirstPage(selectedFilter.value.id);
      return null;
    }, [selectedFilter.value.id]);

    final normalizedQuery = query.value.trim().toLowerCase();
    final bookings =
        bookingPage.value?.content.where((booking) {
          return normalizedQuery.isEmpty ||
              booking.bookingNo.toLowerCase().contains(normalizedQuery) ||
              booking.customerReferenceNo.toLowerCase().contains(
                normalizedQuery,
              ) ||
              booking.pickupLocationAddress.toLowerCase().contains(
                normalizedQuery,
              ) ||
              booking.deliveryLocationAddress.toLowerCase().contains(
                normalizedQuery,
              );
        }).toList() ??
        const <TransportBooking>[];

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _pageHeader(context, styles),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 10.h),
              child: TextField(
                onChanged: (value) => query.value = value,
                style: styles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search job requests',
                  hintStyle: styles.bodySmall,
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: TmsColors.muted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: TmsColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: TmsColors.orange),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 38.h,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                children: _statusFilters
                    .map(
                      (filter) => _statusTab(
                        label: filter.name,
                        selected: selectedFilter.value == filter,
                        onTap: () => selectedFilter.value = filter,
                        styles: styles,
                        color: filter.color,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (isLoading.value)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: CupertinoActivityIndicator(radius: 10.r),
              )
            else
              SizedBox(height: 5.h),
            Expanded(
              child: bookingPage.value == null
                  ? isLoading.value
                        ? const SizedBox.shrink()
                        : _loadErrorState(styles, loadError.value)
                  : bookings.isEmpty
                  ? _emptyState(styles)
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.extentAfter < 240) {
                          loadNextPage();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                        itemCount:
                            bookings.length + (isLoadingMore.value ? 1 : 0),
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, index) {
                          if (index == bookings.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                          return TransportBookingListItem(
                            booking: bookings[index],
                            styles: styles,
                            onTap: () => context.router.push(
                              JobDetailRoute(
                                jobId: bookings[index].transportBookingSeq,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

JobStatusFilter _parseFilter(String? value) {
  final filterId = int.tryParse(value ?? '');
  if (filterId != null) {
    return _statusFilters.firstWhere(
      (filter) => filter.id == filterId,
      orElse: () => _allStatusFilter,
    );
  }

  return switch (value?.toLowerCase()) {
    'delivered' => _filterForId(8),
    'requested' => _filterForId(1),
    'accepted' => _filterForId(3),
    'intransit' || 'in_transit' || 'in-transit' => _filterForId(6),
    'cancelled' => _filterForId(101),
    _ => _allStatusFilter,
  };
}

JobStatusFilter _filterForId(int id) =>
    _statusFilters.firstWhere((filter) => filter.id == id);

Widget _pageHeader(BuildContext context, dynamic styles) => Padding(
  padding: EdgeInsets.fromLTRB(10.w, 9.h, 18.w, 5.h),
  child: Row(
    children: [
      IconButton(
        onPressed: () => context.router.maybePop(),
        icon: const Icon(CupertinoIcons.chevron_back),
      ),
      Expanded(
        child: Text(
          'ALL JOB REQUESTS',
          style: styles.titleMedium.copyWith(
            fontSize: 16.sp,
            letterSpacing: .25,
          ),
        ),
      ),
    ],
  ),
);

Widget _statusTab({
  required String label,
  required bool selected,
  required VoidCallback onTap,
  required dynamic styles,
  Color color = TmsColors.ink,
}) => Padding(
  padding: EdgeInsets.only(right: 8.w),
  child: Material(
    color: selected ? TmsColors.orange : Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: TmsColors.line),
        ),
        child: Text(
          label,
          style: styles.labelSmall.copyWith(
            color: selected ? Colors.white : Colors.black,
            fontSize: 10.sp,
            letterSpacing: .55,
          ),
        ),
      ),
    ),
  ),
);

Widget _emptyState(dynamic styles) => Center(
  child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.doc_text_search,
          size: 36,
          color: TmsColors.muted,
        ),
        SizedBox(height: 12.h),
        Text(
          'No matching job requests',
          style: styles.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5.h),
        Text(
          'Try a different search term or status filter.',
          style: styles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);

Widget _loadErrorState(dynamic styles, String? message) => Center(
  child: Text(
    message ?? 'Could not load job requests',
    style: styles.bodyMedium,
  ),
);
