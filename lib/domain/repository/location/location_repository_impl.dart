import 'dart:convert';
import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/repository/location/location_repository.dart';
import 'package:trash_pay/services/network_service.dart';
import 'package:trash_pay/services/app_messenger.dart';

class LocationRepositoryImpl implements LocationRepository {
  final DioNetwork _networkService = DioNetwork.instance;

  @override
  Future<List<Ward>> getWards() async {
    try {
      final result = await _networkService.get<List<Ward>>(
        '${ApiConfig.metaData}/GetWards',
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          return listData.map((json) => Ward.fromMap(json)).toList();
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
      throw '';
    }
  }

  @override
  Future<List<Group>> getGroups({int? wardId}) async {
    try {
      final endpoint = wardId != null
          ? '${ApiConfig.metaData}/GetGroups?wardId=$wardId'
          : '${ApiConfig.metaData}/GetGroups';

      final result = await _networkService.get<List<Group>>(
        endpoint,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          return listData.map((json) => Group.fromMap(json)).toList();
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
      throw '';
      // Fallback to mock data if API fails
      // return _generateMockGroups(wardId);
    }
  }

  @override
  Future<List<Area>> getAreas({int? groupId}) async {
    try {
      final endpoint = groupId != null
          ? '${ApiConfig.metaData}/GetAreas?groupId=$groupId'
          : '${ApiConfig.metaData}/GetAreas';

      final result = await _networkService.get<List<Area>>(
        endpoint,
        fromJson: (data) {
          final root = jsonDecode(data);
          if (root['isSuccess'] != true) {
            throw root['message'] ?? 'Thao tác thất bại';
          }
          final List<dynamic> listData = root['data'];
          return listData.map((json) => Area.fromMap(json)).toList();
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
      throw '';
    }
  }
}
