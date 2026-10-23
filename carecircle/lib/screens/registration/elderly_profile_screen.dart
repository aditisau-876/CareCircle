
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/family_dashboard_screen.dart';
import '../elderly/elderly_dashboard_screen.dart';

class ElderlyProfileScreen extends StatefulWidget {
  final String role;

  const ElderlyProfileScreen({
    super.key,
    this.role = 'family',
  });

  @override
  State<ElderlyProfileScreen> createState() =>
      _ElderlyProfileScreenState();
}

class _ElderlyProfileScreenState extends State<ElderlyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String? _relationship;
  String? _language;
  String? _mobility;

  bool _isSaving = false;

  final List<String> _relationships = [
    'Parent',
    'Grandparent',
    'Spouse',
    'Sibling',
    'Other relative',
    'Self',
  ];

  final List<String> _languages = [
    'English',
    'Hindi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Marathi',
    'Other',
  ];

  final List<String> _mobilityOptions = [
    'Independent',
    'Needs occasional assistance',
    'Uses walking support',
    'Mostly needs assistance',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.role == 'elderly') {
      _relationship = 'Self';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_relationship == null ||
        _language == null ||
        _mobility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all the required selections.'),
        ),
      );
      return;
    }

    // The current backend creates recipient profiles only for family users.
    // An elderly user's own profile endpoint has not been implemented yet.
    if (widget.role == 'elderly') {
      _openDashboard(
        elderlyName: _nameController.text.trim(),
        profileSaved: false,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final emergencyPhone =
          '+91${_emergencyPhoneController.text.trim().replaceAll(' ', '')}';

      await ApiClient.post(
        '/api/profiles/recipients',
        authenticated: true,
        body: {
          'full_name': _nameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'relationship_to_family': _relationship,
          'address': _addressController.text.trim(),
          'preferred_language': _language,
          'mobility_needs': _mobility,
          'emergency_contact_name':
          _emergencyNameController.text.trim(),
          'emergency_contact_phone': emergencyPhone,
        },
      );

      if (!mounted) return;

      _openDashboard(
        elderlyName: _nameController.text.trim(),
        profileSaved: true,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(error)),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('clientexception') ||
        lowerMessage.contains('timed out')) {
      return 'Cannot connect to CareCircle. Check that the backend is running and your phone and computer are connected to the same Wi-Fi.';
    }

    if (lowerMessage.contains('401') ||
        lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('not authenticated')) {
      return 'Your session may have expired. Please log in again.';
    }

    if (lowerMessage.contains('403') ||
        lowerMessage.contains('forbidden')) {
      return 'Your account does not have permission to save this profile. Please check your account role.';
    }

    if (lowerMessage.contains('422')) {
      return 'Some profile details were rejected by the server. Please check the entered information.';
    }

    if (lowerMessage.contains('400') ||
        lowerMessage.contains('409')) {
      return 'The profile could not be saved. Please check the details and try again.';
    }

    if (error is ApiException) {
      return message
          .replaceFirst('ApiException:', '')
          .trim();
    }

    return 'Unable to save the profile right now. Please try again.';
  }

  void _openDashboard({
    required String elderlyName,
    required bool profileSaved,
  }) {
    if (!mounted) return;

    if (!profileSaved && widget.role == 'elderly') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your dashboard is opening, but profile details have not '
                'been saved yet. Self-profile saving needs a backend endpoint.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.role == 'elderly'
            ? ElderlyDashboardScreen(elderlyName: elderlyName)
            : FamilyDashboardScreen(elderlyName: elderlyName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgress(),

                const SizedBox(height: 30),

                Text(
                  'Tell us about the\nperson you care for',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 12),

                Text(
                  'This helps us personalize care and connect the right services.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 30),

                _sectionTitle('Basic information'),

                const SizedBox(height: 16),

                _label('Full name'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter their full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter their name';
                    }

                    if (value.trim().length < 2) {
                      return 'Please enter a valid name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label('Age'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _ageController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    final age = int.tryParse(value?.trim() ?? '');

                    if (age == null) {
                      return 'Please enter a valid age';
                    }

                    if (age < 18 || age > 120) {
                      return 'Please enter an age between 18 and 120';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label(
                  widget.role == 'elderly'
                      ? 'Relationship to care recipient'
                      : 'Your relationship',
                ),

                const SizedBox(height: 8),

                _buildDropdown(
                  value: _relationship,
                  hint: 'Select relationship',
                  icon: Icons.people_outline_rounded,
                  items: _relationships,
                  onChanged: (value) {
                    setState(() {
                      _relationship = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle('Location & preferences'),

                const SizedBox(height: 16),

                _label('Care address'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _addressController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Enter their complete address',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 42),
                      child: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Please enter the complete care address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label('Preferred language'),

                const SizedBox(height: 8),

                _buildDropdown(
                  value: _language,
                  hint: 'Select preferred language',
                  icon: Icons.translate_rounded,
                  items: _languages,
                  onChanged: (value) {
                    setState(() {
                      _language = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _label('Mobility / assistance'),

                const SizedBox(height: 8),

                _buildDropdown(
                  value: _mobility,
                  hint: 'Select assistance level',
                  icon: Icons.accessible_forward_rounded,
                  items: _mobilityOptions,
                  onChanged: (value) {
                    setState(() {
                      _mobility = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle('Emergency contact'),

                const SizedBox(height: 8),

                Text(
                  'Someone CareCircle can contact if needed.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                _label('Contact name'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _emergencyNameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter contact name',
                    prefixIcon: Icon(Icons.contact_phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an emergency contact';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label('Contact phone'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _emergencyPhoneController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91  ',
                  ),
                  validator: (value) {
                    final phone =
                    (value ?? '').replaceAll(RegExp(r'\s+'), '');

                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
                      return 'Enter a valid 10-digit Indian mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _continue,
                    child: _isSaving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Continue to dashboard'),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'You can update these details later.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: _isSaving ? null : onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please make a selection';
        }

        return null;
      },
    );
  }
}
