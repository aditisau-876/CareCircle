import 'package:flutter/material.dart';
import '../registration/registration_screen.dart';
import '../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  final roles = const [
    _RoleData(
      id: 'family',
      title: 'Family member',
      subtitle: 'I want to arrange and monitor care for someone.',
      icon: Icons.family_restroom_rounded,
    ),
    _RoleData(
      id: 'elderly',
      title: 'Elderly / Care recipient',
      subtitle: 'I receive care and assistance through CareCircle.',
      icon: Icons.elderly_rounded,
    ),
    _RoleData(
      id: 'helper',
      title: 'Care helper',
      subtitle: 'I want to provide trusted care services.',
      icon: Icons.volunteer_activism_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you use\nCareCircle?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 12),

              Text(
                'Choose the option that best describes you.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.separated(
                  itemCount: roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final isSelected = selectedRole == role.id;

                    return _RoleCard(
                      role: role,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedRole = role.id;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegistrationScreen(
                        role: selectedRole!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: CareCircleColors.border,
                  disabledForegroundColor: CareCircleColors.textSecondary,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _RoleData role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? CareCircleColors.primaryLight
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? CareCircleColors.primary
              : CareCircleColors.border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          if (!selected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: selected
                      ? CareCircleColors.primary
                      : CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  role.icon,
                  color: selected
                      ? Colors.white
                      : CareCircleColors.primary,
                  size: 29,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      role.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? CareCircleColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? CareCircleColors.primary
                        : CareCircleColors.border,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _RoleData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}