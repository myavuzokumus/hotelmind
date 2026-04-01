class ResponseModel<T> {
  final T? data;
  final String? error;
  final bool success;

  ResponseModel({
    this.data,
    this.error,
    required this.success,
  });

  // Success constructor
  factory ResponseModel.success(T data) {
    return ResponseModel(
      data: data,
      success: true,
    );
  }

  // Error constructor
  factory ResponseModel.error(String errorMessage) {
    return ResponseModel(
      error: errorMessage,
      success: false,
    );
  }
}