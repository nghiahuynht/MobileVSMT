import 'dart:convert';

class Unit {
  final int id;
  final String? code;
  final String? label;
  final String? description;
  final bool? active;
  final bool? isDeleted;
  final String? linkTraCuu;
  final String? address;

  const Unit({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    this.active,
    this.isDeleted,
    this.linkTraCuu,
    this.address,
  });

  factory Unit.fromMap(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      code: json['code'] as String?,
      label: json['label'] as String?,
      description: json['description'] as String?,
      active: json['active'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      linkTraCuu: json['linkTraCuu'] as String?,
      address: json['address'] as String?,
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
      'linkTraCuu': linkTraCuu,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'Unit(id: $id, code: $code, label: $label, description: $description, active: $active, isDeleted: $isDeleted, linkTraCuu: $linkTraCuu, address: $address)';
  }
}
