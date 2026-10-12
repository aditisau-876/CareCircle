import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'care_tracking_screen.dart';

class HelperFoundScreen extends StatelessWidget {
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

  const HelperFoundScreen({
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

    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Helper found',
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
                  16,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuccessHeader(),

                    const SizedBox(height: 24),

                    _buildHelperCard(),

                    const SizedBox(height: 20),

                    _buildRequestCard(),

                    const SizedBox(height: 20),

                    _buildCareDetailsCard(),

                    const SizedBox(height: 20),

                    _buildSafetyCard(),

                    const SizedBox(height: 24),
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

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE5F3F0),
            Color(0xFFF5FAF9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CareCircleColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: CareCircleColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CareCircleColors.primary.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'A helper is ready',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'We found a verified CareCircle helper for this request.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: CareCircleColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CareCircleColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your helper',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 34,
                  color: CareCircleColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ananya Sharma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: CareCircleColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: CareCircleColors.primary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'CareCircle Verified',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CareCircleColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(
            height: 1,
            color: CareCircleColors.border,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  Icons.star_rounded,
                  'Rating',
                  '4.9 / 5',
                ),
              ),
              Expanded(
                child: _infoItem(
                  Icons.work_outline_rounded,
                  'Experience',
                  '3+ years',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  Icons.language_rounded,
                  'Languages',
                  'English, Hindi',
                ),
              ),
              Expanded(
                child: _infoItem(
                  Icons.location_on_outlined,
                  'Distance',
                  '1.8 km away',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
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
          color: CareCircleColors.primary,
        ),

        const SizedBox(width: 9),

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

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

  Widget _buildRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Care request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _requestRow(
            Icons.person_outline_rounded,
            'For',
            elderlyName,
          ),

          const SizedBox(height: 14),

          _requestRow(
            Icons.volunteer_activism_outlined,
            'Service',
            service,
          ),

          const SizedBox(height: 14),

          _requestRow(
            Icons.calendar_today_outlined,
            'Date',
            _formatDate(date),
          ),

          const SizedBox(height: 14),

          _requestRow(
            Icons.access_time_rounded,
            'Time',
            _formatTime(time),
          ),

          const SizedBox(height: 14),

          _requestRow(
            Icons.location_on_outlined,
            'Location',
            address,
          ),
        ],
      ),
    );
  }

  Widget _requestRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CareCircleColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: CareCircleColors.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CareCircleColors.textSecondary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

  Widget _buildCareDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Care details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _detailLine(
            Icons.schedule_outlined,
            'Duration',
            duration,
          ),

          const SizedBox(height: 14),

          _detailLine(
            Icons.accessibility_new_outlined,
            'Mobility',
            mobility,
          ),

          const SizedBox(height: 14),

          _detailLine(
            Icons.language_outlined,
            'Preferred language',
            language,
          ),

          if (instructions.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _detailLine(
              Icons.notes_rounded,
              'Instructions',
              instructions,
            ),
          ],

          const SizedBox(height: 14),

          _detailLine(
            Icons.notifications_active_outlined,
            'Family updates',
            familySharing ? 'Enabled' : 'Not enabled',
          ),
        ],
      ),
    );
  }

  Widget _detailLine(
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
          color: CareCircleColors.primary,
        ),

        const SizedBox(width: 11),

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

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

  Widget _buildSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CareCircleColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CareCircleColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: CareCircleColors.secondary,
            size: 25,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CareCircle safety',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Your helper is verified before receiving care requests. You can also share care updates with your family.',
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CareTrackingScreen(
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
          },
          icon: const Icon(
            Icons.arrow_forward_rounded,
          ),
          label: const Text(
            'Accept helper & continue',
          ),
        ),
      ),
    );
  }
}