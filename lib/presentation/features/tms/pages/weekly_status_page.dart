import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tms_theme.dart';

@RoutePage()
class WeeklyStatusPage extends StatelessWidget {
  const WeeklyStatusPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('LAST WEEK')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly view answers “how busy were we”',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [42.0, 63, 32, 85, 55, 73, 38]
                  .map(
                    (value) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: value * 2,
                        color: value == 85 ? TmsColors.orange : TmsColors.ink,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
