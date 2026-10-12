import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'care_completion_screen.dart';

class CareTaskScreen extends StatefulWidget {
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

  const CareTaskScreen({
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
  State<CareTaskScreen> createState() => _CareTaskScreenState();
}

class _CareTaskScreenState extends State<CareTaskScreen> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _receiptAdded = false;
  bool _isCompleting = false;

  @override
  void dispose() {
    _costController.dispose();
    _notesController.dispose();
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

  void _toggleReceipt() {
    setState(() {
      _receiptAdded = !_receiptAdded;
    });
  }

  Future<void> _completeTask() async {
    FocusScope.of(context).unfocus();

    final cost = _costController.text.trim();

    if (cost.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the purchase or service amount.',
          ),
        ),
      );
      return;
    }

    final amount = double.tryParse(cost);

    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CareCompletionScreen(
          elderlyName: widget.elderlyName,
          service: widget.service,
          date: widget.date,
          time: widget.time,
          purchaseAmount: cost,
          careNotes: _notesController.text.trim(),
          receiptAdded: _receiptAdded,
          address: widget.address,
          duration: widget.duration,
          mobility: widget.mobility,
          language: widget.language,
          instructions: widget.instructions,
          familySharing: widget.familySharing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care task'),
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
                    _buildProgressHeader(),
                    const SizedBox(height: 20),
                    _buildTaskHeader(),
                    const SizedBox(height: 20),
                    _buildTaskInstructions(),
                    const SizedBox(height: 18),
                    _buildAmountCard(),
                    const SizedBox(height: 18),
                    _buildReceiptCard(),
                    const SizedBox(height: 18),
                    _buildNotesCard(),
                    const SizedBox(height: 18),
                    _buildImportantCard(),
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

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: CareCircleColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: CareCircleColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: CareCircleColors.success,
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
        ),
        const SizedBox(height: 12),
        const Text(
          'Step 4 of 4 • Complete the care task',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CareCircleColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskHeader() {
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Care task in progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${widget.service} for ${widget.elderlyName}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInstructions() {
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
          const Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: CareCircleColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Task details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: CareCircleColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _taskDetailRow(
            'Service',
            widget.service,
            Icons.medical_services_outlined,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Care recipient',
            widget.elderlyName,
            Icons.person_outline_rounded,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Scheduled date',
            _formatDate(widget.date),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Scheduled time',
            _formatTime(widget.time),
            Icons.access_time_rounded,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Location',
            widget.address,
            Icons.location_on_outlined,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Duration',
            widget.duration,
            Icons.timelapse_rounded,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Mobility',
            widget.mobility,
            Icons.accessibility_new_rounded,
          ),
          const SizedBox(height: 13),
          _taskDetailRow(
            'Language',
            widget.language,
            Icons.language_rounded,
          ),
          if (widget.instructions.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            _taskDetailRow(
              'Instructions',
              widget.instructions,
              Icons.notes_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _taskDetailRow(
      String title,
      String value,
      IconData icon,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
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
              color: CareCircleColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return _sectionCard(
      title: 'Purchase / service amount',
      icon: Icons.currency_rupee_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the amount spent for this care request.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: CareCircleColors.textSecondary,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              hintText: '0.00',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'For services without a purchase, enter 0.',
            style: TextStyle(
              fontSize: 12,
              color: CareCircleColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return _sectionCard(
      title: 'Receipt / proof',
      icon: Icons.receipt_long_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a receipt so the family can review the expense.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: CareCircleColors.textSecondary,
            ),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: _toggleReceipt,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _receiptAdded
                    ? const Color(0xFFEAF6EF)
                    : CareCircleColors.background,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: _receiptAdded
                      ? const Color(0xFFC9E8D6)
                      : CareCircleColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _receiptAdded
                          ? Colors.white
                          : CareCircleColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _receiptAdded
                          ? Icons.check_rounded
                          : Icons.camera_alt_outlined,
                      color: _receiptAdded
                          ? CareCircleColors.success
                          : CareCircleColors.primary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _receiptAdded
                              ? 'Receipt added'
                              : 'Add receipt',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CareCircleColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _receiptAdded
                              ? 'Receipt is ready to be shared with the family.'
                              : 'Tap here to add a receipt photo.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CareCircleColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _receiptAdded
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: _receiptAdded
                        ? CareCircleColors.success
                        : CareCircleColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_receiptAdded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CareCircleColors.border,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: CareCircleColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'receipt_photo.jpg',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CareCircleColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 12,
                      color: CareCircleColors.textSecondary,
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

  Widget _buildNotesCard() {
    return _sectionCard(
      title: 'Care notes',
      icon: Icons.notes_rounded,
      child: TextField(
        controller: _notesController,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(
          hintText:
          'Add notes about what was completed, anything the family should know, or any follow-up needed.',
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildImportantCard() {
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
            Icons.info_outline_rounded,
            color: CareCircleColors.secondary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please make sure the amount and care notes are accurate '
                  'before completing the task. The family will be able to '
                  'review these details.',
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

  Widget _sectionCard({
    required String title,
    required IconData icon,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: CareCircleColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: CareCircleColors.textPrimary,
                  ),
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
        onPressed: _isCompleting ? null : _completeTask,
        icon: _isCompleting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.check_circle_outline_rounded,
        ),
        label: Text(
          _isCompleting
              ? 'Completing task...'
              : 'Mark task completed',
        ),
      ),
    );
  }
}