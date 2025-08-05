class Category {
  final int id;
  final String name;
  final String? description;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
} 