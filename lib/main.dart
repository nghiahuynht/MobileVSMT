import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/presentation/my_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  if (kIsWeb) {
    /// This is required to remove the '#' from the URL for web
    /// Before flutterexample.dev/#/path/to/screen
    /// After flutterexample.dev/path/to/screen
    usePathUrlStrategy();
  }

  runApp(const MyApp());
}
