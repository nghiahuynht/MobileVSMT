import 'package:flutter/material.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';

/// Widget dropdown để chọn area, sử dụng data từ AppBloc
class AreasDropdownWidget extends StatelessWidget {
  final Area? selectedArea;
  final Function(Area?) onChanged;
  final String? hintText;
  final int? filterByGroupId;
  final bool enabled;
  final bool showAllOption;
  final String? allOptionText;

  const AreasDropdownWidget({
    super.key,
    required this.selectedArea,
    required this.onChanged,
    this.hintText = 'Chọn khu vực',
    this.filterByGroupId,
    this.enabled = true,
    this.showAllOption = false,
    this.allOptionText = 'Tất cả khu vực',
  });

  @override
  Widget build(BuildContext context) {
    return AreasBuilder(
      builder: (context, areas) {
        // Filter areas by group if specified
        List<Area> filteredAreas = filterByGroupId != null
            ? areas.where((area) => area.groupId == filterByGroupId).toList()
            : areas;

        return DropdownButtonFormField<Area?>(
          value: selectedArea,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
          ),
          items: [
            // All option if enabled
            if (showAllOption)
              DropdownMenuItem<Area?>(
                value: null,
                child: Text(
                  allOptionText!,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Areas
            ...filteredAreas.map((area) => DropdownMenuItem<Area?>(
                  value: area,
                  child: Text(
                    area.name,
                    style: const TextStyle(color: Color(0xFF1E293B)),
                  ),
                )),
          ],
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
          ),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
          ),
        );
      },
      loadingBuilder: (context) => DropdownButtonFormField<Area?>(
        value: null,
        onChanged: null,
        decoration: InputDecoration(
          hintText: 'Đang tải...',
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
        items: const [],
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

/// Widget đơn giản để hiển thị danh sách areas
class AreasListWidget extends StatelessWidget {
  final Function(Area)? onAreaTap;
  final bool showGroupInfo;

  const AreasListWidget({
    super.key,
    this.onAreaTap,
    this.showGroupInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return AreasBuilder(
      builder: (context, areas) {
        if (areas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Color(0xFFCBD5E1),
                ),
                SizedBox(height: 16),
                Text(
                  'Chưa có khu vực nào',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, index) {
            final area = areas[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF059669),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  area.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: showGroupInfo
                    ? Text(
                        'Nhóm ID: ${area.groupId}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: onAreaTap != null
                    ? const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF64748B),
                      )
                    : null,
                onTap: onAreaTap != null ? () => onAreaTap!(area) : null,
              ),
            );
          },
        );
      },
      loadingBuilder: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải khu vực...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 