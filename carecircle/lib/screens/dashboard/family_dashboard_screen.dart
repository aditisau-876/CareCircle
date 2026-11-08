import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/care/data/family_care_service.dart';
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

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final requests = await FamilyCareService.getMyRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _openCareRequest({String? service}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCareRequestScreen(
          elderlyName: widget.elderlyName,
          initialService: service,
        ),
      ),
    ).then((_) => _loadRequests());
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareHistoryScreen(elderlyName: widget.elderlyName),
      ),
    ).then((_) => _loadRequests());
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyProfileScreen(elderlyName: widget.elderlyName),
      ),
    );
  }

  List<Map<String, dynamic>> get _activeRequests => _requests.where((request) {
        final status = _status(request).toLowerCase();
        return !{'completed', 'cancelled', 'rejected'}.contains(status);
      }).toList();

  Map<String, dynamic>? get _nextRequest {
    if (_activeRequests.isEmpty) return null;
    final sorted = [..._activeRequests]
      ..sort((a, b) => _dateTime(a).compareTo(_dateTime(b)));
    return sorted.first;
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
            CareHistoryScreen(elderlyName: widget.elderlyName),
            FamilyProfileScreen(elderlyName: widget.elderlyName),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 0 || index == 2) _loadRequests();
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
      ),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      color: CareCircleColors.primary,
      onRefresh: _loadRequests,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          _buildHeader(),
          const SizedBox(height: 22),
          _buildHeroCard(),
          const SizedBox(height: 26),
          _sectionHeader(
            'Quick care',
            'What does your loved one need today?',
            action: 'View all',
            onAction: () => setState(() => _currentIndex = 1),
          ),
          const SizedBox(height: 14),
          _buildQuickCareGrid(),
          const SizedBox(height: 26),
          _sectionHeader('Your requests', 'Live information from your CareCircle account',
              action: 'History', onAction: _openHistory),
          const SizedBox(height: 12),
          _buildRequestSummary(),
          const SizedBox(height: 22),
          _buildEmergencyCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: const TextStyle(color: CareCircleColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 5),
              Text('Care for ${widget.elderlyName}', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        InkWell(
          onTap: _openProfile,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: CareCircleColors.primary.withValues(alpha: .15)),
            ),
            child: const Icon(Icons.person_outline_rounded, color: CareCircleColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CareCircleColors.primary, CareCircleColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: CareCircleColors.primary.withValues(alpha: .16), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Expanded(child: Text('CareCircle is here for you', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Request trusted help for your loved one whenever they need it.', style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openCareRequest(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Request care'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: CareCircleColors.primary,
                minimumSize: const Size.fromHeight(49),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, {String? action, VoidCallback? onAction}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, color: CareCircleColors.textSecondary)),
            ],
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action, style: const TextStyle(color: CareCircleColors.primary, fontWeight: FontWeight.w700))),
      ],
    );
  }

  Widget _buildQuickCareGrid() {
    final services = <(String, String, IconData)>[
      ('Medicine', 'Pickup', Icons.medication_outlined),
      ('Groceries', 'Pickup', Icons.shopping_basket_outlined),
      ('Appointments', 'Assistance', Icons.calendar_month_outlined),
      ('Companionship', 'Visit', Icons.favorite_border_rounded),
      ('Hospital', 'Help', Icons.local_hospital_outlined),
      ('Household', 'Assistance', Icons.home_outlined),
    ];
    const serviceNames = <String>[
      'Medicine pickup',
      'Grocery pickup',
      'Appointment assistance',
      'Companionship',
      'Accompaniment to hospital',
      'Household assistance',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .95,
      ),
      itemBuilder: (context, index) {
        final item = services[index];
        return InkWell(
          onTap: () => _openCareRequest(service: serviceNames[index]),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CareCircleColors.border)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$3, color: CareCircleColors.primary, size: 26),
                const SizedBox(height: 9),
                Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
                Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: CareCircleColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestSummary() {
    if (_loading) {
      return const Card(child: Padding(padding: EdgeInsets.all(22), child: Center(child: CircularProgressIndicator())));
    }
    if (_error != null) {
      return _messageCard(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load your requests',
        message: _error!,
        action: 'Try again',
        onAction: _loadRequests,
      );
    }
    final request = _nextRequest;
    if (request == null) {
      return _messageCard(
        icon: Icons.event_available_outlined,
        title: 'No active care requests',
        message: _requests.isEmpty ? 'Your submitted care requests will appear here.' : 'You have no pending or ongoing requests right now.',
        action: 'Request care',
        onAction: () => _openCareRequest(),
      );
    }
    return _requestCard(request, compact: true);
  }

  Widget _requestCard(Map<String, dynamic> request, {bool compact = false}) {
    final status = _status(request);
    final color = _statusColor(status);
    final id = request['id'];
    final service = _string(request['service'], 'Care service');
    final date = _formatDate(request['scheduled_date']);
    final time = _formatTime(request['scheduled_time']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: CareCircleColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(service, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary))),
              _statusPill(status, color),
            ],
          ),
          const SizedBox(height: 9),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 15, color: CareCircleColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text('$date  •  $time', style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary))),
          ]),
          if (!compact) ...[
            const SizedBox(height: 7),
            Text(_string(request['address'], 'Address not provided'), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary)),
          ],
          if (id != null) ...[
            const SizedBox(height: 8),
            Text('Request #$id', style: const TextStyle(fontSize: 11, color: CareCircleColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildCareTab() {
    const services = <(String, String, IconData)>[
      ('Grocery pickup', 'Pick up groceries and essentials', Icons.shopping_basket_outlined),
      ('Medicine pickup', 'Collect medicines from a pharmacy', Icons.medication_outlined),
      ('Appointment assistance', 'Help with a scheduled appointment', Icons.calendar_month_outlined),
      ('Accompaniment to hospital', 'Accompany your loved one', Icons.local_hospital_outlined),
      ('Household assistance', 'Help with simple household tasks', Icons.home_outlined),
      ('Document / bill assistance', 'Help with documents and bills', Icons.description_outlined),
      ('Companionship', 'Spend meaningful time together', Icons.favorite_border_rounded),
      ('Short walk assistance', 'Support during a short walk', Icons.directions_walk_outlined),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text('Request care', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 7),
        const Text('Choose the type of support your loved one needs.', style: TextStyle(color: CareCircleColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 20),
        ...services.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: InkWell(
            onTap: () => _openCareRequest(service: item.$1),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CareCircleColors.border)),
              child: Row(children: [
                Container(width: 47, height: 47, decoration: BoxDecoration(color: CareCircleColors.primaryLight, borderRadius: BorderRadius.circular(14)), child: Icon(item.$3, color: CareCircleColors.primary)),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.$1, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(item.$2, style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary)),
                ])),
                const Icon(Icons.chevron_right_rounded, color: CareCircleColors.textSecondary),
              ]),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: const Color(0xFFFFF4F2), borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFF2D5D0))),
      child: const Row(children: [
        Icon(Icons.emergency_outlined, color: CareCircleColors.danger, size: 27),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Need urgent assistance?', style: TextStyle(fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
          SizedBox(height: 4),
          Text('Contact your emergency contact or local emergency services.', style: TextStyle(fontSize: 12, height: 1.4, color: CareCircleColors.textSecondary)),
        ])),
      ]),
    );
  }

  Widget _messageCard({required IconData icon, required String title, required String message, String? action, VoidCallback? onAction}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CareCircleColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: CareCircleColors.primary), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)))]),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 12.5, color: CareCircleColors.textSecondary, height: 1.4)),
        if (action != null) ...[
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: onAction, child: Text(action))),
        ],
      ]),
    );
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)),
      child: Text(_prettyStatus(status), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }

  String _status(Map<String, dynamic> request) => _string(request['status'], 'pending');
  String _string(dynamic value, String fallback) => value == null || value.toString().trim().isEmpty ? fallback : value.toString();
  DateTime _dateTime(Map<String, dynamic> request) {
    final date = DateTime.tryParse(_string(request['scheduled_date'], '')) ?? DateTime(2100);
    final timeParts = _string(request['scheduled_time'], '00:00').split(':');
    final hour = int.tryParse(timeParts.first) ?? 0;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(_string(value, ''));
    if (date == null) return 'Date not set';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  String _formatTime(dynamic value) {
    final raw = _string(value, '');
    final parts = raw.split(':');
    if (parts.length < 2) return raw.isEmpty ? 'Time not set' : raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $suffix';
  }
  String _prettyStatus(String value) => value.replaceAll('_', ' ').split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return CareCircleColors.success;
      case 'cancelled':
      case 'rejected': return CareCircleColors.danger;
      case 'assigned':
      case 'on_the_way':
      case 'arrived':
      case 'task_started': return const Color(0xFF3978A8);
      default: return const Color(0xFFB7791F);
    }
  }
}
