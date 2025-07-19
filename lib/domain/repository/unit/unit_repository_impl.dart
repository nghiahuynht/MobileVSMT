import 'dart:convert';

import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/unit/unit.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository.dart';
import 'package:trash_pay/services/network_service.dart';

class UnitRepositoryImpl implements UnitRepository {
  final DioNetwork _networkService = DioNetwork.instance;

  @override
  Future<List<Unit>> getUnits() async {
    try {
        final result = await _networkService.get<List<Unit>>(
          ApiConfig.unitsEndpoint,
          fromJson: (data) {
            final List<dynamic> listData = jsonDecode(data)['data'];
            return listData.map((json) => Unit.fromMap(json)).toList();
          },
        );
        
        if (result is Success<List<Unit>>) {
          return result.data;
        } else if (result is Failure<List<Unit>>) {
          throw Exception(result.errorResultEntity.message);
        } else {
          throw Exception('Unexpected result type');
        }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
} 