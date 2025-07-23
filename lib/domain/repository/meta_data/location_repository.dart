import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';

abstract class LocationRepository {
  Future<List<Ward>> getWards();
  Future<List<Group>> getGroups({int? wardId});
  Future<List<Area>> getAreas({int? groupId});
} 