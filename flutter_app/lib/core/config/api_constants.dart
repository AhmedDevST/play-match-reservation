class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Authentication endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String profile = '$baseUrl/user/profile';
  
  // Header keys
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
}
