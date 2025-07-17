import 'package:flutter/material.dart';
import 'package:trash_pay/locator.dart';
import 'package:trash_pay/presentation/my_app.dart';

Future main() async {
  await initializeApp();

  runApp(const MyApp());
}
