import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CareHistoryScreen extends StatefulWidget {
  final String elderlyName;

  const CareHistoryScreen({
    super.key,
    required this.elderlyName,
  });

  @override
  State<CareHistoryScreen> createState() =>
      _CareHistoryScreenState();
}

class _CareHistoryScreenState extends State<CareHistoryScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _history = [
    {
      'service': 'Medicine pickup',
      'date': 'September 20, 2026',
      'time': '5:00 PM',
      'status': 'Completed',
      'amount': '₹450.00',
      'fee': '₹100.00',
      'helper': 'Ananya Sharma',
      'icon': Icons.medication_outlined,
    },
    {
      'service': 'Grocery pickup',
      'date': 'September 16, 2026',
      'time': '11:30 AM',
      'status': 'Completed',
      'amount': '₹820.00',
      'fee': '₹100.00',
      'helper': 'Rahul Das',
      'icon': Icons.shopping_basket_outlined,
    },
    {
      'service': 'Appointment assistance',
      'date': 'September 10, 2026',
      'time': '3:00 PM',
      'status': 'Completed',
      'amount': '₹0.00',
      'fee': '₹100.00',
      'helper': 'Priya Sen',
      'icon': Icons.calendar_month_outlined,
    },
    {
      'service': 'Companionship',
      'date': 'September 4, 2026',
      'time': '6:00 PM',
      'status': 'Completed',
      'amount': '₹0.00',
      'fee': '₹100.00',
      'helper': 'Ananya Sharma',
      'icon': Icons.favorite_border_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'All') {
      return _history;
    }

    return _history.where((item) {
      return item['service'] == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care history'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  30,
                ),
                itemCount: _filteredHistory.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _buildHistoryCard(
                    _filteredHistory[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CareCircleColors.primaryLight,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: CareCircleColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your care history',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color:
                      CareCircleColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Past care services for ${widget.elderlyName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                      CareCircleColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      'All',
      'Medicine pickup',
      'Grocery pickup',
      'Appointment assistance',
      'Companionship',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected =
              _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor:
            CareCircleColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? CareCircleColors.primary
                  : CareCircleColors.border,
            ),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : CareCircleColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
      Map<String, dynamic> item,
      ) {
    final String service =
    item['service'] as String;
    final String date =
    item['date'] as String;
    final String time =
    item['time'] as String;
    final String status =
    item['status'] as String;
    final String amount =
    item['amount'] as String;
    final String fee =
    item['fee'] as String;
    final String helper =
    item['helper'] as String;
    final IconData icon =
    item['icon'] as IconData;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _showHistoryDetails(item);
      },
      child: Container(
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
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                    CareCircleColors.primaryLight,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color:
                    CareCircleColors.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          CareCircleColors
                              .textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$date • $time',
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                          CareCircleColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFEAF6EF),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color:
                        CareCircleColors
                            .success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          CareCircleColors
                              .success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Container(
              width: double.infinity,
              height: 1,
              color: CareCircleColors.border,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                  color:
                  CareCircleColors.textSecondary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    helper,
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                      CareCircleColors
                          .textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 17,
                  color:
                  CareCircleColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  amount == '₹0.00'
                      ? 'Service only'
                      : amount,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    CareCircleColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color:
                  CareCircleColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color:
                CareCircleColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 38,
                color:
                CareCircleColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No care history found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color:
                CareCircleColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completed care services will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color:
                CareCircleColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetails(
      Map<String, dynamic> item,
      ) {
    final String service =
    item['service'] as String;
    final String date =
    item['date'] as String;
    final String time =
    item['time'] as String;
    final String amount =
    item['amount'] as String;
    final String fee =
    item['fee'] as String;
    final String helper =
    item['helper'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                      CareCircleColors.border,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Care details',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    CareCircleColors
                        .textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                _detailRow(
                  'Service',
                  service,
                ),
                _detailRow(
                  'Date',
                  date,
                ),
                _detailRow(
                  'Time',
                  time,
                ),
                _detailRow(
                  'Helper',
                  helper,
                ),
                const Divider(
                  height: 24,
                ),
                _detailRow(
                  'Purchase / service',
                  amount,
                ),
                _detailRow(
                  'CareCircle fee',
                  fee,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                    CareCircleColors
                        .primaryLight,
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color:
                        CareCircleColors
                            .primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Receipt and care notes are available for this completed service.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color:
                            CareCircleColors
                                .textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text(
                      'Close',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color:
                CareCircleColors
                    .textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
                color:
                CareCircleColors
                    .textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}