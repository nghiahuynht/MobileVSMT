import 'package:trash_pay/domain/entities/product/product.dart';

extension ProductOrderKey on ProductModel {
  String get productOrderKey =>
      (code != null && code!.isNotEmpty) ? code! : 'id:$id';
}
