import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'care_details_screen.dart';

class CreateCareRequestScreen extends StatefulWidget {
  final String? initialService;
  final String elderlyName;

  const CreateCareRequestScreen({
    super.key,
    this.initialService,
    this.elderlyName = 'your loved one',
  });

  @override
  State<CreateCareRequestScreen> createState() =>
      _CreateCareRequestScreenState();
}

class _CreateCareRequestScreenState
    extends State<CreateCareRequestScreen> {
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Grocery pickup',
      'description': 'Pick up groceries and essentials',
      'icon': Icons.shopping_basket_outlined,
      'background': CareCircleColors.primaryLight,
      'color': CareCircleColors.primary,
    },
    {
      'name': 'Medicine pickup',
      'description': 'Collect medicines from a pharmacy',
      'icon': Icons.medication_outlined,
      'background': CareCircleColors.secondaryLight,
      'color': CareCircleColors.secondary,
    },
    {
      'name': 'Appointment assistance',
      'description': 'Help with a scheduled appointment',
      'icon': Icons.calendar_month_outlined,
      'background': Color(0xFFEDE8FA),
      'color': Color(0xFF7B61A8),
    },
    {
      'name': 'Accompaniment to hospital',
      'description': 'Accompany your loved one',
      'icon': Icons.local_hospital_outlined,
      'background': Color(0xFFE8F1FA),
      'color': Color(0xFF4E7EA8),
    },
    {
      'name': 'Household assistance',
      'description': 'Help with simple household tasks',
      'icon': Icons.home_outlined,
      'background': Color(0xFFF2EDE5),
      'color': Color(0xFF8C704A),
    },
    {
      'name': 'Document / bill assistance',
      'description': 'Help with documents and bills',
      'icon': Icons.description_outlined,
      'background': Color(0xFFEAF3F5),
      'color': Color(0xFF477E87),
    },
    {
      'name': 'Companionship',
      'description': 'Spend meaningful time together',
      'icon': Icons.favorite_border_rounded,
      'background': Color(0xFFFCE9EE),
      'color': Color(0xFFC45C78),
    },
    {
      'name': 'Short walk assistance',
      'description': 'Support during a short walk',
      'icon': Icons.directions_walk_outlined,
      'background': Color(0xFFEAF4E9),
      'color': Color(0xFF5E9360),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: CareCircleColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: CareCircleColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _continue() {
    if (_selectedService == null) {
      _showMessage('Please select a care service.');
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Please select a date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select a time.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareDetailsScreen(
          elderlyName: widget.elderlyName,
          service: _selectedService!,
          date: _selectedDate!,
          time: _selectedTime!,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(
        title: const Text('Request care'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _buildProgress(),
                  const SizedBox(height: 24),

                  Text(
                    'What kind of help is needed?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Choose a service for your loved one.',
                    style: TextStyle(
                      color: CareCircleColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildServices(),

                  const SizedBox(height: 28),

                  Text(
                    'When is help needed?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  _buildDateTimeCard(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
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
              color: CareCircleColors.border,
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

  Widget _buildServices() {
    return Column(
      children: _services.map((service) {
        final isSelected = _selectedService == service['name'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedService = service['name'];
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected
                    ? CareCircleColors.primaryLight
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? CareCircleColors.primary
                      : CareCircleColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: service['background'],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      service['icon'],
                      color: service['color'],
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CareCircleColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['description'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: CareCircleColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? CareCircleColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? CareCircleColors.primary
                            : CareCircleColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CareCircleColors.border,
        ),
      ),
      child: Column(
        children: [
          _dateTimeRow(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value: _selectedDate == null
                ? 'Choose a date'
                : _formatDate(_selectedDate!),
            onTap: _selectDate,
          ),
          const Divider(height: 24),
          _dateTimeRow(
            icon: Icons.access_time_rounded,
            title: 'Time',
            value: _selectedTime == null
                ? 'Choose a time'
                : _selectedTime!.format(context),
            onTap: _selectTime,
          ),
        ],
      ),
    );
  }

  Widget _dateTimeRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CareCircleColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: CareCircleColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

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

          const Icon(
            Icons.chevron_right_rounded,
            color: CareCircleColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: CareCircleColors.border,
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: _continue,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue'),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}