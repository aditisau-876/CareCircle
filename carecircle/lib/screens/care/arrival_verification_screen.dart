import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'care_tracking_screen.dart';

class ArrivalVerificationScreen extends StatefulWidget {
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

  const ArrivalVerificationScreen({
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
  State<ArrivalVerificationScreen> createState() =>
      _ArrivalVerificationScreenState();
}

class _ArrivalVerificationScreenState
    extends State<ArrivalVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  static const String _demoOtp = '2468';

  bool _isVerifying = false;
  bool _showDemoCode = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      _showMessage('Please enter the 4-digit verification code.');
      return;
    }

    if (otp != _demoOtp) {
      _showMessage('Incorrect code. Please try again.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    await _showSuccessDialog();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: CareCircleColors.primary,
              size: 34,
            ),
          ),
          title: const Text(
            'Arrival verified',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'The helper has been verified as arrived. '
                'You can now proceed with the care task.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CareTrackingScreen(
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
          initialStep: 3,
        ),
      ),
    );
  }

  String _formatDate() {
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

    return '${months[widget.date.month - 1]} '
        '${widget.date.day}, ${widget.date.year}';
  }

  String _formatTime() {
    final hour = widget.time.hourOfPeriod == 0
        ? 12
        : widget.time.hourOfPeriod;

    final minute = widget.time.minute.toString().padLeft(2, '0');
    final period = widget.time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrival verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgress(),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: CareCircleColors.primary,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Confirm arrival',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verify that your CareCircle helper has arrived '
                          'before the task begins.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _buildCareSummary(),

              const SizedBox(height: 22),

              _buildOtpCard(),

              const SizedBox(height: 18),

              _buildSafetyCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        _progressCircle(
          number: '1',
          label: 'Assigned',
          active: true,
        ),
        _progressLine(active: true),
        _progressCircle(
          number: '2',
          label: 'Arrived',
          active: true,
        ),
        _progressLine(active: false),
        _progressCircle(
          number: '3',
          label: 'Task',
          active: false,
        ),
      ],
    );
  }

  Widget _progressCircle({
    required String number,
    required String label,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active
                ? CareCircleColors.primary
                : CareCircleColors.border,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : CareCircleColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active
                ? FontWeight.w600
                : FontWeight.w400,
            color: active
                ? CareCircleColors.primary
                : CareCircleColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _progressLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(
          left: 6,
          right: 6,
          bottom: 22,
        ),
        color: active
            ? CareCircleColors.primary
            : CareCircleColors.border,
      ),
    );
  }

  Widget _buildCareSummary() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled care',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CareCircleColors.textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.service,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.person_outline_rounded,
            widget.elderlyName,
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.calendar_today_outlined,
            _formatDate(),
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.access_time_outlined,
            _formatTime(),
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.location_on_outlined,
            widget.address,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: CareCircleColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: CareCircleColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
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
            'Enter verification code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CareCircleColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Ask the helper for the 4-digit arrival code.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: CareCircleColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
            ),
            decoration: const InputDecoration(
              hintText: '••••',
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          if (_showDemoCode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CareCircleColors.secondaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Demo verification code: 2468',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ),
          if (_showDemoCode) const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showDemoCode = !_showDemoCode;
              });
            },
            icon: Icon(
              _showDemoCode
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(
              _showDemoCode
                  ? 'Hide demo code'
                  : 'Show demo code',
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: _isVerifying ? null : _verifyOtp,
            child: _isVerifying
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Text('Verify arrival'),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: CareCircleColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.familySharing
                  ? 'Family care updates are enabled for this request.'
                  : 'Family care updates are currently turned off for this request.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: CareCircleColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}