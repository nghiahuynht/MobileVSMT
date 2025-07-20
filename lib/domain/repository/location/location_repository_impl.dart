import 'dart:convert';
import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/repository/location/location_repository.dart';
import 'package:trash_pay/services/network_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  final DioNetwork _networkService = DioNetwork.instance;

  @override
  Future<List<Ward>> getWards() async {
    try {
      // Mock data for demo - replace with actual API call
      if (ApiConfig.isDemoMode) {
        return _generateMockWards();
      }

      final result = await _networkService.get<List<Ward>>(
        '${ApiConfig.metaData}/GetWards',
        fromJson: (data) {
          final List<dynamic> listData = jsonDecode(data)['data'];
          return listData.map((json) => Ward.fromMap(json)).toList();
        },
      );
      
      if (result is Success<List<Ward>>) {
        return result.data;
      } else if (result is Failure<List<Ward>>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockWards();
    }
  }

  @override
  Future<List<Group>> getGroups({int? wardId}) async {
    try {
      // Mock data for demo - replace with actual API call
      if (ApiConfig.isDemoMode) {
        return _generateMockGroups(wardId);
      }

      final endpoint = wardId != null 
          ? '${ApiConfig.metaData}/GetGroups?wardId=$wardId'
          : '${ApiConfig.metaData}/GetGroups';
          
      final result = await _networkService.get<List<Group>>(
        endpoint,
        fromJson: (data) {
          final List<dynamic> listData = jsonDecode(data)['data'];
          return listData.map((json) => Group.fromMap(json)).toList();
        },
      );
      
      if (result is Success<List<Group>>) {
        return result.data;
      } else if (result is Failure<List<Group>>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockGroups(wardId);
    }
  }

  @override
  Future<List<Area>> getAreas({int? groupId}) async {
    try {
      // Mock data for demo - replace with actual API call
      if (ApiConfig.isDemoMode) {
        return _generateMockAreas(groupId);
      }

      final endpoint = groupId != null 
          ? '${ApiConfig.metaData}/GetAreas?groupId=$groupId'
          : '${ApiConfig.metaData}/GetAreas';
          
      final result = await _networkService.get<List<Area>>(
        endpoint,
        fromJson: (data) {
          final List<dynamic> listData = jsonDecode(data)['data'];
          return listData.map((json) => Area.fromMap(json)).toList();
        },
      );
      
      if (result is Success<List<Area>>) {
        return result.data;
      } else if (result is Failure<List<Area>>) {
        throw Exception(result.errorResultEntity.message);
      } else {
        throw Exception('Unexpected result type');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockAreas(groupId);
    }
  }

  // Mock data generators
  List<Ward> _generateMockWards() {
    return [
      const Ward(id: 1, code: 'PX001', name: 'Phường 1', description: 'Phường 1 - Quận 1'),
      const Ward(id: 2, code: 'PX002', name: 'Phường 2', description: 'Phường 2 - Quận 1'),
      const Ward(id: 3, code: 'PX003', name: 'Phường 3', description: 'Phường 3 - Quận 1'),
      const Ward(id: 4, code: 'PX004', name: 'Phường 4', description: 'Phường 4 - Quận 1'),
      const Ward(id: 5, code: 'PX005', name: 'Phường 5', description: 'Phường 5 - Quận 1'),
    ];
  }

  List<Group> _generateMockGroups(int? wardId) {
    final allGroups = [
      const Group(id: 1, code: 'TO001', name: 'Tổ 1', description: 'Tổ 1 - Phường 1', wardId: 1),
      const Group(id: 2, code: 'TO002', name: 'Tổ 2', description: 'Tổ 2 - Phường 1', wardId: 1),
      const Group(id: 3, code: 'TO003', name: 'Tổ 3', description: 'Tổ 3 - Phường 1', wardId: 1),
      const Group(id: 4, code: 'TO004', name: 'Tổ 1', description: 'Tổ 1 - Phường 2', wardId: 2),
      const Group(id: 5, code: 'TO005', name: 'Tổ 2', description: 'Tổ 2 - Phường 2', wardId: 2),
      const Group(id: 6, code: 'TO006', name: 'Tổ 1', description: 'Tổ 1 - Phường 3', wardId: 3),
      const Group(id: 7, code: 'TO007', name: 'Tổ 2', description: 'Tổ 2 - Phường 3', wardId: 3),
      const Group(id: 8, code: 'TO008', name: 'Tổ 1', description: 'Tổ 1 - Phường 4', wardId: 4),
      const Group(id: 9, code: 'TO009', name: 'Tổ 1', description: 'Tổ 1 - Phường 5', wardId: 5),
    ];

    if (wardId != null) {
      return allGroups.where((group) => group.wardId == wardId).toList();
    }
    return allGroups;
  }

  List<Area> _generateMockAreas(int? groupId) {
    final allAreas = [
      const Area(id: 1, code: 'KH001', name: 'Khu A', description: 'Khu A - Tổ 1', groupId: 1),
      const Area(id: 2, code: 'KH002', name: 'Khu B', description: 'Khu B - Tổ 1', groupId: 1),
      const Area(id: 3, code: 'KH003', name: 'Khu C', description: 'Khu C - Tổ 1', groupId: 1),
      const Area(id: 4, code: 'KH004', name: 'Khu A', description: 'Khu A - Tổ 2', groupId: 2),
      const Area(id: 5, code: 'KH005', name: 'Khu B', description: 'Khu B - Tổ 2', groupId: 2),
      const Area(id: 6, code: 'KH006', name: 'Khu A', description: 'Khu A - Tổ 3', groupId: 3),
      const Area(id: 7, code: 'KH007', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 2', groupId: 4),
      const Area(id: 8, code: 'KH008', name: 'Khu B', description: 'Khu B - Tổ 1 Phường 2', groupId: 4),
      const Area(id: 9, code: 'KH009', name: 'Khu A', description: 'Khu A - Tổ 2 Phường 2', groupId: 5),
      const Area(id: 10, code: 'KH010', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 3', groupId: 6),
      const Area(id: 11, code: 'KH011', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 4', groupId: 8),
      const Area(id: 12, code: 'KH012', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 5', groupId: 9),
    ];

    if (groupId != null) {
      return allAreas.where((area) => area.groupId == groupId).toList();
    }
    return allAreas;
  }
} 