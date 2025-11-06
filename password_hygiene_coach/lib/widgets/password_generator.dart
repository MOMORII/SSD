import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/password_utils.dart';
import '../utils/constants.dart';

class PasswordGeneratorWidget extends StatefulWidget {
  const PasswordGeneratorWidget({super.key});

  @override
  State<PasswordGeneratorWidget> createState() => _PasswordGeneratorWidgetState();
}

class _PasswordGeneratorWidgetState extends State<PasswordGeneratorWidget> {
  int _length = 12;
  String _letters = Charsets.lowercase + Charsets.uppercase;
  String _numbers = Charsets.numbers;
  String _symbols = Charsets.symbols;
  String _password = '';

  final _lettersController = TextEditingController();
  final _numbersController = TextEditingController();
  final _symbolsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lettersController.text = _letters;
    _numbersController.text = _numbers;
    _symbolsController.text = _symbols;
  }

  void _generatePassword() {
    setState(() {
      _password = PasswordGenerator.generate(
        length: _length,
        useLowercase: true,
        useUppercase: true,
        useNumbers: true,
        useSymbols: true,
      );
    });
  }

  void _copyPassword() {
    if (_password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard!')),
    );
  }

  @override
  void dispose() {
    _lettersController.dispose();
    _numbersController.dispose();
    _symbolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password length: $_length', style: const TextStyle(fontSize: 16)),
            Slider(
              value: _length.toDouble(),
              min: 8,
              max: 32,
              divisions: 24,
              label: '$_length',
              onChanged: (val) => setState(() => _length = val.toInt()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lettersController,
              decoration: const InputDecoration(
                labelText: 'Letters',
                hintText: 'Enter letters to include (e.g., abcdef...)',
              ),
            ),
            TextField(
              controller: _numbersController,
              decoration: const InputDecoration(
                labelText: 'Numbers',
                hintText: 'Enter numbers to include (e.g., 0123456789)',
              ),
            ),
            TextField(
              controller: _symbolsController,
              decoration: const InputDecoration(
                labelText: 'Symbols',
                hintText: 'Enter symbols to include (e.g., !@#\$%^&*)',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _generatePassword,
                icon: const Icon(Icons.lock),
                label: const Text('Generate Password'),
              ),
            ),
            const SizedBox(height: 20),
            if (_password.isNotEmpty) ...[
              SelectableText(
                _password,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _copyPassword,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}