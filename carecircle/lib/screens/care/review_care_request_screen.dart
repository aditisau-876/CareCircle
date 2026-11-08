import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../features/care/data/care_request_service.dart';
import 'request_submitted_screen.dart';

class ReviewCareRequestScreen extends StatefulWidget {
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

  @override
  State<ReviewCareRequestScreen> createState() =>
      _ReviewCareRequestScreenState();
}

class _ReviewCareRequestScreenState extends State<ReviewCareRequestScreen> {
  bool _isSubmitting = false;

  String _formatDate(DateTime value) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _confirmRequest() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final savedRequest = await CareRequestService.createRequest(
        elderlyName: widget.elderlyName,
        service: widget.service,
        address: widget.address,
        date: widget.date,
        time: _formatTime(widget.time),
        duration: widget.duration,
        mobility: widget.mobility,
        language: widget.language,
        instructions: widget.instructions,
        familySharing: widget.familySharing,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RequestSubmittedScreen(
            requestId: savedRequest['id'] as int,
            elderlyName: widget.elderlyName,
            service: widget.service,
            date: widget.date,
            time: widget.time,
            address: widget.address,
            status: savedRequest['status'] as String? ?? 'pending',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while submitting the request.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        title: const Text('Review request'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _progressIndicator(),
                    const SizedBox(height: 28),
                    Text(
                      'Everything looks good?',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please review the details. Your request will be saved to your CareCircle account.',
                      style: TextStyle(
                        color: CareCircleColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _mainCard(),
                    const SizedBox(height: 16),
                    _detailCard(
                      title: 'Schedule and location',
                      icon: Icons.location_on_outlined,
                      rows: [
                        _row(Icons.calendar_today_outlined, 'Date', _formatDate(widget.date)),
                        _row(Icons.schedule_outlined, 'Time', _formatTime(widget.time)),
                        _row(Icons.location_on_outlined, 'Address', widget.address),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _detailCard(
                      title: 'Care preferences',
                      icon: Icons.volunteer_activism_outlined,
                      rows: [
                        _row(Icons.timelapse_rounded, 'Duration', widget.duration),
                        _row(Icons.accessible_forward_rounded, 'Mobility', widget.mobility),
                        _row(Icons.language_rounded, 'Language', widget.language),
                      ],
                    ),
                    if (widget.instructions.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _detailCard(
                        title: 'Additional instructions',
                        icon: Icons.notes_rounded,
                        rows: [
                          _row(Icons.notes_rounded, 'Notes', widget.instructions),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
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
                          const Icon(Icons.shield_outlined, color: CareCircleColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.familySharing
                                  ? 'Family updates are enabled for this request.'
                                  : 'Family updates are disabled for this request.',
                              style: const TextStyle(
                                color: CareCircleColors.primaryDark,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Submitting this request saves it to the server. Helper matching will be handled in the next workflow step.',
                      style: TextStyle(
                        color: CareCircleColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _confirmRequest,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_isSubmitting ? 'Submitting request...' : 'Confirm and submit request'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressIndicator() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: CareCircleColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CareCircleColors.primary, CareCircleColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 14),
          Text(
            widget.service,
            style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'For ${widget.elderlyName}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required IconData icon,
    required List<Widget> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareCircleColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CareCircleColors.primary, size: 20),
              const SizedBox(width: 9),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ..._withSpacing(rows),
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children) {
    final result = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) result.add(const SizedBox(height: 13));
      result.add(children[index]);
    }
    return result;
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: CareCircleColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(color: CareCircleColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: CareCircleColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
