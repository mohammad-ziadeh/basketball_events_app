import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

class ApiConfig {
  static String get baseUrl {
    const localIp = 'http://192.168.1.159:8000';

    if (kIsWeb) {
      return localIp;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return localIp;
    } else {
      return localIp;
    }
  }
}
