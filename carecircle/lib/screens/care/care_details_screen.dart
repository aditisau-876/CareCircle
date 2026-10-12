import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'review_care_request_screen.dart';

class CareDetailsScreen extends StatefulWidget {
  final String elderlyName;
  final String service;
  final DateTime date;
  final TimeOfDay time;

  const CareDetailsScreen({
    super.key,
    required this.elderlyName,
    required this.service,
    required this.date,
    required this.time,
  });

  @override
  State<CareDetailsScreen> createState() => _CareDetailsScreenState();
}

class _CareDetailsScreenState extends State<CareDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _duration;
  String? _mobility;
  String? _language;

  bool _familySharing = true;

  final List<String> _durations = [
    '30 minutes',
    '1 hour',
    '2 hours',
    '3 hours',
    '4 hours',
    'More than 4 hours',
  ];

  final List<String> _mobilityOptions = [
    'Independent',
    'Needs occasional assistance',
    'Uses walking support',
    'Mostly needs assistance',
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

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_duration == null ||
        _mobility == null ||
        _language == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required care details.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewCareRequestScreen(
          elderlyName: widget.elderlyName,
          service: widget.service,
          date: widget.date,
          time: widget.time,
          address: _addressController.text.trim(),
          duration: _duration!,
          mobility: _mobility!,
          language: _language!,
          instructions: _instructionsController.text.trim(),
          familySharing: _familySharing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Care details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressIndicator(),

                      const SizedBox(height: 28),

                      Text(
                        'Tell us what they need',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'These details help us match the request with a suitable verified helper.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle(
                        'Care location',
                        'Where should the helper provide the service?',
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Care address',
                          hintText: 'Enter the complete address',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 38),
                            child: Icon(
                              Icons.location_on_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the care address';
                          }

                          if (value.trim().length < 10) {
                            return 'Please enter a more complete address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle(
                        'Time & duration',
                        'Tell us how long the helper may be needed.',
                      ),

                      const SizedBox(height: 12),

                      _buildDropdown(
                        label: 'Expected duration',
                        hint: 'Select duration',
                        value: _duration,
                        items: _durations,
                        icon: Icons.schedule_outlined,
                        onChanged: (value) {
                          setState(() {
                            _duration = value;
                          });
                        },
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle(
                        'Assistance needs',
                        'This helps us understand the level of support required.',
                      ),

                      const SizedBox(height: 12),

                      _buildDropdown(
                        label: 'Mobility assistance',
                        hint: 'Select assistance level',
                        value: _mobility,
                        items: _mobilityOptions,
                        icon: Icons.accessibility_new_outlined,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      _buildDropdown(
                        label: 'Preferred helper language',
                        hint: 'Select preferred language',
                        value: _language,
                        items: _languages,
                        icon: Icons.language_outlined,
                        onChanged: (value) {
                          setState(() {
                            _language = value;
                          });
                        },
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle(
                        'Additional instructions',
                        'Anything the helper should know before arriving?',
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText:
                          'Example: Please call before arriving...',
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildFamilyUpdatesCard(),

                      const SizedBox(height: 26),

                      _buildRequestSummary(),
                    ],
                  ),
                ),
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
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

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CareCircleColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: CareCircleColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      hint: Text(hint),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFamilyUpdatesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: CareCircleColors.primary,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family care updates',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Receive updates about the helper and care progress.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: CareCircleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _familySharing,
            activeThumbColor: CareCircleColors.primary,
            onChanged: (value) {
              setState(() {
                _familySharing = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: CareCircleColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.service} for ${widget.elderlyName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(widget.date)} • ${_formatTime(widget.time)}',
                  style: const TextStyle(
                    fontSize: 13,
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _continue,
        child: const Text('Continue to review'),
      ),
    );
  }
}