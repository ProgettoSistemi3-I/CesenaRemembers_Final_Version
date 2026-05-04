import 'dart:developer' as developer;

class AppLogger {
  const AppLogger._();

  static void info(String message, {String name = 'CesenaRemembers'}) {
    developer.log(message, name: name);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'CesenaRemembers',
  }) {
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
