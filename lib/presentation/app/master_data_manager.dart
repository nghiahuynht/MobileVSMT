import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/unit/unit.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/language/language.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository.dart';
import 'package:trash_pay/domain/repository/product/product_repository.dart';
import 'package:trash_pay/domain/repository/customer/customer_repository.dart';
import 'package:trash_pay/domain/repository/location/location_repository.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'logics/app_events.dart';

/// Manager để load và cache master data
class MasterDataManager {
  static final MasterDataManager _instance = MasterDataManager._internal();
  factory MasterDataManager() => _instance;
  MasterDataManager._internal();

  final DomainManager _domainManager = GetIt.I<DomainManager>();

  /// Load tất cả master data
  Future<Map<MasterDataType, List<dynamic>>> loadAllMasterData() async {
    final results = <MasterDataType, List<dynamic>>{};
    
    try {
      // Load parallel để tăng tốc độ
      final futures = <Future<void>>[
        _loadUnits().then((data) => results[MasterDataType.units] = data),
        // _loadGroups().then((data) => results[MasterDataType.groups] = data),
        // _loadAreas().then((data) => results[MasterDataType.areas] = data),
        // _loadWards().then((data) => results[MasterDataType.wards] = data),
      ];

      await Future.wait(futures);
      return results;
    } catch (e) {
      throw Exception('Lỗi khi load master data: $e');
    }
  }

  // /// Load specific master data type
  // Future<List<dynamic>> loadMasterDataByType(MasterDataType type) async {
  //   switch (type) {
  //     case MasterDataType.units:
  //       return await _loadUnits();
  //     case MasterDataType.groups:
  //       return await _loadGroups();
  //     case MasterDataType.areas:
  //       return await _loadAreas();
  //     case MasterDataType.wards:
  //       return await _loadWards();
  //   }
  // }

  Future<List<Unit>> _loadUnits() async {
    try {
      final units = await _domainManager.unit.getUnits();
      return units;
    } catch (e) {
      throw Exception('Lỗi khi load Units: $e');
    }
  }

  // /// Load Groups
  // Future<List<Group>> _loadGroups() async {
  //   try {
  //     final result = await _locationRepository.getGroups();
  //     return result;
  //   } catch (e) {
  //     throw Exception('Lỗi khi load Groups: $e');
  //   }
  // }

  // /// Load Areas
  // Future<List<Area>> _loadAreas() async {
  //   try {
  //     final result = await _locationRepository.getAreas();
  //     return result;
  //   } catch (e) {
  //     throw Exception('Lỗi khi load Areas: $e');
  //   }
  // }

  // /// Load Wards
  // Future<List<Ward>> _loadWards() async {
  //   try {
  //     final result = await _locationRepository.getWards();
  //     return result;
  //   } catch (e) {
  //     throw Exception('Lỗi khi load Wards: $e');
  //   }
  // }

  List<Group> getGroupsByWardId(List<Group> groups, int wardId) {
    return groups.where((group) => group.wardId == wardId).toList();
  }

  /// Lọc Areas theo Group ID
  List<Area> getAreasByGroupId(List<Area> areas, int groupId) {
    return areas.where((area) => area.groupId == groupId).toList();
  }

  /// Lọc Customers theo Group Code
  List<CustomerModel> getCustomersByGroupCode(List<CustomerModel> customers, String groupCode) {
    return customers.where((customer) => customer.customerGroupCode == groupCode).toList();
  }

  /// Lọc Products active
  List<ProductModel> getActiveProducts(List<ProductModel> products) {
    return products.where((product) => product.isActive == true).toList();
  }

  /// Tìm Unit theo code
  Unit? findUnitByCode(List<Unit> units, String code) {
    try {
      return units.firstWhere((unit) => unit.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tìm Product theo code
  ProductModel? findProductByCode(List<ProductModel> products, String code) {
    try {
      return products.firstWhere((product) => product.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tìm Customer theo code
  CustomerModel? findCustomerByCode(List<CustomerModel> customers, String code) {
    try {
      return customers.firstWhere((customer) => customer.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tìm Group theo code
  Group? findGroupByCode(List<Group> groups, String code) {
    try {
      return groups.firstWhere((group) => group.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tìm Area theo code
  Area? findAreaByCode(List<Area> areas, String code) {
    try {
      return areas.firstWhere((area) => area.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Tìm Ward theo code
  Ward? findWardByCode(List<Ward> wards, String code) {
    try {
      return wards.firstWhere((ward) => ward.code == code);
    } catch (e) {
      return null;
    }
  }
} 