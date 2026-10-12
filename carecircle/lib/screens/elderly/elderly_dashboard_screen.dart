import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../care/create_care_request_screen.dart';
import '../history/care_history_screen.dart';

class ElderlyDashboardScreen extends StatefulWidget {
  final String elderlyName;

  const ElderlyDashboardScreen({
    super.key,
    required this.elderlyName,
  });

  @override
  State<ElderlyDashboardScreen> createState() => _ElderlyDashboardScreenState();
}

class _ElderlyDashboardScreenState extends State<ElderlyDashboardScreen> {
  int _selectedIndex = 0;

  void _requestHelp({String? service}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCareRequestScreen(
          elderlyName: widget.elderlyName,
          initialService: service,
        ),
      ),
    );
  }

  void _showNotConnected(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available when CareCircle is connected to its backend.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      CareHistoryScreen(elderlyName: widget.elderlyName),
      _profilePage(),
    ];

    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        title: const Text('CareCircle'),
        actions: [
          IconButton(
            tooltip: 'Contact support',
            onPressed: () => _showNotConnected('CareCircle support'),
            icon: const Icon(Icons.support_agent_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'My care',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CareCircleColors.primary, CareCircleColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Hello, ${widget.elderlyName}',
                style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are not alone. Your care circle is here to help.',
                style: TextStyle(color: Colors.white, height: 1.45, fontSize: 15),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CareCircleColors.primaryDark,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () => _requestHelp(),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Request assistance'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text('What would you like help with?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.12,
          children: [
            _serviceTile(icon: Icons.medication_outlined, title: 'Medicine pickup', subtitle: 'Collect essentials', onTap: () => _requestHelp(service: 'Medicine pickup')),
            _serviceTile(icon: Icons.shopping_basket_outlined, title: 'Groceries', subtitle: 'Daily essentials', onTap: () => _requestHelp(service: 'Grocery pickup')),
            _serviceTile(icon: Icons.local_hospital_outlined, title: 'Appointment', subtitle: 'Help getting there', onTap: () => _requestHelp(service: 'Appointment assistance')),
            _serviceTile(icon: Icons.groups_2_outlined, title: 'Companionship', subtitle: 'A friendly visit', onTap: () => _requestHelp(service: 'Companionship')),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: CareCircleColors.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: CareCircleColors.primaryDark, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your safety matters', style: TextStyle(color: CareCircleColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 6),
                    Text(
                      'Share your care plans with family and only meet helpers through the confirmed CareCircle process. This app is not an emergency medical service.',
                      style: TextStyle(color: CareCircleColors.textSecondary, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.history_rounded),
          label: const Text('View my care history'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), foregroundColor: CareCircleColors.primary),
        ),
      ],
    );
  }

  Widget _serviceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: CareCircleColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: CareCircleColors.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: CareCircleColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: CareCircleColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: CareCircleColors.primaryLight,
                child: const Icon(Icons.elderly_rounded, color: CareCircleColors.primary, size: 42),
              ),
              const SizedBox(height: 14),
              Text(widget.elderlyName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              const Text('Care recipient'),
              const SizedBox(height: 18),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit my profile'),
                subtitle: const Text('Update personal and care preferences'),
                onTap: () => _showNotConnected('Profile editing'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.family_restroom_outlined),
                title: const Text('My care circle'),
                subtitle: const Text('Family and trusted contacts'),
                onTap: () => _showNotConnected('Care circle management'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy and safety'),
                onTap: () => _showNotConnected('Privacy settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
