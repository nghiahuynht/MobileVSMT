import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/locator.dart';
import 'package:flutter_boilerplate/presentation/my_app.dart';

Future main() async {
  await initializeApp();

  runApp(const MyApp());
}
