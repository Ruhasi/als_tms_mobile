import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tms_theme.dart';

@RoutePage()
class MonthlyStatusPage extends StatelessWidget {
  const MonthlyStatusPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MONTHLY SUMMARY')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TmsColors.ink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL JOB REQUESTS',
                style: TextStyle(fontSize: 9, color: Colors.white70),
              ),
              Text(
                '55',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Delivered  34'),
        const Text('In transit  12'),
        const Text('Requested  8'),
        const Text('Cancelled  1'),
        const Divider(height: 34),
        const Text(
          'On-time delivery ratio  92%',
          style: TextStyle(fontWeight: FontWeight.w900, color: TmsColors.green),
        ),
      ],
    ),
  );
}
