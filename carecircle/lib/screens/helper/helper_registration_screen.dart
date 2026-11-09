import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/helper/data/helper_service.dart';
import '../../core/network/api_client.dart';

/// Helper onboarding screen. Account name and phone come from the signed-in
/// account; this form saves the helper-specific profile through FastAPI.
class HelperRegistrationScreen extends StatefulWidget {
  const HelperRegistrationScreen({super.key});

  @override
  State<HelperRegistrationScreen> createState() =>
      _HelperRegistrationScreenState();
}

class _HelperRegistrationScreenState extends State<HelperRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  static const List<String> _serviceOptions = [
    'Grocery pickup',
    'Medicine pickup',
    'Appointment assistance',
    'Accompaniment to hospital',
    'Household assistance',
    'Document/bill assistance',
    'Companionship',
    'Short walk assistance',
  ];

  static const List<String> _languageOptions = [
    'English',
    'Hindi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Marathi',
    'Other',
  ];

  final Set<String> _selectedSkills = {};
  final Set<String> _selectedLanguages = {'English'};
  double _serviceRadius = 5;
  bool _saving = false;

  Map<String, dynamic>? get _account => AuthService.currentUser;

  String get _helperName {
    final name = _account?['full_name'];
    return name is String && name.trim().isNotEmpty
        ? name.trim()
        : 'CareCircle helper';
  }

  String get _phone {
    final phone = _account?['phone'];
    return phone is String && phone.trim().isNotEmpty ? phone.trim() : '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSkills.isEmpty || _selectedLanguages.isEmpty) {
      _showMessage('Select at least one service and one language.');
      return;
    }

    setState(() => _saving = true);

    try {
      final profile = await HelperService.saveProfile(
        address: _addressController.text,
        skills: _selectedSkills.toList()..sort(),
        languages: _selectedLanguages.toList()..sort(),
        serviceRadiusKm: _serviceRadius.round(),
      );

      if (!mounted) return;

      final radiusValue = profile['service_radius_km'];
      final radius = radiusValue is num ? radiusValue.toDouble() : _serviceRadius;
      final skills = _split(profile['skills']);
      final languages = _split(profile['languages']);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HelperDashboardScreen(
            helperName: _helperName,
            phone: _phone,
            address: profile['address'] as String? ?? _addressController.text.trim(),
            emergencyName: '',
            emergencyPhone: '',
            skills: skills,
            languages: languages,
            available: profile['is_available'] == true,
            radius: radius,
            verificationStatus:
                profile['verification_status'] as String? ?? 'pending',
          ),
        ),
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Could not save your helper profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _split(dynamic value) {
    if (value is! String || value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              _Header(
                icon: Icons.volunteer_activism_rounded,
                title: 'Join CareCircle, $_helperName',
                subtitle:
                    'Set up your helper profile so families can find support in their area.',
              ),
              const SizedBox(height: 20),
              _InfoCard(
                icon: Icons.verified_user_outlined,
                title: 'Your account details',
                message: _phone.isEmpty
                    ? 'Name: $_helperName. Your account phone number is not available. You can update it through your account settings.'
                    : 'Name: $_helperName\nPhone: $_phone\nThese details come from the account you registered with.',
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Home address'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Enter an address with at least 5 characters.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Your residential address',
                  hintText: 'House/flat, street, area, city, PIN code',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Services you can provide'),
              const SizedBox(height: 6),
              const Text(
                'Choose only the services you are comfortable and able to provide.',
                style: TextStyle(color: CareCircleColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ..._serviceOptions.map((service) {
                final selected = _selectedSkills.contains(service);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ChoiceTile(
                    title: service,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedSkills.remove(service);
                        } else {
                          _selectedSkills.add(service);
                        }
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 18),
              const _SectionTitle('Languages you speak'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languageOptions.map((language) {
                  final selected = _selectedLanguages.contains(language);
                  return FilterChip(
                    label: Text(language),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedLanguages.add(language);
                        } else {
                          _selectedLanguages.remove(language);
                        }
                      });
                    },
                    selectedColor: CareCircleColors.primaryLight,
                    checkmarkColor: CareCircleColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Service area'),
              const SizedBox(height: 8),
              Text(
                'Maximum travel distance: ${_serviceRadius.round()} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
              Slider(
                value: _serviceRadius,
                min: 1,
                max: 25,
                divisions: 24,
                label: '${_serviceRadius.round()} km',
                activeColor: CareCircleColors.primary,
                onChanged: (value) => setState(() => _serviceRadius = value),
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.shield_outlined,
                title: 'Verification comes first',
                message:
                    'Your profile will be saved with a pending verification status. You will not receive real care requests or be allowed to switch availability on until an authorised administrator verifies your account.',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveAndContinue,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving profile...' : 'Save helper profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard constructor is kept compatible with AuthNavigation.
/// All helper profile and request data is loaded from the backend.
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
  final String verificationStatus;

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
    this.verificationStatus = 'pending',
  });

  @override
  State<HelperDashboardScreen> createState() => _HelperDashboardScreenState();
}

class _HelperDashboardScreenState extends State<HelperDashboardScreen> {
  int _selectedTab = 0;
  bool _loading = true;
  bool _changingAvailability = false;
  String? _error;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _myRequests = [];
  List<Map<String, dynamic>> _completed = [];

  String get _verificationStatus =>
      (_profile?['verification_status'] as String? ??
              widget.verificationStatus)
          .toLowerCase();

  bool get _isVerified => _verificationStatus == 'verified';
  bool get _isAvailable => _profile?['is_available'] == true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        HelperService.getProfile(),
        HelperService.getOffers(),
        HelperService.getMyRequests(),
        HelperService.getCompletedRequests(),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as Map<String, dynamic>;
        _offers = results[1] as List<Map<String, dynamic>>;
        _myRequests = results[2] as List<Map<String, dynamic>>;
        _completed = results[3] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your helper dashboard. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _changeAvailability(bool value) async {
    if (!_isVerified && value) {
      _message('Your profile must be verified before you can become available.');
      return;
    }
    if (_changingAvailability) return;

    setState(() => _changingAvailability = true);
    try {
      final result = await HelperService.updateAvailability(value);
      if (!mounted) return;
      setState(() {
        _profile = {
          ...?_profile,
          'is_available': result['is_available'] == true,
        };
        _changingAvailability = false;
      });
      _message(result['message'] as String? ?? 'Availability updated.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _changingAvailability = false);
      _message(error.message);
      await _loadDashboard();
    } catch (_) {
      if (!mounted) return;
      setState(() => _changingAvailability = false);
      _message('Could not update availability. Please try again.');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeTab(),
      _requestListTab('Incoming offers', _offers, emptyTitle: 'No offers yet',
          emptyMessage: 'New offers assigned to your helper profile will appear here.'),
      _requestListTab('My requests', _myRequests,
          emptyTitle: 'No assigned requests',
          emptyMessage: 'Requests you accept or are assigned to will appear here.'),
      _profileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle Helper'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorView()
                : IndexedStack(index: _selectedTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Offers',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'My requests',
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

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44,
                color: CareCircleColors.textSecondary),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CareCircleColors.primary, CareCircleColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HELPER DASHBOARD',
                    style: TextStyle(color: Colors.white70, letterSpacing: 1.2,
                        fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Hello, ${widget.helperName}!',
                    style: const TextStyle(color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  _isVerified
                      ? 'Your verified helper account is ready.'
                      : 'Your profile has been submitted for verification.',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isAvailable ? 'Available for requests' : 'Not available',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_changingAvailability)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Switch(
                        value: _isAvailable,
                        onChanged: _isVerified ? _changeAvailability : null,
                        activeTrackColor: CareCircleColors.secondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _statusBanner(),
          const SizedBox(height: 22),
          const _SectionTitle('Your activity'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(
                title: 'Incoming offers', value: '${_offers.length}',
                icon: Icons.inbox_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(
                title: 'Active requests', value: '${_myRequests.length}',
                icon: Icons.assignment_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(
                title: 'Completed', value: '${_completed.length}',
                icon: Icons.task_alt_rounded)),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Recent activity'),
          const SizedBox(height: 10),
          if (_myRequests.isEmpty && _completed.isEmpty)
            const _EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nothing here yet',
              message: 'Your real assigned and completed care requests will appear here.',
            )
          else ...[
            ..._myRequests.take(2).map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RequestCard(request: request),
            )),
            ..._completed.take(2).map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RequestCard(request: request),
            )),
          ],
        ],
      ),
    );
  }

  Widget _statusBanner() {
    final title = _isVerified ? 'Profile verified' : 'Verification pending';
    final message = _isVerified
        ? 'Your account has been marked verified by the backend.'
        : 'You can review your profile, but availability remains disabled until an administrator verifies your account.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isVerified ? CareCircleColors.primaryLight : CareCircleColors.secondaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CareCircleColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
              color: CareCircleColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary)),
                const SizedBox(height: 5),
                Text(message, style: const TextStyle(height: 1.4,
                    color: CareCircleColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestListTab(
    String title,
    List<Map<String, dynamic>> requests, {
    required String emptyTitle,
    required String emptyMessage,
  }) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(title),
          const SizedBox(height: 14),
          if (requests.isEmpty)
            _EmptyState(
              icon: Icons.inbox_outlined,
              title: emptyTitle,
              message: emptyMessage,
            )
          else
            ...requests.map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestCard(request: request),
            )),
        ],
      ),
    );
  }

  Widget _profileTab() {
    final profile = _profile ?? <String, dynamic>{};
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionTitle('Helper profile'),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              children: [
                _DetailRow(label: 'Name', value: widget.helperName),
                _DetailRow(label: 'Phone', value: widget.phone.isEmpty ? 'Not provided' : widget.phone),
                _DetailRow(label: 'Address', value: profile['address'] as String? ?? widget.address),
                _DetailRow(label: 'Languages', value: profile['languages'] as String? ?? widget.languages.join(', ')),
                _DetailRow(label: 'Service radius', value: '${profile['service_radius_km'] ?? widget.radius.round()} km'),
                _DetailRow(label: 'Verification', value: _verificationStatus),
                _DetailRow(label: 'Availability', value: _isAvailable ? 'Available' : 'Unavailable'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Services selected'),
          const SizedBox(height: 10),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _split(profile['skills'] ?? widget.skills.join(', '))
                  .map((skill) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, size: 18,
                          color: CareCircleColors.primary),
                      const SizedBox(width: 9),
                      Expanded(child: Text(skill)),
                    ]),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _split(dynamic value) {
    if (value is! String || value.trim().isEmpty) return [];
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final id = request['id']?.toString() ?? '—';
    final status = request['status']?.toString().replaceAll('_', ' ') ?? 'unknown';
    final name = request['elderly_name']?.toString() ?? 'Care recipient';
    final service = request['service']?.toString() ?? 'Care service';
    final address = request['address']?.toString() ?? '';
    final date = request['scheduled_date']?.toString() ?? '';
    final time = request['scheduled_time']?.toString() ?? '';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(service, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16,
                  color: CareCircleColors.textPrimary))),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 9),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(address, style: const TextStyle(color: CareCircleColors.textSecondary)),
          ],
          const SizedBox(height: 8),
          Text('Request #$id  •  $date  •  ${_shortTime(time)}',
              style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary)),
        ],
      ),
    );
  }

  String _shortTime(String value) => value.length >= 5 ? value.substring(0, 5) : value;
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: CareCircleColors.primaryDark)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: CareCircleColors.primary, size: 21),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 22,
          fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
      const SizedBox(height: 3),
      Text(title, style: const TextStyle(fontSize: 11,
          color: CareCircleColors.textSecondary)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(children: [
      Icon(icon, size: 38, color: CareCircleColors.primary),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary)),
      const SizedBox(height: 6),
      Text(message, textAlign: TextAlign.center,
          style: const TextStyle(height: 1.4, color: CareCircleColors.textSecondary)),
    ]),
  );
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: CareCircleColors.border),
    ),
    child: child,
  );
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Header({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(21)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 48, height: 48,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: CareCircleColors.primary, size: 25)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700,
            color: CareCircleColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(height: 1.45,
            color: CareCircleColors.textSecondary)),
      ])),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary));
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceTile({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? CareCircleColors.primaryLight : Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected
                ? CareCircleColors.primary : CareCircleColors.border)),
        child: Row(children: [
          Icon(selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? CareCircleColors.primary : CareCircleColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
              color: CareCircleColors.textPrimary))),
        ]),
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _InfoCard({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: CareCircleColors.secondaryLight,
        borderRadius: BorderRadius.circular(16)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: CareCircleColors.secondary),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
            color: CareCircleColors.textPrimary)),
        const SizedBox(height: 5),
        Text(message, style: const TextStyle(fontSize: 12, height: 1.45,
            color: CareCircleColors.textPrimary)),
      ])),
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 105, child: Text(label,
          style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary))),
      const SizedBox(width: 8),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: CareCircleColors.textPrimary))),
    ]),
  );
}
