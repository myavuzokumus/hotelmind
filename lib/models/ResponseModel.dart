class ResponseModel<T> {
  final T? data;
  final String? error;
  final bool success;

  ResponseModel({
    this.data,
    this.error,
    required this.success,
  });

  // Başarılı işlem constructor'ı
  factory ResponseModel.success(T data) {
    return ResponseModel(
      data: data,
      success: true,
    );
  }

  // Hatalı işlem constructor'ı
  factory ResponseModel.error(String errorMessage) {
    return ResponseModel(
      error: errorMessage,
      success: false,
    );
  }
}