import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/driver/driver_providers.dart';
import '../../../../domain/driver/driver_job.dart';
import '../../../core/misc/text_style_provider.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class DriverPodUploadPage extends HookConsumerWidget {
  const DriverPodUploadPage({
    super.key,
    @PathParam('jobId') required this.jobId,
  });

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.read(textStyleProvider);
    final job = ref.watch(driverJobProvider(jobId));
    final images = useState<List<ProofOfDeliveryImage>>(const []);
    final isSaving = useState(false);

    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job unavailable')));
    }

    void addMockImage() {
      final index = images.value.length + 1;
      images.value = [
        ...images.value,
        ProofOfDeliveryImage(
          id: 'mock-${job.id}-$index',
          label: index == 1
              ? 'Signed delivery note'
              : index == 2
              ? 'Unloading photo'
              : 'Proof image $index',
          uploadedAt: DateTime.now(),
        ),
      ];
    }

    return Scaffold(
      backgroundColor: TmsColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(CupertinoIcons.chevron_back),
                  ),
                  Expanded(
                    child: Text(
                      'PROOF OF DELIVERY',
                      style: styles.titleMedium.copyWith(
                        fontSize: 16.sp,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                job.bookingNo,
                style: styles.labelSmall.copyWith(letterSpacing: 1.1),
              ),
              SizedBox(height: 4.h),
              Text(
                'Add delivery proof images. Uploading completes this job.',
                style: styles.bodySmall,
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: images.value.isEmpty
                    ? Center(
                        child: Text(
                          'No images added yet',
                          style: styles.bodySmall,
                        ),
                      )
                    : GridView.builder(
                        itemCount: images.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                        ),
                        itemBuilder: (_, index) {
                          final image = images.value[index];
                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: TmsColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: TmsColors.green.withValues(
                                        alpha: .12,
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: TmsColors.green,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  image.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: TmsColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: addMockImage,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Add proof image'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 46.h),
                  foregroundColor: TmsColors.ink,
                  side: const BorderSide(color: TmsColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TmsButton(
                label: isSaving.value ? 'Uploading...' : 'Upload and complete job',
                onPressed: images.value.isEmpty || isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        await Future<void>.delayed(
                          const Duration(milliseconds: 600),
                        );
                        ref
                            .read(driverJobsProvider.notifier)
                            .addProofs(job.id, images.value);
                        if (!context.mounted) return;
                        isSaving.value = false;
                        await showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Job completed'),
                            content: const Text(
                              'Proof of delivery was uploaded. This job is now complete.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        if (context.mounted) context.router.maybePop();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
