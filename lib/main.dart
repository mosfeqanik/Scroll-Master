import 'package:flutter/material.dart';
import 'main_app.dart';

final class Sections {
  final String value;

  Sections({required this.value});
}

final sections = [
  Sections(value: "one"),
  Sections(value: "two"),
  Sections(value: "three"),
  Sections(value: "four"),
  Sections(value: "five"),
];

void main() {
  runApp(const MainApp());
}

