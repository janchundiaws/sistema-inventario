class Role {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name)';
  }
} 