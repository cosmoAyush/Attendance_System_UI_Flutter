import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_bottom_navigation.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/api/leave_api_service.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<LeavePolicyType> _leavePolicies = [];
  bool _isBalanceExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchLeavePolicies();
  }

  Future<void> _fetchLeavePolicies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('DEBUG: Fetching leave policies...');
      final response = await LeaveApiService.getLeavePolicyTypes();
      print('DEBUG: Leave policies fetched: ${response.data.length}');
      setState(() {
        _leavePolicies = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error fetching leave policies: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load leave policies: $e';
      });
    }
  }

  void _toggleBalanceExpanded() {
    setState(() {
      _isBalanceExpanded = !_isBalanceExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Leave Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeavePolicies,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Increased bottom padding from 80 to 100 for more space
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildLeaveOptions(context),
            const SizedBox(height: 24),
            _buildCollapsibleLeaveSummary(context),
            const SizedBox(height: 20), // Added extra bottom spacing
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationWithRoutes(currentIndex: 2),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppRouter.navigateTo(context, AppRouter.requestLeave),
                    icon: const Icon(Icons.add),
                    label: const Text('Request Leave'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AppRouter.navigateTo(context, AppRouter.leaveList),
                    icon: const Icon(Icons.list),
                    label: const Text('View Requests'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleLeaveSummary(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleBalanceExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Leave Balance',
                    style: AppTheme.headingSmall,
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  AnimatedRotation(
                    turns: _isBalanceExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Reduced bottom padding from 16 to 8
              child: _buildLeaveSummaryContent(context),
            ),
            crossFadeState: _isBalanceExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSummaryContent(BuildContext context) {
    final theme = Theme.of(context);
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      );
    } else if (_leavePolicies.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          'No leave policies found.',
          style: AppTheme.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    } else {
      // Use LayoutBuilder to constrain the grid height to available space
      return LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight > 600 ? 600 : constraints.maxHeight - 30, // Increased maxHeight from 500 to 600 and reduced buffer from 50 to 30
              minHeight: 0,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: _buildLeaveBalanceGrid(),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildLeaveBalanceGrid() {
    // Group policies by category
    final Map<String, List<LeavePolicyType>> groupedPolicies = {};
    for (final policy in _leavePolicies) {
      final category = policy.leavePolicyCategory.name;
      groupedPolicies.putIfAbsent(category, () => []).add(policy);
    }

    return Column(
      children: groupedPolicies.entries.map((entry) {
        final category = entry.key;
        final policies = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupedPolicies.length > 1) ...[
              Text(
                category,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 3), // Reduced from 4 for more compact layout
            ],
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6, // Increased from 2 for better spacing
                mainAxisSpacing: 6, // Increased from 2 for better spacing
                childAspectRatio: 2.8, // Reduced from 5.0 to give more height to items
              ),
              itemCount: policies.length,
              itemBuilder: (context, index) {
                final policy = policies[index];
                return _buildLeaveBalanceItem(policy);
              },
            ),
            if (groupedPolicies.length > 1 && entry.key != groupedPolicies.keys.last)
              const SizedBox(height: 4), // Reduced from 6 for more compact layout
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLeaveBalanceItem(LeavePolicyType policy) {
    return Container(
      padding: const EdgeInsets.all(0), // Increased from 2 for better spacing
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8), // Increased from 3 for better appearance
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            policy.leaveType,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontSize: 12, // Increased from 3 for better readability
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Increased from 1 for better spacing
          Text(
            '${policy.maxDay} day${policy.maxDayInt > 1 ? 's' : ''}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14, // Increased from 9 for better visibility
            ),
          ),
          const SizedBox(height: 2), // Increased from 1 for better spacing
          Text(
            policy.leavePolicyCategory.name,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontSize: 10, // Increased from 6 for better readability
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveOptions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Options',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Request New Leave'),
              subtitle: const Text('Submit a new leave request'),
              onTap: () => AppRouter.navigateTo(context, AppRouter.requestLeave),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Leave History'),
              subtitle: const Text('View all your leave requests'),
              onTap: () => AppRouter.navigateTo(context, AppRouter.leaveList),
            ),
          ],
        ),
      ),
    );
  }
} 