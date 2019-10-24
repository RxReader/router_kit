class TextSymbol {
  TextSymbol._();

  /// 换行
  static const String newLine = '\n';

  /// 回车
  static const String carriageReturn = '\r';

  /// 制表符
  static const String newTab = '\t';

  /// 空
  static const String empty = '';

  /// 空格 - 半角
  static const String dbcSpace = '\u0020';

  /// 空格 - 全角
  static const String sbcSpace = '\u3000';

  /// 段间距占位符
  static const String paragraphSpacingPlaceholder = '\uFFFC\n';
  static const String paragraphSpacingPlaceholderFixed = '\r\n';

  static String toDBC(String text) {
    return text;
  }

  static String toSBC(String text) {
    return text;
  }
}
