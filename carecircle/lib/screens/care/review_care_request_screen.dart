import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'request_submitted_screen.dart';

class ReviewCareRequestScreen extends StatelessWidget {
  final String elderlyName;
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final String address;
  final String duration;
  final String mobility;
  final String language;
  final String instructions;
  final bool familySharing;

  const ReviewCareRequestScreen({
    super.key,
    required this.elderlyName,
    required this.service,
    required this.date,
    required this.time,
    required this.address,
    required this.duration,
    required this.mobility,
    required this.language,
    required this.instructions,
    required this.familySharing,
  });

  String _formatDate(DateTime value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void _confirmRequest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequestSubmittedScreen(
          elderlyName: elderlyName,
          service: service,
          date: date,
          time: time,
          address: address,
          duration: duration,
          mobility: mobility,
          language: language,
          instructions: instructions,
          familySharing: familySharing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        title: const Text(
          'Review request',
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressIndicator(),

                    const SizedBox(height: 28),

                    Text(
                      'Everything looks good?',
                      style:
                      Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Review the care request before we start looking for a suitable helper.',
                      style: TextStyle(
                        color: CareCircleColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildMainRequestCard(),

                    const SizedBox(height: 16),

                    _buildCareLocationCard(),

                    const SizedBox(height: 16),

                    _buildSupportDetailsCard(),

                    const SizedBox(height: 16),

                    _buildInstructionsCard(),

                    const SizedBox(height: 16),

                    _buildFamilyUpdatesCard(),

                    const SizedBox(height: 20),

                    _buildMatchingInfoCard(),
                  ],
                ),
              ),
            ),

            _buildBottomButton(context),
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
              color: CareCircleColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainRequestCard() {
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Care request',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            service,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'For $elderlyName',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${_formatDate(date)} • ${_formatTime(time)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareLocationCard() {
    return _sectionCard(
      title: 'Care location',
      icon: Icons.location_on_outlined,
      child: Text(
        address,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: CareCircleColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSupportDetailsCard() {
    return _sectionCard(
      title: 'Support details',
      icon: Icons.accessibility_new_outlined,
      child: Column(
        children: [
          _detailRow(
            Icons.schedule_outlined,
            'Expected duration',
            duration,
          ),
          const SizedBox(height: 14),
          _detailRow(
            Icons.accessibility_new_outlined,
            'Mobility assistance',
            mobility,
          ),
          const SizedBox(height: 14),
          _detailRow(
            Icons.language_outlined,
            'Preferred helper language',
            language,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return _sectionCard(
      title: 'Additional instructions',
      icon: Icons.notes_outlined,
      child: Text(
        instructions.isEmpty
            ? 'No additional instructions provided.'
            : instructions,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: CareCircleColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFamilyUpdatesCard() {
    return _sectionCard(
      title: 'Family care updates',
      icon: Icons.notifications_none_rounded,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: familySharing
                  ? CareCircleColors.primaryLight
                  : CareCircleColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              familySharing
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: familySharing
                  ? CareCircleColors.primary
                  : CareCircleColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              familySharing
                  ? 'You will receive updates about the helper and care progress.'
                  : 'Family care updates are turned off for this request.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: CareCircleColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CareCircleColors.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: CareCircleColors.primary,
            size: 23,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How CareCircle will match',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'We will look for a suitable verified helper based on location, availability, service skills, language and care requirements.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
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

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: CareCircleColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: CareCircleColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: CareCircleColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _confirmRequest(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
            ),
            SizedBox(width: 8),
            Text('Confirm & find a helper'),
          ],
        ),
      ),
    );
  }
}