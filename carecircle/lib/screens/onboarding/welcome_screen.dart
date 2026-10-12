import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../core/theme/app_theme.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const Spacer(),

              // Main visual
              Container(
                width: size.width * 0.68,
                height: size.width * 0.68,
                constraints: const BoxConstraints(
                  maxWidth: 280,
                  maxHeight: 280,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CareCircleColors.primaryLight,
                  boxShadow: [
                    BoxShadow(
                      color: CareCircleColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      size: 76,
                      color: CareCircleColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 42),

              Text(
                'Care, connected.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),

              const SizedBox(height: 14),

              Text(
                'Helping families stay close to the people they care about — wherever they are.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Get started'),
              ),

              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'I already have an account',
                  style: TextStyle(
                    color: CareCircleColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}