class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  // Optional: Convert to/from JSON for Firebase or local storage
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}
