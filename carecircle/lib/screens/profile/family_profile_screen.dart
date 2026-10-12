import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FamilyProfileScreen extends StatefulWidget {
  final String elderlyName;

  const FamilyProfileScreen({
    super.key,
    required this.elderlyName,
  });

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available when the backend is connected.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'You can log back in later using your CareCircle account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout will be connected to authentication later.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showComingSoon('Profile editing'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 22),

            _buildSectionTitle('Care recipient'),
            const SizedBox(height: 10),
            _buildCareRecipientCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('Account'),
            const SizedBox(height: 10),
            _buildAccountCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('Preferences'),
            const SizedBox(height: 10),
            _buildPreferencesCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('CareCircle'),
            const SizedBox(height: 10),
            _buildCareCircleCard(),
            const SizedBox(height: 28),

            _buildLogoutButton(),
            const SizedBox(height: 20),

            Center(
              child: Text(
                'CareCircle • Your circle of care',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CareCircleColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CareCircleColors.primary,
            CareCircleColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CareCircleColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CareCircle Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9BE7B6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Account active',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCareRecipientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.elderly_rounded,
                  color: CareCircleColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.elderlyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Care recipient',
                      style: TextStyle(
                        color: CareCircleColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: CareCircleColors.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _infoRow(
            Icons.location_on_outlined,
            'Care address',
            'Saved care address',
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.translate_rounded,
            'Preferred language',
            'Selected during profile setup',
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.accessibility_new_rounded,
            'Mobility support',
            'Care requirements saved',
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _showComingSoon('Care profile editing'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(
                color: CareCircleColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('View care profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: [
          _profileActionTile(
            icon: Icons.person_outline_rounded,
            title: 'Personal information',
            subtitle: 'Name, phone number and email',
            onTap: () => _showComingSoon('Personal information'),
          ),
          _divider(),
          _profileActionTile(
            icon: Icons.contact_phone_outlined,
            title: 'Emergency contacts',
            subtitle: 'People to contact when needed',
            onTap: () => _showComingSoon('Emergency contacts'),
          ),
          _divider(),
          _profileActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Password & security',
            subtitle: 'Manage account security',
            onTap: () => _showComingSoon('Password and security'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeThumbColor: CareCircleColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            secondary: _iconBox(
              Icons.notifications_none_rounded,
              CareCircleColors.secondaryLight,
              CareCircleColors.secondary,
            ),
            title: const Text(
              'Care notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Updates about requests and helpers',
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: _locationSharingEnabled,
            onChanged: (value) {
              setState(() {
                _locationSharingEnabled = value;
              });
            },
            activeThumbColor: CareCircleColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            secondary: _iconBox(
              Icons.location_on_outlined,
              CareCircleColors.primaryLight,
              CareCircleColors.primary,
            ),
            title: const Text(
              'Location sharing',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Used during active care requests',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCircleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: [
          _profileActionTile(
            icon: Icons.workspace_premium_outlined,
            title: 'CareCircle plan',
            subtitle: 'Family plan and subscription details',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: CareCircleColors.secondaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Free',
                style: TextStyle(
                  color: Color(0xFF9A5B27),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _showComingSoon('Subscription management'),
          ),
          _divider(),
          _profileActionTile(
            icon: Icons.shield_outlined,
            title: 'Privacy & safety',
            subtitle: 'How CareCircle protects your information',
            onTap: () => _showComingSoon('Privacy and safety'),
          ),
          _divider(),
          _profileActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'Get assistance with CareCircle',
            onTap: () => _showComingSoon('Help and support'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _showLogoutDialog,
      icon: const Icon(
        Icons.logout_rounded,
        color: CareCircleColors.danger,
      ),
      label: const Text(
        'Log out',
        style: TextStyle(
          color: CareCircleColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: CareCircleColors.danger.withValues(alpha: 0.25),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
      ),
    );
  }

  Widget _profileActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      leading: _iconBox(
        icon,
        CareCircleColors.primaryLight,
        CareCircleColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(subtitle),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: CareCircleColors.textSecondary,
          ),
    );
  }

  Widget _iconBox(
      IconData icon,
      Color background,
      Color foreground,
      ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: foreground,
        size: 22,
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: CareCircleColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: CareCircleColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: CareCircleColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 76,
      endIndent: 16,
    );
  }
}