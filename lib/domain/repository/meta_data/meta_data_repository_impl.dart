import 'dart:convert';

import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
import 'package:trash_pay/domain/entities/meta_data/meta_data.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/domain/repository/meta_data/meta_data_repository.dart';
import 'package:trash_pay/services/network_service.dart';
import 'package:trash_pay/services/app_messenger.dart';

class MetaDataRepositoryImpl implements MetaDataRepository {
  final DioNetwork _networkService = DioNetwork.instance;

  @override
  Future<List<Area>> getAreas({required String? saleUser}) async {
    try {
      final result = await _networkService.get<List<Area>>(
        ApiConfig.listAreaSaleBySaleUser,
        queryParameters: {if (saleUser != null) "saleUser": saleUser},
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<Area> areas =
              listData.map((json) => Area.fromMap(json)).toList();
          return areas;
        },
      );

      if (result is Success<List<Area>>) {
        return result.data;
      } else if (result is Failure<List<Area>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<Route>> getAllRouteSaleByAreaSale(
      {required String areaSaleCode}) async {
    try {
      final result = await _networkService.get<List<Route>>(
        ApiConfig.getAllRouteSaleByAreaSale,
        queryParameters: {"areaSaleCode": areaSaleCode},
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<Route> routes =
              listData.map((json) => Route.fromMap(json)).toList();
          return routes;
        },
      );

      if (result is Success<List<Route>>) {
        return result.data;
      } else if (result is Failure<List<Route>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<Province>> getAllProvinces() async {
    try {
      final result = await _networkService.get<List<Province>>(
        ApiConfig.getAllProvinces,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<Province> provinces =
              listData.map((json) => Province.fromMap(json)).toList();
          return provinces;
        },
      );

      if (result is Success<List<Province>>) {
        return result.data;
      } else if (result is Failure<List<Province>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<Ward>> getWardsByProvinceCode(
      {required String provinceCode}) async {
    try {
      final result = await _networkService.get<List<Ward>>(
        ApiConfig.getWardsByProvinceCode,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<Ward> wards =
              listData.map((json) => Ward.fromMap(json)).toList();
          return wards;
        },
      );

      if (result is Success<List<Ward>>) {
        return result.data;
      } else if (result is Failure<List<Ward>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<Group>> getAllGroups() async {
    try {
      final result = await _networkService.get<List<Group>>(
        ApiConfig.getAllCustomerGroup,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<Group> listModel =
              listData.map((json) => Group.fromMap(json)).toList();
          return listModel;
        },
      );

      if (result is Success<List<Group>>) {
        return result.data;
      } else if (result is Failure<List<Group>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<ProductModel>> getAllProduct() async {
    try {
      final result = await _networkService.get<List<ProductModel>>(
        ApiConfig.productsEndpoint,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          final List<ProductModel> listModel =
              listData.map((json) => ProductModel.fromJson(json)).toList();
          return listModel;
        },
      );

      if (result is Success<List<ProductModel>>) {
        return result.data;
      } else if (result is Failure<List<ProductModel>>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }

  @override
  Future<MetaData> getAllMetaData() async {
    try {
      final result = await _networkService.get<MetaData>(
        ApiConfig.getAllMetaData,
        fromJson: (data) {
          return MetaData.fromJson(data);
        },
      );

      if (result is Success<MetaData>) {
        return result.data;
      } else if (result is Failure<MetaData>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Error: $e');
    }
  }
}
