class LoginDTO {
  final String email;
  final String password;

  LoginDTO({required this.email, required this.password});

  // Convert the LoginDTO to a Map for easier handling when sending data to the backend
  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}
