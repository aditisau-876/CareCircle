
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// ===============================================================
/// HELPER REGISTRATION
/// ===============================================================

class HelperRegistrationScreen extends StatefulWidget {
  const HelperRegistrationScreen({super.key});

  @override
  State<HelperRegistrationScreen> createState() =>
      _HelperRegistrationScreenState();
}

class _HelperRegistrationScreenState
    extends State<HelperRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();

  final Set<String> _skills = {};
  final Set<String> _languages = {'English'};

  bool _available = true;
  double _radius = 5;

  static const _services = [
    'Grocery pickup',
    'Medicine pickup',
    'Appointment assistance',
    'Hospital accompaniment',
    'Household assistance',
    'Document / bill assistance',
    'Companionship',
    'Short walk assistance',
  ];

  static const _languageOptions = [
    'English',
    'Hindi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Marathi',
    'Other',
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty || _languages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one service and language.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HelperVerificationScreen(
          helperName: _name.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          emergencyName: _emergencyName.text.trim(),
          emergencyPhone: _emergencyPhone.text.trim(),
          skills: _skills.toList(),
          languages: _languages.toList(),
          available: _available,
          radius: _radius,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Helper registration')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _HelperHeader(
                icon: Icons.volunteer_activism_rounded,
                title: 'Join CareCircle',
                subtitle:
                'Help older adults with everyday tasks and make a meaningful difference.',
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Personal details'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                validator: (v) => _required(v, 'your full name'),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || !RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                    return 'Enter a valid 10-digit Indian mobile number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                minLines: 2,
                maxLines: 3,
                validator: (v) => _required(v, 'your address'),
                decoration: const InputDecoration(
                  labelText: 'Home address',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 26),
              const _SectionTitle('Emergency contact'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emergencyName,
                textCapitalization: TextCapitalization.words,
                validator: (v) => _required(v, 'an emergency contact name'),
                decoration: const InputDecoration(
                  labelText: 'Contact person',
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emergencyPhone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || !RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Emergency contact number',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone_in_talk_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 26),
              const _SectionTitle('Services you can provide'),
              const SizedBox(height: 6),
              const Text(
                'Select every service you are comfortable providing.',
                style: TextStyle(color: CareCircleColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ..._services.map(
                    (service) => _SelectionTile(
                  title: service,
                  selected: _skills.contains(service),
                  onTap: () {
                    setState(() {
                      if (!_skills.add(service)) {
                        _skills.remove(service);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Languages you speak'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languageOptions.map((language) {
                  final selected = _languages.contains(language);
                  return FilterChip(
                    label: Text(language),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _languages.add(language);
                        } else {
                          _languages.remove(language);
                        }
                      });
                    },
                    selectedColor: CareCircleColors.primaryLight,
                    checkmarkColor: CareCircleColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              const _SectionTitle('Availability and service area'),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _available,
                activeColor: CareCircleColors.primary,
                title: const Text(
                  'Available for care requests',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _available
                      ? 'You can receive demo request offers.'
                      : 'You will not receive new demo offers.',
                ),
                onChanged: (value) => setState(() => _available = value),
              ),
              const SizedBox(height: 12),
              Text(
                'Maximum travel distance: ${_radius.round()} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CareCircleColors.textPrimary,
                ),
              ),
              Slider(
                value: _radius,
                min: 1,
                max: 25,
                divisions: 24,
                label: '${_radius.round()} km',
                activeColor: CareCircleColors.primary,
                onChanged: (value) => setState(() => _radius = value),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CareCircleColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: CareCircleColors.secondary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your details are currently kept in this demo flow. '
                            'Secure account storage and verification will be '
                            'connected to the backend later.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: CareCircleColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _continue,
                child: const Text('Continue to verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// VERIFICATION CHECKLIST
/// ===============================================================

class HelperVerificationScreen extends StatefulWidget {
  final String helperName;
  final String phone;
  final String address;
  final String emergencyName;
  final String emergencyPhone;
  final List<String> skills;
  final List<String> languages;
  final bool available;
  final double radius;

  const HelperVerificationScreen({
    super.key,
    required this.helperName,
    required this.phone,
    required this.address,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.skills,
    required this.languages,
    required this.available,
    required this.radius,
  });

  @override
  State<HelperVerificationScreen> createState() =>
      _HelperVerificationScreenState();
}

class _HelperVerificationScreenState
    extends State<HelperVerificationScreen> {
  final Set<int> _acknowledged = {};

  static const _checks = [
    (
    'Identity document',
    'Provide an approved identity document for secure review.',
    Icons.badge_outlined,
    ),
    (
    'Address verification',
    'Confirm your current residential address.',
    Icons.home_work_outlined,
    ),
    (
    'Contact verification',
    'Verify your mobile number using a one-time code.',
    Icons.phonelink_lock_outlined,
    ),
    (
    'References',
    'Provide references when requested by the review team.',
    Icons.people_outline_rounded,
    ),
    (
    'Training and safety',
    'Complete applicable care, privacy and safety training.',
    Icons.health_and_safety_outlined,
    ),
  ];

  void _openDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HelperDashboardScreen(
          helperName: widget.helperName,
          phone: widget.phone,
          address: widget.address,
          emergencyName: widget.emergencyName,
          emergencyPhone: widget.emergencyPhone,
          skills: widget.skills,
          languages: widget.languages,
          available: widget.available,
          radius: widget.radius,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Helper verification')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _HelperHeader(
              icon: Icons.shield_outlined,
              title: 'Build trust with families',
              subtitle:
              'Review the steps required before you can be approved for real care requests.',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CareCircleColors.secondaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    color: CareCircleColors.secondary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demo status: Verification pending. Checking a box '
                          'acknowledges that you understand a requirement; '
                          'it does not verify your identity or approve your account.',
                      style: TextStyle(
                        height: 1.45,
                        color: CareCircleColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ...List.generate(_checks.length, (index) {
              final check = _checks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _card(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _acknowledged.contains(index),
                    activeColor: CareCircleColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: Icon(
                      check.$3,
                      color: CareCircleColors.primary,
                    ),
                    title: Text(
                      check.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(check.$2),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _acknowledged.add(index);
                        } else {
                          _acknowledged.remove(index);
                        }
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openDashboard,
              child: const Text('Continue to demo dashboard'),
            ),
            const SizedBox(height: 10),
            const Text(
              'The dashboard is available for testing. Real requests must '
                  'remain restricted until backend verification is complete.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: CareCircleColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// HELPER DASHBOARD
/// ===============================================================

class HelperDashboardScreen extends StatefulWidget {
  final String helperName;
  final String phone;
  final String address;
  final String emergencyName;
  final String emergencyPhone;
  final List<String> skills;
  final List<String> languages;
  final bool available;
  final double radius;

  const HelperDashboardScreen({
    super.key,
    required this.helperName,
    required this.phone,
    required this.address,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.skills,
    required this.languages,
    required this.available,
    required this.radius,
  });

  @override
  State<HelperDashboardScreen> createState() =>
      _HelperDashboardScreenState();
}

class _HelperDashboardScreenState extends State<HelperDashboardScreen> {
  late bool _available;
  int _tab = 0;
  final List<_CareJob> _history = [];
  _CareJob? _activeJob;

  @override
  void initState() {
    super.initState();
    _available = widget.available;
  }

  static final List<_CareJob> _demoJobs = [
    _CareJob(
      id: 'CC-1042',
      recipient: 'Mrs. Sen',
      service: 'Medicine pickup',
      address: 'Near Salt Lake, Kolkata',
      date: 'Today',
      time: '5:00 PM',
      duration: '45 minutes',
      instructions: 'Collect the prescribed medicine and keep the receipt.',
      amount: 100,
    ),
    _CareJob(
      id: 'CC-1043',
      recipient: 'Mr. Das',
      service: 'Grocery pickup',
      address: 'New Town, Kolkata',
      date: 'Tomorrow',
      time: '11:30 AM',
      duration: '1 hour',
      instructions: 'Confirm the grocery list with the family before buying.',
      amount: 100,
    ),
    _CareJob(
      id: 'CC-1044',
      recipient: 'Mrs. Roy',
      service: 'Companionship',
      address: 'Bidhannagar, Kolkata',
      date: 'Tomorrow',
      time: '4:00 PM',
      duration: '1 hour',
      instructions: 'Friendly conversation and a short indoor activity.',
      amount: 100,
    ),
  ];

  void _openJob(_CareJob job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HelperJobOfferScreen(
          job: job,
          onAccept: () {
            Navigator.pop(context);
            setState(() => _activeJob = job);
            _openTask(job);
          },
        ),
      ),
    );
  }

  void _openTask(_CareJob job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HelperTaskScreen(
          job: job,
          onComplete: () {
            setState(() {
              _history.insert(0, job);
              _activeJob = null;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo task marked as completed.'),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _requestsPage(),
      _historyPage(),
      _profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle Helper'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => setState(() => _tab = 3),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    final visibleJobs = _demoJobs
        .where((job) => widget.skills.contains(job.service))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                CareCircleColors.primary,
                CareCircleColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HELPER DASHBOARD',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.3,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hello, ${widget.helperName}!',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your time and kindness can make someone’s day easier.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _available ? 'Available for requests' : 'Currently unavailable',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Switch(
                    value: _available,
                    onChanged: (value) => setState(() => _available = value),
                    activeTrackColor: CareCircleColors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Completed',
                '${_history.length}',
                Icons.task_alt_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Demo earnings',
                '₹${_history.fold<double>(0, (sum, job) => sum + job.amount).toStringAsFixed(0)}',
                Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Your next task'),
        const SizedBox(height: 12),
        if (_activeJob != null)
          _jobCard(
            _activeJob!,
            buttonLabel: 'Continue task',
            onPressed: () => _openTask(_activeJob!),
          )
        else
          _emptyCard(
            Icons.event_available_outlined,
            'No active task',
            'Accept a suitable request to see it here.',
          ),
        const SizedBox(height: 26),
        const _SectionTitle('Matching demo requests'),
        const SizedBox(height: 12),
        if (!_available)
          _emptyCard(
            Icons.pause_circle_outline,
            'You are unavailable',
            'Turn on availability to browse demo requests.',
          )
        else if (visibleJobs.isEmpty)
          _emptyCard(
            Icons.search_off_rounded,
            'No matching demo requests',
            'Your selected service skills determine which sample offers appear.',
          )
        else
          ...visibleJobs.map(
                (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _jobCard(
                job,
                buttonLabel: 'View request',
                onPressed: () => _openJob(job),
              ),
            ),
          ),
      ],
    );
  }

  Widget _requestsPage() {
    final jobs = _demoJobs
        .where((job) => widget.skills.contains(job.service))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle('Available requests'),
        const SizedBox(height: 8),
        const Text(
          'These are sample requests for testing, not real family bookings.',
        ),
        const SizedBox(height: 18),
        if (!_available)
          _emptyCard(
            Icons.pause_circle_outline,
            'Availability is off',
            'Turn it on from Home to see demo offers.',
          )
        else if (jobs.isEmpty)
          _emptyCard(
            Icons.search_off_rounded,
            'No matching offers',
            'No sample requests match your selected skills.',
          )
        else
          ...jobs.map(
                (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _jobCard(
                job,
                buttonLabel: 'View offer',
                onPressed: () => _openJob(job),
              ),
            ),
          ),
      ],
    );
  }

  Widget _historyPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle('Care history'),
        const SizedBox(height: 8),
        const Text('Your completed demo tasks appear here.'),
        const SizedBox(height: 18),
        if (_history.isEmpty)
          _emptyCard(
            Icons.history_rounded,
            'No completed tasks yet',
            'Finish a demo task to see it in your history.',
          )
        else
          ..._history.map(
                (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.service,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CareCircleColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${job.recipient} • ${job.date}, ${job.time}'),
                    const SizedBox(height: 8),
                    Text(
                      'Demo earning: ₹${job.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: CareCircleColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 17,
                          color: CareCircleColors.success,
                        ),
                        SizedBox(width: 6),
                        Text('Marked completed in this demo'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _HelperHeader(
          icon: Icons.account_circle_outlined,
          title: 'Helper profile',
          subtitle: 'Review the details entered during registration.',
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            children: [
              _detailRow('Name', widget.helperName),
              _detailRow('Phone', '+91 ${widget.phone}'),
              _detailRow('Address', widget.address),
              _detailRow('Emergency contact', widget.emergencyName),
              _detailRow('Emergency phone', widget.emergencyPhone),
              _detailRow('Languages', widget.languages.join(', ')),
              _detailRow('Service radius', '${widget.radius.round()} km'),
              _detailRow(
                'Verification',
                'Pending — not yet verified',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.skills.map(
                    (skill) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: CareCircleColors.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Text(skill)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => setState(() => _tab = 0),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Back to home'),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: CareCircleColors.primary, size: 24),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _jobCard(
      _CareJob job, {
        required String buttonLabel,
        required VoidCallback onPressed,
      }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: CareCircleColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.service,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: CareCircleColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${job.date} • ${job.time}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${job.amount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow('Recipient', job.recipient),
          _detailRow('Area', job.address),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(IconData icon, String title, String message) {
    return _card(
      child: Column(
        children: [
          Icon(icon, size: 36, color: CareCircleColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: CareCircleColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// ===============================================================
/// CARE REQUEST OFFER
/// ===============================================================

class HelperJobOfferScreen extends StatelessWidget {
  final _CareJob job;
  final VoidCallback onAccept;

  const HelperJobOfferScreen({
    super.key,
    required this.job,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care request offer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _HelperHeader(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Review this request',
              subtitle:
              'Check the details carefully before accepting the demo task.',
            ),
            const SizedBox(height: 20),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.service,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: CareCircleColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _detailRow('Request ID', job.id),
                  _detailRow('Care recipient', job.recipient),
                  _detailRow('Location', job.address),
                  _detailRow('Date', job.date),
                  _detailRow('Time', job.time),
                  _detailRow('Estimated duration', job.duration),
                  _detailRow(
                    'Illustrative helper fee',
                    '₹${job.amount}',
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: CareCircleColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(job.instructions),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CareCircleColors.secondaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'This is sample data. The recipient, address, schedule and '
                    'fee are illustrative and are not a real booking.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accept demo request'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Decline / go back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// HELPER TASK TRACKING
/// ===============================================================

class HelperTaskScreen extends StatefulWidget {
  final _CareJob job;
  final VoidCallback onComplete;

  const HelperTaskScreen({
    super.key,
    required this.job,
    required this.onComplete,
  });

  @override
  State<HelperTaskScreen> createState() => _HelperTaskScreenState();
}

class _HelperTaskScreenState extends State<HelperTaskScreen> {
  int _step = 0;

  static const _steps = [
    'Request accepted',
    'On the way',
    'Arrived',
    'Task started',
    'Completed',
  ];

  void _advance() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _step == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care task'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: CareCircleColors.primary,
                    size: 34,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.job.service,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: CareCircleColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Recipient', widget.job.recipient),
                  _detailRow('Location', widget.job.address),
                  _detailRow(
                    'Schedule',
                    '${widget.job.date}, ${widget.job.time}',
                  ),
                  _detailRow('Duration', widget.job.duration),
                  _detailRow('Request ID', widget.job.id),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Task progress'),
            const SizedBox(height: 16),
            ...List.generate(_steps.length, (index) {
              final isDone = index <= _step;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDone
                            ? CareCircleColors.primary
                            : CareCircleColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone ? Icons.check : Icons.circle_outlined,
                        size: 18,
                        color: isDone
                            ? Colors.white
                            : CareCircleColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _steps[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: index == _step
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isDone
                                ? CareCircleColors.textPrimary
                                : CareCircleColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (_step == 2)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CareCircleColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Arrival verification is a demo placeholder. A real app '
                      'should verify a one-time code or another approved method '
                      'before allowing the task to start.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _advance,
              child: Text(
                completed ? 'Finish and save demo history' : _nextLabel(),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  String _nextLabel() {
    switch (_step) {
      case 0:
        return 'Mark as on the way';
      case 1:
        return 'Mark as arrived';
      case 2:
        return 'Start task';
      case 3:
        return 'Mark task completed';
      default:
        return 'Finish';
    }
  }
}

/// ===============================================================
/// REUSABLE UI AND DEMO DATA
/// ===============================================================

class _CareJob {
  final String id;
  final String recipient;
  final String service;
  final String address;
  final String date;
  final String time;
  final String duration;
  final String instructions;
  final double amount;

  const _CareJob({
    required this.id,
    required this.recipient,
    required this.service,
    required this.address,
    required this.date,
    required this.time,
    required this.duration,
    required this.instructions,
    required this.amount,
  });
}

class _HelperHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelperHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: CareCircleColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: CareCircleColors.textPrimary,
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? CareCircleColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected
                    ? CareCircleColors.primary
                    : CareCircleColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected
                      ? CareCircleColors.primary
                      : CareCircleColors.textSecondary,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CareCircleColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _card({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: CareCircleColors.border),
    ),
    child: child,
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CareCircleColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CareCircleColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
