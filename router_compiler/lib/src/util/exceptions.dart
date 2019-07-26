class RouterCompilerException implements Exception {
  final String message;

  RouterCompilerException([this.message]);

  String toString() {
    if (message == null) return "RouterCompilerException";
    return "RouterCompilerException: $message";
  }
}
