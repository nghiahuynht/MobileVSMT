import 'dart:convert';

class Ward {
  final int id;
  final String? code;
  final String? name;
  final int? parentId;
  final String? parentCode;
  final String? gsoCode;
  final bool? isActive;
  Ward({
    required this.id,
    this.code,
    this.name,
    this.parentId,
    this.parentCode,
    this.gsoCode,
    this.isActive,
  });

  Ward copyWith({
    int? id,
    String? code,
    String? name,
    int? parentId,
    String? parentCode,
    String? gsoCode,
    bool? isActive,
  }) {
    return Ward(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      parentCode: parentCode ?? this.parentCode,
      gsoCode: gsoCode ?? this.gsoCode,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'parentId': parentId,
      'parentCode': parentCode,
      'gsoCode': gsoCode,
      'isActive': isActive,
    };
  }

  factory Ward.fromMap(Map<String, dynamic> map) {
    return Ward(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      parentCode:
          map['parentCode'] != null ? map['parentCode'] as String : null,
      gsoCode: map['gsoCode'] != null ? map['gsoCode'] as String : null,
      isActive: map['isActive'] != null ? map['isActive'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ward.fromJson(String source) =>
      Ward.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ward(id: $id, code: $code, name: $name, parentId: $parentId, parentCode: $parentCode, gsoCode: $gsoCode, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant Ward other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.name == name &&
        other.parentId == parentId &&
        other.parentCode == parentCode &&
        other.gsoCode == gsoCode &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        name.hashCode ^
        parentId.hashCode ^
        parentCode.hashCode ^
        gsoCode.hashCode ^
        isActive.hashCode;
  }
}
