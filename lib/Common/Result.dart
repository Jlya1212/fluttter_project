// 1. This class wraps the result of any operation (success or failure)

class Result<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  Result._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  // 2. Create a success result
  factory Result.success(T data) {
    return Result._(isSuccess: true, data: data , errorMessage: null);
  }

  // 3. Create a failure result
  factory Result.failure(String message) {
    return Result._(isSuccess: false, data : null , errorMessage: message );
  }

  // 4. Optional: readable print
  @override
  String toString() {
    return isSuccess
        ? 'Result.success(data: $data)'
        : 'Result.failure(error: $errorMessage)';
  }
}
