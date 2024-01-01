class CreateUserRequest {
  final String email;
  final String password;
  final String name;

  CreateUserRequest({required this.email, required this.password, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      email: json['email'],
      password: json['password'],
      name: json['name'],
    );
  }
}
