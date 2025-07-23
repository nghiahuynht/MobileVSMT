// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Route {
  final int id;
  final String? code;
  final String? name;
  final String? startDate;
  final String? areaSaleCode;
  final String? areaSaleName;
  final String? saleAdminUserCode;
  final String? saleAdminName;
  final String? description;
  final bool? isDeleted;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;
  Route({
    required this.id,
    required this.code,
    required this.name,
    required this.startDate,
    required this.areaSaleCode,
    required this.areaSaleName,
    required this.saleAdminUserCode,
    required this.saleAdminName,
    required this.description,
    required this.isDeleted,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });


  Route copyWith({
    int? id,
    String? code,
    String? name,
    String? startDate,
    String? areaSaleCode,
    String? areaSaleName,
    String? saleAdminUserCode,
    String? saleAdminName,
    String? description,
    bool? isDeleted,
    String? createdBy,
    String? createdDate,
    String? updatedBy,
    String? updatedDate,
  }) {
    return Route(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      areaSaleCode: areaSaleCode ?? this.areaSaleCode,
      areaSaleName: areaSaleName ?? this.areaSaleName,
      saleAdminUserCode: saleAdminUserCode ?? this.saleAdminUserCode,
      saleAdminName: saleAdminName ?? this.saleAdminName,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'startDate': startDate,
      'areaSaleCode': areaSaleCode,
      'areaSaleName': areaSaleName,
      'saleAdminUserCode': saleAdminUserCode,
      'saleAdminName': saleAdminName,
      'description': description,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdDate': createdDate,
      'updatedBy': updatedBy,
      'updatedDate': updatedDate,
    };
  }

  factory Route.fromMap(Map<String, dynamic> map) {
    return Route(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      startDate: map['startDate'] != null ? map['startDate'] as String : null,
      areaSaleCode: map['areaSaleCode'] != null ? map['areaSaleCode'] as String : null,
      areaSaleName: map['areaSaleName'] != null ? map['areaSaleName'] as String : null,
      saleAdminUserCode: map['saleAdminUserCode'] != null ? map['saleAdminUserCode'] as String : null,
      saleAdminName: map['saleAdminName'] != null ? map['saleAdminName'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : null,
      createdBy: map['createdBy'] != null ? map['createdBy'] as String : null,
      createdDate: map['createdDate'] != null ? map['createdDate'] as String : null,
      updatedBy: map['updatedBy'] != null ? map['updatedBy'] as String : null,
      updatedDate: map['updatedDate'] != null ? map['updatedDate'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Route.fromJson(String source) => Route.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Route(id: $id, code: $code, name: $name, startDate: $startDate, areaSaleCode: $areaSaleCode, areaSaleName: $areaSaleName, saleAdminUserCode: $saleAdminUserCode, saleAdminName: $saleAdminName, description: $description, isDeleted: $isDeleted, createdBy: $createdBy, createdDate: $createdDate, updatedBy: $updatedBy, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant Route other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.code == code &&
      other.name == name &&
      other.startDate == startDate &&
      other.areaSaleCode == areaSaleCode &&
      other.areaSaleName == areaSaleName &&
      other.saleAdminUserCode == saleAdminUserCode &&
      other.saleAdminName == saleAdminName &&
      other.description == description &&
      other.isDeleted == isDeleted &&
      other.createdBy == createdBy &&
      other.createdDate == createdDate &&
      other.updatedBy == updatedBy &&
      other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      code.hashCode ^
      name.hashCode ^
      startDate.hashCode ^
      areaSaleCode.hashCode ^
      areaSaleName.hashCode ^
      saleAdminUserCode.hashCode ^
      saleAdminName.hashCode ^
      description.hashCode ^
      isDeleted.hashCode ^
      createdBy.hashCode ^
      createdDate.hashCode ^
      updatedBy.hashCode ^
      updatedDate.hashCode;
  }
}
