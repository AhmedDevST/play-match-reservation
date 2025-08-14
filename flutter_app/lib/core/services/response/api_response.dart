class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    List<String>? extractedErrors;
    if (json['errors'] != null && json['errors'] is Map) {
      extractedErrors = (json['errors'] as Map<String, dynamic>)
          .values
          .expand((value) => List<String>.from(value))
          .toList();
    }
    T? parsedData;
    if (fromJsonT != null && json['data'] != null) {
      parsedData = fromJsonT(Map<String, dynamic>.from(json['data']));
    }
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: parsedData,
      errors: extractedErrors,
    );
  }
}
