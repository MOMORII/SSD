import 'package:flutter/material.dart';
import '../widgets/password_generator.dart';

class PasswordGeneratorScreen extends StatelessWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Password Generator')),
      body: SingleChildScrollView(
        child: PasswordGeneratorWidget(),
      ),
    );
  }
}