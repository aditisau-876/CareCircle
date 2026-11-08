import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/care/data/family_care_service.dart';

class CareHistoryScreen extends StatefulWidget {
  final String elderlyName;

  const CareHistoryScreen({
    super.key,
    required this.elderlyName,
  });

  @override
  State<CareHistoryScreen> createState() => _CareHistoryScreenState();
}

class _CareHistoryScreenState extends State<CareHistoryScreen> {
  String _selectedFilter = 'All';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  static const List<String> _filters = [
    'All',
    'Active',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await FamilyCareService.getMyRequests(limit: 100);
      if (!mounted) return;
      setState(() {
        _requests = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredRequests {
    final filtered = _requests.where((request) {
      final status = _status(request).toLowerCase();
      switch (_selectedFilter) {
        case 'Active':
          return !{'completed', 'cancelled', 'rejected'}.contains(status);
        case 'Completed':
          return status == 'completed';
        case 'Cancelled':
          return status == 'cancelled' || status == 'rejected';
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => _dateTime(b).compareTo(_dateTime(a)));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareCircleColors.background,
      appBar: AppBar(title: const Text('Care history')),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 14),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: CareCircleColors.primaryLight,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded, color: CareCircleColors.primary, size: 27),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your care requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Requests for ${widget.elderlyName}', style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary)),
                ],
              ),
            ),
            Text('${_requests.length}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: CareCircleColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            selectedColor: CareCircleColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? CareCircleColors.primary : CareCircleColors.border),
            labelStyle: TextStyle(color: selected ? Colors.white : CareCircleColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: CareCircleColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 42, color: CareCircleColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Could not load care history', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
              const SizedBox(height: 7),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadHistory, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    final items = _filteredRequests;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 75),
            Icon(Icons.event_note_rounded, size: 54, color: CareCircleColors.primary.withValues(alpha: .55)),
            const SizedBox(height: 16),
            const Text('No care requests found', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
            const SizedBox(height: 7),
            const Text('Your submitted care requests will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: CareCircleColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: CareCircleColors.primary,
      onRefresh: _loadHistory,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildRequestCard(items[index]),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final service = _string(request['service'], 'Care service');
    final status = _status(request);
    final color = _statusColor(status);
    final id = request['id'];
    return InkWell(
      onTap: () => _showRequestDetails(request),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: CareCircleColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: CareCircleColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                  child: Icon(_serviceIcon(service), color: CareCircleColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(service, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary))),
                _statusBadge(status, color),
              ],
            ),
            const SizedBox(height: 13),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: CareCircleColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text('${_formatDate(request['scheduled_date'])}  •  ${_formatTime(request['scheduled_time'])}', style: const TextStyle(fontSize: 12, color: CareCircleColors.textSecondary))),
              if (id != null) Text('#$id', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CareCircleColors.textSecondary)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: CareCircleColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(_string(request['address'], 'Address not available'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: CareCircleColors.textSecondary))),
              const Icon(Icons.chevron_right_rounded, color: CareCircleColors.textSecondary),
            ]),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    final status = _status(request);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: CareCircleColors.border, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('Request details', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: CareCircleColors.textPrimary)),
              const SizedBox(height: 15),
              _detailRow('Request ID', request['id']?.toString() ?? 'Not available'),
              _detailRow('Service', _string(request['service'], 'Not specified')),
              _detailRow('For', _string(request['elderly_name'], widget.elderlyName)),
              _detailRow('Date', _formatDate(request['scheduled_date'])),
              _detailRow('Time', _formatTime(request['scheduled_time'])),
              _detailRow('Status', _prettyStatus(status)),
              _detailRow('Address', _string(request['address'], 'Not provided')),
              if (_string(request['duration'], '').isNotEmpty) _detailRow('Duration', _string(request['duration'], '')),
              if (_string(request['mobility'], '').isNotEmpty) _detailRow('Mobility needs', _string(request['mobility'], '')),
              if (_string(request['language'], '').isNotEmpty) _detailRow('Preferred language', _string(request['language'], '')),
              if (_string(request['instructions'], '').isNotEmpty) _detailRow('Instructions', _string(request['instructions'], '')),
              const SizedBox(height: 15),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Close'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 115, child: Text(label, style: const TextStyle(fontSize: 12.5, color: CareCircleColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: CareCircleColors.textPrimary))),
      ]),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)),
      child: Text(_prettyStatus(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  String _status(Map<String, dynamic> request) => _string(request['status'], 'pending');
  String _string(dynamic value, String fallback) => value == null || value.toString().trim().isEmpty ? fallback : value.toString();

  DateTime _dateTime(Map<String, dynamic> request) {
    final date = DateTime.tryParse(_string(request['scheduled_date'], '')) ?? DateTime(1970);
    final parts = _string(request['scheduled_time'], '00:00').split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(_string(value, ''));
    if (date == null) return 'Not scheduled';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(dynamic value) {
    final raw = _string(value, '');
    final parts = raw.split(':');
    if (parts.length < 2) return raw.isEmpty ? 'Not set' : raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $suffix';
  }

  String _prettyStatus(String value) => value.replaceAll('_', ' ').split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return CareCircleColors.success;
      case 'cancelled':
      case 'rejected': return CareCircleColors.danger;
      case 'assigned':
      case 'on_the_way':
      case 'arrived':
      case 'task_started': return const Color(0xFF3978A8);
      default: return const Color(0xFFB7791F);
    }
  }

  IconData _serviceIcon(String service) {
    final value = service.toLowerCase();
    if (value.contains('medicine')) return Icons.medication_outlined;
    if (value.contains('grocery')) return Icons.shopping_basket_outlined;
    if (value.contains('appointment')) return Icons.calendar_month_outlined;
    if (value.contains('hospital')) return Icons.local_hospital_outlined;
    if (value.contains('household')) return Icons.home_outlined;
    if (value.contains('document') || value.contains('bill')) return Icons.description_outlined;
    if (value.contains('walk')) return Icons.directions_walk_outlined;
    if (value.contains('companionship')) return Icons.favorite_border_rounded;
    return Icons.volunteer_activism_outlined;
  }
}
