import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'helper_found_screen.dart';

class RequestSubmittedScreen extends StatefulWidget {
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

  const RequestSubmittedScreen({
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

  @override
  State<RequestSubmittedScreen> createState() =>
      _RequestSubmittedScreenState();
}

class _RequestSubmittedScreenState extends State<RequestSubmittedScreen> {
  Timer? _timer;

  double _progress = 0.0;
  int _currentMessage = 0;

  final List<String> _messages = [
    'Finding verified helpers near you...',
    'Checking availability and service skills...',
    'Matching the best helper for this request...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();

    _startMatching();
  }

  void _startMatching() {
    const totalSteps = 4;
    int step = 0;

    _timer = Timer.periodic(
      const Duration(milliseconds: 850),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        step++;

        setState(() {
          _progress = step / totalSteps;

          if (step < _messages.length) {
            _currentMessage = step;
          }
        });

        if (step >= totalSteps) {
          timer.cancel();

          Future.delayed(
            const Duration(milliseconds: 600),
                () {
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HelperFoundScreen(
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
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const Spacer(),

              // Main animation / icon
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CareCircleColors.primaryLight,
                  boxShadow: [
                    BoxShadow(
                      color: CareCircleColors.primary.withValues(alpha: 0.10),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CareCircleColors.primary,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Finding the right helper',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 10),

              Text(
                _messages[_currentMessage],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 30),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: CareCircleColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CareCircleColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '${(_progress * 100).round()}% complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CareCircleColors.primary,
                ),
              ),

              const SizedBox(height: 34),

              // Request summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: CareCircleColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: CareCircleColors.secondaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_rounded,
                            color: CareCircleColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.service,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'For ${widget.elderlyName}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Divider(
                      color: CareCircleColors.border,
                      height: 1,
                    ),

                    const SizedBox(height: 16),

                    _SummaryRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: _formatDate(widget.date),
                    ),

                    const SizedBox(height: 12),

                    _SummaryRow(
                      icon: Icons.schedule_rounded,
                      label: 'Time',
                      value: _formatTime(widget.time),
                    ),

                    const SizedBox(height: 12),

                    _SummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: widget.address,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Privacy / safety note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CareCircleColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: CareCircleColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CareCircle will match your request with an available verified helper based on location, availability and service requirements.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: CareCircleColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'You can review the helper before accepting the match.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: CareCircleColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: CareCircleColors.primary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: CareCircleColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}