import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/locator.dart';
import 'package:flutter_boilerplate/presentation/my_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future main() async {
  if (kIsWeb) {
    /// This is required to remove the '#' from the URL for web
    /// Before flutterexample.dev/#/path/to/screen
    /// After flutterexample.dev/path/to/screen
    usePathUrlStrategy();
  }

  await initializeApp();

  runApp(const MyApp());
}
