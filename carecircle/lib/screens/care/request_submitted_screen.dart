import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Confirms that a request was persisted by the backend.
/// This screen intentionally does not pretend that a helper has been matched.
class RequestSubmittedScreen extends StatelessWidget {
  final int requestId;
  final String elderlyName;
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final String address;
  final String status;

  const RequestSubmittedScreen({
    super.key,
    required this.requestId,
    required this.elderlyName,
    required this.service,
    required this.date,
    required this.time,
    required this.address,
    required this.status,
  });

  String _formatDate(DateTime value) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  void _returnToDashboard(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: CareCircleColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 68,
                      color: CareCircleColors.success,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Request submitted',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your care request has been saved successfully. You can find it in your CareCircle request history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CareCircleColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: CareCircleColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Request reference',
                              style: TextStyle(
                                color: CareCircleColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '#$requestId',
                              style: const TextStyle(
                                color: CareCircleColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _summaryRow('Service', service),
                        _summaryRow('For', elderlyName),
                        _summaryRow('Date', _formatDate(date)),
                        _summaryRow('Time', _formatTime(time)),
                        _summaryRow('Address', address),
                        _summaryRow('Status', status.replaceAll('_', ' ')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CareCircleColors.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: CareCircleColors.primary),
                        SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Status: Pending. Helper matching and live tracking will become available once those workflows are connected.',
                            style: TextStyle(
                              color: CareCircleColors.primaryDark,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _returnToDashboard(context),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Return to dashboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(
                color: CareCircleColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CareCircleColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
