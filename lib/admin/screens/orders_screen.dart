import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import 'dashboard_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'All';
  String _sortBy = 'Date';
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#1001',
      'customer': 'Ali',
      'status': 'Completed',
      'amount': 1200,
      'date': DateTime(2025, 10, 7),
    },
    {
      'id': '#1002',
      'customer': 'Sara',
      'status': 'Pending',
      'amount': 800,
      'date': DateTime(2025, 10, 6),
    },
    {
      'id': '#1003',
      'customer': 'Bilal',
      'status': 'Cancelled',
      'amount': 500,
      'date': DateTime(2025, 10, 5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildFiltersAndSearch(),
              const SizedBox(height: 20),
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildOrdersChart(),
              const SizedBox(height: 20),
              _buildOrdersTable(),
              const SizedBox(height: 20),
              _buildPagination(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () {
          // TODO: Add new order
        },
        child: const Icon(Icons.add, color: AppColors.light),
      ),
    );
  }

  // ======================= Top Bar =======================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.light),
        ),
        const SizedBox(width: 8),
        const Text(
          'Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primaryFont,
            color: AppColors.light,
          ),
        ),
      ],
    );
  }

  // ======================= Search & Filters =======================
  Widget _buildFiltersAndSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search & Filters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.light,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Search Bar
            SizedBox(
              width: 250,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.light),
                decoration: InputDecoration(
                  hintText: 'Search by ID or Customer',
                  hintStyle: const TextStyle(color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.dark,
                  prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),

            // Status Filter
            DropdownButton<String>(
              dropdownColor: AppColors.dark,
              value: _selectedStatus,
              items: ['All', 'Pending', 'Completed', 'Cancelled']
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(color: AppColors.light),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),

            // Sort By
            DropdownButton<String>(
              dropdownColor: AppColors.dark,
              value: _sortBy,
              items: ['Date', 'Amount']
                  .map(
                    (sort) => DropdownMenuItem(
                      value: sort,
                      child: Text(
                        'Sort by $sort',
                        style: const TextStyle(color: AppColors.light),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _sortBy = value!);
              },
            ),

            // Date Range Picker
            ElevatedButton(
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: _selectedDateRange,
                );
                if (picked != null) {
                  setState(() => _selectedDateRange = picked);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: AppColors.light,
              ),
              child: const Text('Select Date Range'),
            ),
          ],
        ),
      ],
    );
  }

  // ======================= Stats Cards =======================
  Widget _buildStatsCards() {
    final revenue = _orders.fold<int>(
      0,
      (sum, o) => sum + (int.tryParse(o['amount'].toString()) ?? 0),
    );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildStatCard('Total Orders', _orders.length.toString(), Colors.blue),
        _buildStatCard(
          'Completed',
          _orders.where((o) => o['status'] == 'Completed').length.toString(),
          Colors.green,
        ),
        _buildStatCard(
          'Pending',
          _orders.where((o) => o['status'] == 'Pending').length.toString(),
          Colors.orange,
        ),
        _buildStatCard('Revenue', 'PKR $revenue', Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.light,
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: AppFonts.primaryFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ======================= Chart =======================
  Widget _buildOrdersChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 5),
                FlSpot(2, 2),
                FlSpot(3, 4),
                FlSpot(4, 6),
              ],
              isCurved: true,
              color: Colors.greenAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= Orders Table =======================
  Widget _buildOrdersTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: AppColors.light,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primaryFont,
          ),
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _orders.map((order) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    order['id'],
                    style: const TextStyle(color: AppColors.light),
                  ),
                ),
                DataCell(
                  Text(
                    order['customer'],
                    style: const TextStyle(color: AppColors.light),
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat('yyyy-MM-dd').format(order['date']),
                    style: const TextStyle(color: AppColors.light),
                  ),
                ),
                DataCell(
                  Text(
                    order['status'],
                    style: TextStyle(
                      color: order['status'] == 'Completed'
                          ? Colors.green
                          : order['status'] == 'Pending'
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    order['amount'].toString(),
                    style: const TextStyle(color: AppColors.light),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ======================= Pagination =======================
  Widget _buildPagination() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              foregroundColor: AppColors.light,
            ),
            child: const Text('Previous'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              foregroundColor: AppColors.light,
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
