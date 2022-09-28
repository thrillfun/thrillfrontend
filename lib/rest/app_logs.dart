class Log {
  static const isDebug = false;

  static console(Object? msg) {
    if (isDebug) print(msg);
  }
}
