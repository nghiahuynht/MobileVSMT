import 'package:trash_pay/domain/entities/product/product.dart';

extension ProductOrderKey on ProductModel {
  String get productOrderKey =>
      (code != null && code!.isNotEmpty) ? code! : 'id:$id';

  /// Số tháng (1..12) nếu sản phẩm là "Tháng X" (vd: "Tháng 1", "Thang 01", "T12").
  int? get monthNumber {
    final RegExp pattern = RegExp(
      r'(?:^|[^a-zA-Z])(?:th[aáà]ng|t)\s*0?(\d{1,2})(?!\d)',
      caseSensitive: false,
      unicode: true,
    );
    for (final String? source in <String?>[name, code]) {
      final RegExpMatch? match = pattern.firstMatch(source ?? '');
      if (match == null) continue;
      final int? month = int.tryParse(match.group(1)!);
      if (month != null && month >= 1 && month <= 12) return month;
    }
    return null;
  }
}
