import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../dashboard/family_dashboard_screen.dart';

class CareCompletionScreen extends StatefulWidget {
  final String elderlyName;
  final String service;
  final DateTime date;
  final TimeOfDay time;

  // Request details
  final String address;
  final String duration;
  final String mobility;
  final String language;
  final String instructions;
  final bool familySharing;

  // Task completion details
  final String purchaseAmount;
  final String careNotes;
  final bool receiptAdded;

  const CareCompletionScreen({
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
    required this.purchaseAmount,
    required this.careNotes,
    required this.receiptAdded,
  });

  @override
  State<CareCompletionScreen> createState() =>
      _CareCompletionScreenState();
}

class _CareCompletionScreenState
    extends State<CareCompletionScreen> {
  bool _confirmed = false;

  // Temporary frontend value.
  // This will later come from the backend/payment system.
  static const double _careFee = 100.00;

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

  double get _purchaseCost {
    return double.tryParse(widget.purchaseAmount) ?? 0;
  }

  double get _totalAmount {
    return _purchaseCost + _careFee;
  }

  String _money(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  void _confirmCare() {
    setState(() {
      _confirmed = true;
    });
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FamilyDashboardScreen(
          elderlyName: widget.elderlyName,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care completed'),
        automaticallyImplyLeading: false,
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
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuccessHeader(),
                    const SizedBox(height: 20),
                    _buildCareSummary(),
                    const SizedBox(height: 18),
                    _buildRequestDetails(),
                    const SizedBox(height: 18),
                    _buildCostCard(),
                    const SizedBox(height: 18),
                    _buildReceiptCard(),
                    if (widget.careNotes.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _buildNotesCard(),
                    ],
                    const SizedBox(height: 18),
                    _buildPaymentCard(),
                    const SizedBox(height: 18),
                    _buildConfirmationCard(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Care task completed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The service has been completed and the care details are ready for review.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.volunteer_activism_outlined,
                color: CareCircleColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Care summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _summaryRow(
            Icons.person_outline_rounded,
            'Care recipient',
            widget.elderlyName,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.medical_services_outlined,
            'Service',
            widget.service,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.calendar_today_outlined,
            'Date',
            _formatDate(widget.date),
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.access_time_rounded,
            'Time',
            _formatTime(widget.time),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: CareCircleColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Request details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _summaryRow(
            Icons.location_on_outlined,
            'Location',
            widget.address,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.timer_outlined,
            'Duration',
            widget.duration,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.accessibility_new_outlined,
            'Mobility',
            widget.mobility,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.language_outlined,
            'Language',
            widget.language,
          ),
          const SizedBox(height: 13),
          _summaryRow(
            Icons.share_outlined,
            'Family sharing',
            widget.familySharing ? 'Enabled' : 'Disabled',
          ),
          if (widget.instructions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: CareCircleColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_outlined,
                    size: 19,
                    color: CareCircleColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special instructions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CareCircleColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.instructions,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: CareCircleColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: CareCircleColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Expense summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _amountRow(
            'Purchase / service cost',
            _money(_purchaseCost),
          ),
          const SizedBox(height: 13),
          _amountRow(
            'Care service fee',
            _money(_careFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(
              color: CareCircleColors.border,
            ),
          ),
          _amountRow(
            'Total',
            _money(_totalAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.receiptAdded
                  ? const Color(0xFFEAF6EF)
                  : CareCircleColors.secondaryLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              widget.receiptAdded
                  ? Icons.receipt_long_rounded
                  : Icons.receipt_long_outlined,
              color: widget.receiptAdded
                  ? CareCircleColors.success
                  : CareCircleColors.secondary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiptAdded
                      ? 'Receipt attached'
                      : 'No receipt attached',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.receiptAdded
                      ? 'The receipt is available for family review.'
                      : 'A receipt was not added for this task.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CareCircleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            widget.receiptAdded
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: widget.receiptAdded
                ? CareCircleColors.success
                : CareCircleColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_rounded,
                color: CareCircleColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Care notes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: CareCircleColors.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              widget.careNotes,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: CareCircleColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: CareCircleColors.secondary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payment processing will be connected later. '
                  'For now, this screen shows the purchase amount and '
                  'CareCircle service fee separately.',
              style: TextStyle(
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

  Widget _buildConfirmationCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _confirmed
            ? const Color(0xFFEAF6EF)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _confirmed
              ? const Color(0xFFC9E8D6)
              : CareCircleColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _confirmed
                    ? Icons.verified_rounded
                    : Icons.check_circle_outline_rounded,
                color: _confirmed
                    ? CareCircleColors.success
                    : CareCircleColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _confirmed
                      ? 'Care received confirmed'
                      : 'Confirm care received',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _confirmed
                ? 'The care request has been confirmed. Thank you for using CareCircle.'
                : 'Please confirm that the requested care service was received successfully.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: CareCircleColors.textSecondary,
            ),
          ),
          if (!_confirmed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmCare,
                icon: const Icon(
                  Icons.thumb_up_alt_outlined,
                ),
                label: const Text(
                  'Yes, care was received',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        18,
      ),
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
        onPressed: _confirmed ? _goToDashboard : null,
        icon: const Icon(
          Icons.home_outlined,
        ),
        label: const Text(
          'Return to dashboard',
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
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
      child: child,
    );
  }

  Widget _summaryRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: CareCircleColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 13,
            color: CareCircleColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CareCircleColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountRow(
      String title,
      String amount, {
        bool isTotal = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
              isTotal ? FontWeight.w700 : FontWeight.w500,
              color: CareCircleColors.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w700,
            color: isTotal
                ? CareCircleColors.primary
                : CareCircleColors.textPrimary,
          ),
        ),
      ],
    );
  }
}