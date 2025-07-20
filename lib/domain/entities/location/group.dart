class Group {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int? wardId;

  const Group({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
    this.wardId,
  });

  factory Group.fromMap(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      wardId: json['wardId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'wardId': wardId,
    };
  }

  @override
  String toString() {
    return 'Group(id: $id, code: $code, name: $name)';
  }
} 