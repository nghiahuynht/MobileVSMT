import 'package:flutter/material.dart';
import 'package:trash_pay/constants/colors.dart';

class XDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final Function(T?) onChanged;
  final String Function(T) itemBuilder;

  const XDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        menuMaxHeight: 300,
        items: [
          DropdownMenuItem<T>(
            value: null,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          ...items.map((item) => DropdownMenuItem<T>(
                value: item,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemBuilder(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (value == item)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              )),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF64748B),
          size: 20,
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
        ),
        selectedItemBuilder: (context) {
          final List<Widget> displayItems = [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
            ),
            ...items.map((item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    itemBuilder(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                )),
          ];
          return displayItems;
        },
      ),
    );
  }
}
