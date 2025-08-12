import 'package:flutter/foundation.dart';
import 'config.dart';

class Logger {
  static void log(String message) {
    if (Config.debug) {
      debugPrint(message);
    }
  }
}
