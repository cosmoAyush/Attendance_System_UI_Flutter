import 'package:flutter/material.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/services/api/leave_api_service.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';

class ViewLeaveRequestsScreen extends StatefulWidget {
  const ViewLeaveRequestsScreen({super.key});

  @override
  State<ViewLeaveRequestsScreen> createState() => _ViewLeaveRequestsScreenState();
}

class _ViewLeaveRequestsScreenState extends State<ViewLeaveRequestsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<LeaveRequestListItem> _allRequests = [];
  List<LeaveRequestListItem> _filteredRequests = [];
  String? _selectedFilter;
  bool _isFilterExpanded = false;

  // Filter options
  static const Map<String, String> _filterOptions = {
    'all': 'All Requests',
    'PENDING': 'Pending',
    'APPROVED': 'Approved',
    'REJECTED': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'all'; // Default to show all requests
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('DEBUG: Fetching leave requests...');
      final response = await LeaveApiService.getOwnLeaveRequests();
      print('DEBUG: Leave requests fetched: ${response.data.length}');
      print('DEBUG: Response data: ${response.data}');
      setState(() {
        _allRequests = response.data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error fetching leave requests: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load leave requests: $e';
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == null || _selectedFilter == 'all') {
      _filteredRequests = List.from(_allRequests);
    } else {
      _filteredRequests = _allRequests
          .where((request) => request.status.status == _selectedFilter)
          .toList();
    }
  }

  void _onFilterChanged(String? filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  void _toggleFilterExpansion() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(theme),
          // Content Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor),
                        ),
                      )
                    : _filteredRequests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedFilter == null || _selectedFilter == 'all'
                                      ? Icons.inbox_outlined
                                      : Icons.filter_list_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == null || _selectedFilter == 'all'
                                      ? 'No leave requests found.'
                                      : 'No ${_filterOptions[_selectedFilter]} requests.',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                if (_selectedFilter != null && _selectedFilter != 'all') ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _onFilterChanged('all'),
                                    child: const Text('Show All Requests'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchRequests,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRequests.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final req = _filteredRequests[index];
                                return _buildRequestCard(req, theme);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(_isFilterExpanded ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with current filter and expand button
          InkWell(
            onTap: _toggleFilterExpansion,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${_filterOptions[_selectedFilter] ?? 'All Requests'}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedFilter != null && _selectedFilter != 'all') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filteredRequests.length}',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AnimatedRotation(
                    turns: _isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded filter options
          if (_isFilterExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filterOptions.entries.map((entry) {
                final isSelected = _selectedFilter == entry.key;
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    _onFilterChanged(selected ? entry.key : 'all');
                    if (selected) {
                      // Auto-collapse after selection
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          setState(() {
                            _isFilterExpanded = false;
                          });
                        }
                      });
                    }
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
            if (_selectedFilter != null && _selectedFilter != 'all') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Showing ${_filteredRequests.length} of ${_allRequests.length} requests',
                    style: AppTheme.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequestListItem req, ThemeData theme) {
    final statusColor = req.status.color;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Leave Type and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_note, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      req.leavePolicy.leaveType,
                      style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    req.status.status,
                    style: AppTheme.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Dates
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  '${req.formattedStartDate} - ${req.formattedEndDate}',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Text('(${req.numberOfDays} day${req.numberOfDays > 1 ? 's' : ''})', style: AppTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    req.reason,
                    style: AppTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Created at
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text('Requested: ${req.formattedCreatedAt}', style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 