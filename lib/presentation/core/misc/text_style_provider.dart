import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../values/text_styles.dart';

final textStyleProvider = Provider<AppTextStyles>((ref) {

  return AppTextStyles();
});
