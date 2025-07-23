import 'dart:convert';

class Group {
  final int id;
  final String? code;
  final String? name;
  final String? description;
  final bool isDeleted;
  final String? label;
  final bool active;
  Group({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isDeleted = false,
    this.label,
    this.active = true,
  });

  Group copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    bool? isDeleted,
    String? label,
    bool? active,
  }) {
    return Group(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      label: label ?? this.label,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'isDeleted': isDeleted,
      'label': label,
      'active': active,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : false,
      label: map['label'] != null ? map['label'] as String : null,
      active: map['active'] != null ? map['active'] as bool : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) =>
      Group.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Group(id: $id, code: $code, name: $name, description: $description, isDeleted: $isDeleted, label: $label, active: $active)';
  }

  @override
  bool operator ==(covariant Group other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.name == name &&
        other.description == description &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.active == active;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        name.hashCode ^
        description.hashCode ^
        isDeleted.hashCode ^
        label.hashCode ^
        active.hashCode;
  }
}
