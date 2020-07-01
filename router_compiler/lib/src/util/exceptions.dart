class RouterCompilerException implements Exception {
  RouterCompilerException([this.message]);

  final String message;

  @override
  String toString() {
    if (message == null) {
      return 'RouterCompilerException';
    }
    return 'RouterCompilerException: $message';
  }
}
