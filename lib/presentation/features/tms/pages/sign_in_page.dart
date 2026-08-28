import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nexus_360/presentation/core/misc/text_style_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../application/auth/auth_controller.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tms_theme.dart';
import '../../../core/widgets/tms_widgets.dart';

@RoutePage()
class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = useTextEditingController();
    final password = useTextEditingController();
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: TmsColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TmsColors.orange,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text('A', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 28.h),
              Text('Nexus360', style: ref.read(textStyleProvider).bold28),
              const SizedBox(height: 8),
              const Text(
                'Transport management in your pocket.',
                style: TextStyle(color: Color(0xFF9A9CA2)),
              ),
              const Spacer(),
              Text(
                'USERNAME',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9A9CA2)),
              ),
              SizedBox(height: 4.h),
              TextField(
                controller: username,
                style: const TextStyle(color: Colors.white),
                decoration: _input('USERNAME'),
              ),
              const SizedBox(height: 12),
              Text(
                'PASSWORD',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9A9CA2)),
              ),
              SizedBox(height: 4.h),
              TextField(
                controller: password,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _input('PASSWORD'),
              ),
              const SizedBox(height: 22),
              TmsButton(
                label: authState.isLoading ? 'Signing in...' : 'Sign in',
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final signedIn = await ref
                            .read(authControllerProvider.notifier)
                            .signIn(
                              username: username.text,
                              password: password.text,
                            );
                        if (!context.mounted) return;
                        if (signedIn) {
                          context.router.replace(const DashboardRoute());
                          return;
                        }
                        final error = ref.read(authControllerProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error?.toString() ?? 'Unable to sign in.',
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _input(String label) => InputDecoration(
  // labelText: label,
  // labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF9A9CA2)),
  filled: true,
  fillColor: const Color(0xFF1E242D),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
);
