import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:trash_pay/locator.dart';
import 'package:trash_pay/presentation/my_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await initializeApp();

  runApp(const MyApp());
}
