import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'arrival_verification_screen.dart';
import 'care_task_screen.dart';

class CareTrackingScreen extends StatefulWidget {
  final String elderlyName;
  final String service;
  final DateTime date;
  final TimeOfDay time;

  // Full care-request information.
  final String address;
  final String duration;
  final String mobility;
  final String language;
  final String instructions;
  final bool familySharing;

  // Which stage should the tracking screen start from?
  final int initialStep;

  const CareTrackingScreen({
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
    this.initialStep = 0,
  });

  @override
  State<CareTrackingScreen> createState() => _CareTrackingScreenState();
}

class _CareTrackingScreenState extends State<CareTrackingScreen> {
  late int _currentStep;

  final List<String> _statuses = [
    'Helper assigned',
    'On the way',
    'Arrived',
    'Task started',
    'Completed',
  ];

  final List<String> _descriptions = [
    'Your CareCircle helper has accepted the request.',
    'Your helper is on the way to the care recipient.',
    'Your helper has reached the care recipient location.',
    'The requested care service is now in progress.',
    'The care request has been completed successfully.',
  ];

  final List<IconData> _icons = [
    Icons.person_outline_rounded,
    Icons.directions_walk_rounded,
    Icons.location_on_outlined,
    Icons.volunteer_activism_outlined,
    Icons.check_circle_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _currentStep = widget.initialStep.clamp(0, _statuses.length - 1);
  }

  String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void _updateStatus() {
    if (_currentStep == 2) {
      // Arrived → verify arrival before starting the care task.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArrivalVerificationScreen(
            elderlyName: widget.elderlyName,
            service: widget.service,
            date: widget.date,
            time: widget.time,
            address: widget.address,
            duration: widget.duration,
            mobility: widget.mobility,
            language: widget.language,
            instructions: widget.instructions,
            familySharing: widget.familySharing,
          ),
        ),
      );

      return;
    }

    if (_currentStep == 3) {
      // Task started → open the actual care task.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CareTaskScreen(
            elderlyName: widget.elderlyName,
            service: widget.service,
            date: widget.date,
            time: widget.time,
            address: widget.address,
            duration: widget.duration,
            mobility: widget.mobility,
            language: widget.language,
            instructions: widget.instructions,
            familySharing: widget.familySharing,
          ),
        ),
      );

      return;
    }

    if (_currentStep < _statuses.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Color _statusColor(int index) {
    if (index < _currentStep) {
      return CareCircleColors.success;
    }

    if (index == _currentStep) {
      return CareCircleColors.primary;
    }

    return CareCircleColors.border;
  }

  // Information row used in the scheduled request card.
  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            size: 19,
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
                  fontWeight: FontWeight.w500,
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
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = _currentStep == _statuses.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care tracking'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLiveStatusCard(),
                    const SizedBox(height: 18),
                    _buildHelperCard(),
                    const SizedBox(height: 22),
                    Text(
                      'Care journey',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    _buildTimeline(),
                    const SizedBox(height: 22),
                    _buildRequestCard(),
                    const SizedBox(height: 18),
                    _buildSafetyCard(),
                    if (completed) ...[
                      const SizedBox(height: 18),
                      _buildCompletedCard(),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomButton(completed),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'LIVE CARE STATUS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _statuses[_currentStep],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _descriptions[_currentStep],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 30,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: CareCircleColors.success,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'CareCircle Verified',
                      style: TextStyle(
                        fontSize: 12,
                        color: CareCircleColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.call_rounded,
              color: CareCircleColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: List.generate(
          _statuses.length,
              (index) {
            final bool isLast = index == _statuses.length - 1;
            final bool isCompleted = index < _currentStep;
            final bool isCurrent = index == _currentStep;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? CareCircleColors.primaryLight
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : _icons[index],
                        color: _statusColor(index),
                        size: 21,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 38,
                        color: index < _currentStep
                            ? CareCircleColors.success
                            : CareCircleColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statuses[index],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isCurrent || isCompleted
                                ? CareCircleColors.textPrimary
                                : CareCircleColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted
                              ? 'Completed'
                              : isCurrent
                              ? 'Current status'
                              : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrent
                                ? CareCircleColors.primary
                                : CareCircleColors.textSecondary,
                          ),
                        ),
                        if (!isLast) const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.person_outline_rounded,
            'Care recipient',
            widget.elderlyName,
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.volunteer_activism_outlined,
            'Service',
            widget.service,
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.calendar_today_outlined,
            'Date',
            _formatDate(widget.date),
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.access_time_rounded,
            'Time',
            _formatTime(widget.time),
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.location_on_outlined,
            'Location',
            widget.address,
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.timelapse_rounded,
            'Duration',
            widget.duration,
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.accessibility_new_rounded,
            'Mobility',
            widget.mobility,
          ),
          const SizedBox(height: 13),
          _infoRow(
            Icons.language_rounded,
            'Language',
            widget.language,
          ),
        ],
      ),
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
          color: const Color(0xFFF5D9BF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: CareCircleColors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.familySharing
                  ? 'Your care updates are visible to the family member. '
                  'Arrival verification helps confirm that the helper has '
                  'reached the correct location.'
                  : 'Arrival verification helps confirm that the helper has '
                  'reached the correct location.',
              style: const TextStyle(
                fontSize: 13,
                color: CareCircleColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC9E8D6),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: CareCircleColors.success,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This care request has been completed. '
                  'The family can now review the care details and receipt.',
              style: TextStyle(
                fontSize: 13,
                color: CareCircleColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool completed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: completed
            ? () {
          Navigator.of(context).popUntil(
                (route) => route.isFirst,
          );
        }
            : _updateStatus,
        icon: Icon(
          completed
              ? Icons.home_outlined
              : _currentStep == 2
              ? Icons.verified_user_outlined
              : _currentStep == 3
              ? Icons.assignment_outlined
              : Icons.arrow_forward_rounded,
        ),
        label: Text(
          completed
              ? 'Back to home'
              : _currentStep == 2
              ? 'Verify arrival'
              : _currentStep == 3
              ? 'Open care task'
              : 'Update status',
        ),
      ),
    );
  }
}