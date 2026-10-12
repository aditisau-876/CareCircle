import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../care/create_care_request_screen.dart';
import '../history/care_history_screen.dart';
import '../profile/family_profile_screen.dart';

class FamilyDashboardScreen extends StatefulWidget {
  final String elderlyName;

  const FamilyDashboardScreen({
    super.key,
    required this.elderlyName,
  });

  @override
  State<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState
    extends State<FamilyDashboardScreen> {
  int _currentIndex = 0;

  void _openCareRequest({String? service}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCareRequestScreen(
          elderlyName: widget.elderlyName,
          initialService: service,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareHistoryScreen(
          elderlyName: widget.elderlyName,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyProfileScreen(
          elderlyName: widget.elderlyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHome(),
            _buildCareTab(),
            _buildHistoryTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCareStatusCard(),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: 'Quick care',
                  subtitle: 'What does your loved one need today?',
                  actionText: 'View all',
                  onAction: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
                const SizedBox(height: 14),
                _buildQuickCareGrid(),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: 'Upcoming care',
                  subtitle: 'Your next scheduled service',
                ),
                const SizedBox(height: 14),
                _buildUpcomingCareCard(),
                const SizedBox(height: 28),
                _buildEmergencyCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good evening 👋',
                style: TextStyle(
                  fontSize: 14,
                  color: CareCircleColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Care for ${widget.elderlyName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: CareCircleColors.primary.withValues(
                  alpha: 0.15,
                ),
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: CareCircleColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCareStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CareCircleColors.primary,
            CareCircleColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: CareCircleColors.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CareCircle is here for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Request trusted help for your loved one whenever they need it.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => _openCareRequest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: CareCircleColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 21),
                SizedBox(width: 7),
                Text(
                  'Request care',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: CareCircleColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                color: CareCircleColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickCareGrid() {
    final services = [
      {
        'title': 'Medicine',
        'subtitle': 'Pickup',
        'icon': Icons.medication_outlined,
        'color': CareCircleColors.secondary,
        'background': CareCircleColors.secondaryLight,
        'service': 'Medicine pickup',
      },
      {
        'title': 'Groceries',
        'subtitle': 'Pickup',
        'icon': Icons.shopping_basket_outlined,
        'color': CareCircleColors.primary,
        'background': CareCircleColors.primaryLight,
        'service': 'Grocery pickup',
      },
      {
        'title': 'Appointments',
        'subtitle': 'Assistance',
        'icon': Icons.calendar_month_outlined,
        'color': const Color(0xFF7B61A8),
        'background': const Color(0xFFEDE8FA),
        'service': 'Appointment assistance',
      },
      {
        'title': 'Companionship',
        'subtitle': 'Visit',
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFFC45C78),
        'background': const Color(0xFFFCE9EE),
        'service': 'Companionship',
      },
      {
        'title': 'Hospital',
        'subtitle': 'Help',
        'icon': Icons.local_hospital_outlined,
        'color': const Color(0xFF4E7EA8),
        'background': const Color(0xFFE8F1FA),
        'service': 'Accompaniment to hospital',
      },
      {
        'title': 'Household',
        'subtitle': 'Assistance',
        'icon': Icons.home_outlined,
        'color': const Color(0xFF8C704A),
        'background': const Color(0xFFF2EDE5),
        'service': 'Household assistance',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = services[index];

        return InkWell(
          onTap: () => _openCareRequest(
            service: item['service'] as String,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CareCircleColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: item['background'] as Color,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: CareCircleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingCareCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CareCircleColors.secondaryLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: CareCircleColors.secondary,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicine pickup',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'No upcoming request',
                  style: TextStyle(
                    fontSize: 12,
                    color: CareCircleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: CareCircleColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFF2D5D0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE3DF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emergency_outlined,
              color: CareCircleColors.danger,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need urgent assistance?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Contact your emergency contact or local emergency services.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: CareCircleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text(
          'Request care',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 7),
        const Text(
          'Choose the type of support your loved one needs.',
          style: TextStyle(
            color: CareCircleColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 22),
        _buildAllServices(),
      ],
    );
  }

  Widget _buildAllServices() {
    final services = [
      (
      'Grocery pickup',
      'Pick up groceries and essentials',
      Icons.shopping_basket_outlined,
      ),
      (
      'Medicine pickup',
      'Collect medicines from a pharmacy',
      Icons.medication_outlined,
      ),
      (
      'Appointment assistance',
      'Help with a scheduled appointment',
      Icons.calendar_month_outlined,
      ),
      (
      'Accompaniment to hospital',
      'Accompany your loved one',
      Icons.local_hospital_outlined,
      ),
      (
      'Household assistance',
      'Help with simple household tasks',
      Icons.home_outlined,
      ),
      (
      'Document / bill assistance',
      'Help with documents and bills',
      Icons.description_outlined,
      ),
      (
      'Companionship',
      'Spend meaningful time together',
      Icons.favorite_border_rounded,
      ),
      (
      'Short walk assistance',
      'Support during a short walk',
      Icons.directions_walk_outlined,
      ),
    ];

    return Column(
      children: services.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _openCareRequest(
              service: item.$1,
            ),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: CareCircleColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CareCircleColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.$3,
                      color: CareCircleColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color:
                            CareCircleColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color:
                            CareCircleColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: CareCircleColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryTab() {
    return CareHistoryScreen(
      elderlyName: widget.elderlyName,
    );
  }

  Widget _buildProfileTab() {
    return FamilyProfileScreen(
      elderlyName: widget.elderlyName,
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white,
      elevation: 0,
      indicatorColor: CareCircleColors.primaryLight,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.volunteer_activism_outlined),
          selectedIcon: Icon(Icons.volunteer_activism_rounded),
          label: 'Care',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}