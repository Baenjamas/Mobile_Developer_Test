import 'package:flutter/material.dart';
import 'package:test_intern/feedscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const FeedScreen());
  }
}
