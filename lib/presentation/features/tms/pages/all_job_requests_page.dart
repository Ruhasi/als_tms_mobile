import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_template/presentation/features/tms/widgets/job_list_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/tms/tms_providers.dart';
import '../../../../domain/tms/models/tms_models.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';

enum JobListFilter {
  all,
  open,
  requested,
  accepted,
  inTransit,
  delivered,
  cancelled,
  flagged,
}

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
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      loading: () =>
          const Scaffold(body: Center(child: CupertinoActivityIndicator())),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Could not load job requests')),
      ),
      data: (data) {
        final normalizedQuery = query.value.trim().toLowerCase();
        final jobs = data.jobs.where((job) {
          final matchesFilter = _matchesFilter(job, selectedFilter.value);
          final matchesQuery =
              normalizedQuery.isEmpty ||
              job.id.toLowerCase().contains(normalizedQuery) ||
              job.pickup.toLowerCase().contains(normalizedQuery) ||
              job.destination.toLowerCase().contains(normalizedQuery) ||
              job.customer.toLowerCase().contains(normalizedQuery);
          return matchesFilter && matchesQuery;
        }).toList();

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
                    children: JobListFilter.values
                        .map(
                          (filter) => _statusTab(
                            label: _filterLabel(filter),
                            selected: selectedFilter.value == filter,
                            onTap: () => selectedFilter.value = filter,
                            styles: styles,
                            color: _filterColor(filter),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: 5.h),
                Expanded(
                  child: jobs.isEmpty
                      ? _emptyState(styles)
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                          itemCount: jobs.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (_, index) =>
                              JobListItem(job: jobs[index], styles: styles),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

JobListFilter _parseFilter(String? value) => switch (value?.toLowerCase()) {
  'open' => JobListFilter.open,
  'delivered' => JobListFilter.delivered,
  'flagged' => JobListFilter.flagged,
  'requested' => JobListFilter.requested,
  'accepted' => JobListFilter.accepted,
  'intransit' || 'in_transit' || 'in-transit' => JobListFilter.inTransit,
  'cancelled' => JobListFilter.cancelled,
  _ => JobListFilter.all,
};

bool _matchesFilter(TmsJob job, JobListFilter filter) => switch (filter) {
  JobListFilter.all => true,
  JobListFilter.open =>
    job.status == JobStatus.requested ||
        job.status == JobStatus.accepted ||
        job.status == JobStatus.inTransit,
  JobListFilter.requested => job.status == JobStatus.requested,
  JobListFilter.accepted => job.status == JobStatus.accepted,
  JobListFilter.inTransit => job.status == JobStatus.inTransit,
  JobListFilter.delivered => job.status == JobStatus.delivered,
  JobListFilter.cancelled => job.status == JobStatus.cancelled,
  JobListFilter.flagged => job.isFlagged,
};

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
    color: selected ? color : Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: selected ? color : TmsColors.line),
        ),
        child: Text(
          label,
          style: styles.labelSmall.copyWith(
            color: selected ? Colors.white : color,
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

String _filterLabel(JobListFilter filter) => switch (filter) {
  JobListFilter.all => 'All',
  JobListFilter.open => 'Open',
  JobListFilter.requested => 'Requested',
  JobListFilter.accepted => 'Accepted',
  JobListFilter.inTransit => 'In transit',
  JobListFilter.delivered => 'Delivered',
  JobListFilter.cancelled => 'Cancelled',
  JobListFilter.flagged => 'Flagged',
};

Color _filterColor(JobListFilter filter) => switch (filter) {
  JobListFilter.all => TmsColors.ink,
  JobListFilter.open => TmsColors.ink,
  JobListFilter.requested => TmsColors.gold,
  JobListFilter.accepted || JobListFilter.inTransit => TmsColors.blue,
  JobListFilter.delivered => TmsColors.green,
  JobListFilter.cancelled => TmsColors.red,
  JobListFilter.flagged => TmsColors.orange,
};
