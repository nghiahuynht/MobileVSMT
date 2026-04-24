import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trash_pay/constants/colors.dart';

/// Filter-style dropdown: full-width button/menu, optional null row, [DropdownButton2].
class XDropdown<T> extends StatefulWidget {
  const XDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.itemBuilder,
    this.menuMaxHeight = 300,
  });

  final T? value;
  final List<T> items;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemBuilder;
  final double menuMaxHeight;

  @override
  State<XDropdown<T>> createState() => _XDropdownState<T>();
}

class _XDropdownState<T> extends State<XDropdown<T>> {
  late final ValueNotifier<T?> _valueNotifier;

  static const TextStyle _hintStyle = TextStyle(
    color: Color(0xFF94A3B8),
    fontSize: 14,
  );

  static const TextStyle _itemStyle = TextStyle(
    color: Color(0xFF1E293B),
    fontSize: 14,
  );

  static const Color _itemBorderColor = Color(0xFFCBD5E1);

  static const int _menuItemLineCount = 3;

  static const double _menuItemVerticalPadding = 12.0;

  double _menuItemHeightForThreeLines(BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final TextPainter painter = TextPainter(
      text: const TextSpan(style: _itemStyle, text: '█'),
      textDirection: Directionality.of(context),
      textScaler: textScaler,
      locale: Localizations.maybeLocaleOf(context),
    )..layout(maxWidth: double.infinity);
    final double oneLineHeight = painter.height;
    final double rawHeight =
        oneLineHeight * _menuItemLineCount + _menuItemVerticalPadding;
    return math.max(rawHeight, kMinInteractiveDimension);
  }

  Widget _menuItemWithBottomBorder({
    required bool hasBottomBorder,
    required Widget child,
  }) {
    if (!hasBottomBorder) {
      return child;
    }
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _itemBorderColor, width: 1),
        ),
      ),
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier<T?>(widget.value);
  }

  @override
  void didUpdateWidget(XDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final T? selectedValue = widget.value;
    final double menuItemHeight = _menuItemHeightForThreeLines(context);
    final List<DropdownItem<T>> dropdownItems = <DropdownItem<T>>[
      DropdownItem<T>(
        value: null,
        height: menuItemHeight,
        child: _menuItemWithBottomBorder(
          hasBottomBorder: widget.items.isNotEmpty,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.hintText,
              maxLines: _menuItemLineCount,
              overflow: TextOverflow.ellipsis,
              style: _hintStyle,
            ),
          ),
        ),
      ),
      ...widget.items.asMap().entries.map(
        (MapEntry<int, T> entry) {
          final T item = entry.value;
          final bool hasBottomBorder = entry.key < widget.items.length - 1;
          return DropdownItem<T>(
            value: item,
            height: menuItemHeight,
            child: _menuItemWithBottomBorder(
              hasBottomBorder: hasBottomBorder,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.itemBuilder(item),
                      maxLines: _menuItemLineCount,
                      overflow: TextOverflow.ellipsis,
                      style: _itemStyle,
                    ),
                  ),
                  if (selectedValue == item)
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
            ),
          );
        },
      ),
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<T>(
                valueListenable: _valueNotifier,
                isExpanded: true,
                isDense: true,
                hint: widget.items.isEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.hintText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _hintStyle,
                        ),
                      )
                    : null,
                items: widget.items.isEmpty ? <DropdownItem<T>>[] : dropdownItems,
                onChanged: widget.items.isEmpty
                    ? null
                    : (T? newValue) {
                        _valueNotifier.value = newValue;
                        widget.onChanged(newValue);
                      },
                style: _itemStyle,
                selectedItemBuilder: widget.items.isEmpty
                    ? null
                    : (BuildContext context) {
                        return <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.hintText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _hintStyle,
                            ),
                          ),
                          ...widget.items.map(
                            (T item) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.itemBuilder(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _itemStyle,
                              ),
                            ),
                          ),
                        ];
                      },
                buttonStyleData: const ButtonStyleData(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: widget.menuMaxHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
