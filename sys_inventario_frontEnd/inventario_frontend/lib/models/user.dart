class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final String? roleName;
  final bool status;
  final String? lastLogin;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.roleName,
    required this.status,
    this.lastLogin,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
      roleName: json['role_name'],
      status: json['status'] ?? true,
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
      'role_name': roleName,
      'status': status,
      'last_login': lastLogin,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, roleId: $roleId)';
  }
} 