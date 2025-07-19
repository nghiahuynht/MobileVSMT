// {"data":[{"id":1,"code":"DVCIChuan","label":"DVCI Chuan","description":null,"active":null,"isDeleted":null},{"id":2,"code":"DichVuCong_Demo","label":"DichVuCong Demo","description":null,"active":null,"isDeleted":null}],"isSuccess":true,"message":"Success","code":200}
import 'dart:convert';

class Unit {
  final int id;
  final String? code;
  final String? label;
  final String? description;
  final bool? active;
  final bool? isDeleted;

  const Unit({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    this.active,
    this.isDeleted,
  });

  factory Unit.fromMap(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      code: json['code'] as String?,
      label: json['label'] as String?,
      description: json['description'] as String?,
      active: json['active'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
    );
  }

  factory Unit.fromJson(String json) {
    return Unit.fromMap(jsonDecode(json)['data']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'label': label,
      'description': description,
      'active': active,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() {
    return 'Unit(id: $id, code: $code, label: $label, description: $description, active: $active, isDeleted: $isDeleted)';
  }
}
