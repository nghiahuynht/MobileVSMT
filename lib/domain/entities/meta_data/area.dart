class Area {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int? groupId;

  const Area({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
    this.groupId,
  });

  factory Area.fromMap(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      groupId: json['groupId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'groupId': groupId,
    };
  }

  @override
  String toString() {
    return 'Area(id: $id, code: $code, name: $name)';
  }
} 