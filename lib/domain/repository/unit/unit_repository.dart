import 'package:trash_pay/domain/entities/unit/unit.dart';

abstract class UnitRepository {
  Future<List<Unit>> getUnits();
} 