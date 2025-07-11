import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/locator.dart';
import 'package:flutter_boilerplate/presentation/my_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await initializeApp();

  runApp(const MyApp());
}
