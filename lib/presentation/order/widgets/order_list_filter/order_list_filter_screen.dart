// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:trash_pay/constants/font_family.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart' as MetaRoute;
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';
import 'package:trash_pay/presentation/order/logics/order_events.dart';
import 'package:trash_pay/presentation/widgets/common_dropdown.dart';

class OrderListFilterScreen extends StatefulWidget {
  final Area? selectedArea;
  final MetaRoute.Route? selectedRoute;
  final bool? filterByDate;
  final int? dateType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<MetaRoute.Route>? routes;

  const OrderListFilterScreen({
    super.key,
    this.selectedArea,
    this.selectedRoute,
    this.filterByDate,
    this.dateType,
    this.fromDate,
    this.toDate,
    this.routes,
  });

  @override
  State<OrderListFilterScreen> createState() => _OrderListFilterScreenState();
}

class _OrderListFilterScreenState extends State<OrderListFilterScreen> {
  Area? _selectedArea;
  MetaRoute.Route? _selectedRoute;
  bool _filterByDate = false;
  int _dateType = 1;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<MetaRoute.Route> _routes = [];

  @override
  void initState() {
    super.initState();
    _selectedArea = widget.selectedArea;
    _selectedRoute = widget.selectedRoute;
    _filterByDate = widget.filterByDate ?? false;
    _dateType = widget.dateType ?? 1;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _routes = widget.routes ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.productSans,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedArea = null;
                      _selectedRoute = null;
                      _filterByDate = false;
                      _dateType = 1;
                      _fromDate = null;
                      _toDate = null;
                    });
                  },
                  child: Text(
                    'Xóa tất cả',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area, Route Row
                  Row(
                    children: [
                      // Area Filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Khu vực',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: FontFamily.productSans,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            XDropdown<Area>(
                              hintText: 'Chọn Khu vực',
                              value: _selectedArea,
                              items: context.areas,
                              itemBuilder: (Area area) => area.name,
                              onChanged: (area) async {
                                setState(() {
                                  _selectedArea = area;
                                  _selectedRoute = null;
                                  _routes = [];
                                });
                                if (area != null) {
                                  try {
                                    final routes = await DomainManager()
                                        .metaData
                                        .getAllRouteSaleByAreaSale(
                                            areaSaleCode: area.code);
                                    setState(() {
                                      _routes = routes;
                                    });
                                  } catch (e) {
                                    // handle error if needed
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Route Filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.route_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Tuyến',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: FontFamily.productSans,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            XDropdown<MetaRoute.Route>(
                              hintText: 'Chọn Tuyến',
                              value: _selectedRoute,
                              items: _routes,
                              itemBuilder: (MetaRoute.Route route) =>
                                  route.name ?? '',
                              onChanged: (route) {
                                setState(() {
                                  _selectedRoute = route;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Date Filter Section
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Theo ngày',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.productSans,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _filterByDate,
                        onChanged: (value) {
                          setState(() {
                            _filterByDate = value;
                            if (!value) {
                              _fromDate = null;
                              _toDate = null;
                            }
                          });
                        },
                        activeColor: const Color(0xFF059669),
                      ),
                    ],
                  ),

                  if (_filterByDate) ...[
                    const SizedBox(height: 16),

                    // Date Type Selection
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF059669).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại ngày',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.productSans,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildModalDateTypeOption(
                                  title: 'Theo ngày tạo',
                                  value: 1,
                                  groupValue: _dateType,
                                  onChanged: (value) {
                                    setState(() {
                                      _dateType = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildModalDateTypeOption(
                                  title: 'Theo ngày duyệt',
                                  value: 2,
                                  groupValue: _dateType,
                                  onChanged: (value) {
                                    setState(() {
                                      _dateType = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range_outlined,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Khoảng thời gian',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: FontFamily.productSans,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildModalDateRangeField(
                          fromDate: _fromDate,
                          toDate: _toDate,
                          onTap: () async {
                            final picked = await _selectModalDateRange(
                              context,
                              _fromDate,
                              _toDate,
                            );
                            if (picked != null) {
                              setState(() {
                                _fromDate = picked.start;
                                _toDate = picked.end;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontFamily: FontFamily.productSans,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context,
                          FilterOrdersByMultipleCriteriaEvent(
                            selectedArea: _selectedArea,
                            selectedRoute: _selectedRoute,
                            dateType: _filterByDate ? _dateType : null,
                            fromDate: _filterByDate ? _fromDate : null,
                            toDate: _filterByDate ? _toDate : null,
                            routes: _routes,
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Áp dụng lọc',
                      style: TextStyle(
                        fontFamily: FontFamily.productSans,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalDateTypeOption({
    required String title,
    required int value,
    required int groupValue,
    required ValueChanged<int?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF059669),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDateRangeField({
    required DateTime? fromDate,
    required DateTime? toDate,
    required VoidCallback onTap,
  }) {
    String displayText;
    if (fromDate != null && toDate != null) {
      displayText =
          '${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year} - ${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}';
    } else {
      displayText = 'Chọn khoảng thời gian';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  color: (fromDate != null && toDate != null)
                      ? Colors.black87
                      : Colors.grey[500],
                  fontSize: 14,
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
            Icon(Icons.date_range, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange?> _selectModalDateRange(
    BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  ) async {
    final DateTimeRange? initialRange =
        (initialStartDate != null && initialEndDate != null)
            ? DateTimeRange(start: initialStartDate, end: initialEndDate)
            : null;

    return await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      locale: const Locale("vi"),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
