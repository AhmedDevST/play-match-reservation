class ApiResponse {
  final bool success;
  final String message;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.errors,
  });
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}
