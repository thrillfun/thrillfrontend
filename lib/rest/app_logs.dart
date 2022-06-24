class Log {
  static const isDebug = true;

  static console(Object? msg) {
    if (isDebug) print(msg);
  }
}