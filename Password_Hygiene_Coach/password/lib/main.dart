
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const PasswordHygieneCoachApp());

class PasswordHygieneCoachApp extends StatelessWidget {
  const PasswordHygieneCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Hygiene Coach',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String password = "";
  final _length = ValueNotifier<int>(12);

  String generatePassword(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Select password length:', style: TextStyle(fontSize: 16)),
            ValueListenableBuilder(
              valueListenable: _length,
              builder: (context, val, _) => Column(
                children: [
                  Slider(
                    value: val.toDouble(),
                    min: 6,
                    max: 32,
                    divisions: 26,
                    label: val.toString(),
                    onChanged: (v) => _length.value = v.toInt(),
                  ),
                  Text('Length: $val characters'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  password = generatePassword(_length.value);
                });
              },
              child: const Text('Generate Password'),
            ),
            const SizedBox(height: 20),
            SelectableText(
              password.isEmpty ? 'Your password will appear here' : password,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

