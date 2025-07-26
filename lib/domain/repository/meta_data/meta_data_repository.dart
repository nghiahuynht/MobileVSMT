import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
import 'package:trash_pay/domain/entities/meta_data/meta_data.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart';
import 'package:trash_pay/domain/entities/product/product.dart';

abstract class MetaDataRepository {
  Future<List<Route>> getAllRouteSaleByAreaSale({required String areaSaleCode});
  Future<List<Province>> getAllProvinces();
  Future<List<Group>> getAllGroups();
  Future<List<Ward>> getWardsByProvinceCode({required String provinceCode});
  Future<List<Area>> getAreas({required String? saleUser});
  Future<List<ProductModel>> getAllProduct();
  Future<MetaData> getAllMetaData();
}
