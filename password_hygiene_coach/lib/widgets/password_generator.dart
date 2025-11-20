import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/password_utils.dart';

class PasswordGeneratorWidget extends StatefulWidget {
  const PasswordGeneratorWidget({super.key});

  @override
  State<PasswordGeneratorWidget> createState() => _PasswordGeneratorWidgetState();
}

class _PasswordGeneratorWidgetState extends State<PasswordGeneratorWidget> {
  int _length = 12;
  bool _obscurePassword = true;
  String _password = '';

  final _charactersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Leave empty — user will type their own characters.
  }

  void _generatePassword() {
  // RAW user input (don’t substitute defaults yet)
  final userInput = _charactersController.text; // no trim needed for length logic

  // If the user typed more characters than the desired length -> error
  if (userInput.length > _length) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Too many characters — reduce input or increase length.')),
    );
    return;
  }

  // Pass the raw input (can be empty) to the generator.
  // generateWithInput will fill any missing count with random defaults,
  // and will use only defaults if input is empty.
  final newPassword = PasswordGenerator.generateWithInput(
    length: _length,
    input: userInput,
  );

  setState(() {
    _password = newPassword;
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
    _charactersController.dispose();
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

            // Single Characters field (empty by default)
            TextField(
              controller: _charactersController,
              decoration: const InputDecoration(
                labelText: 'Characters',
                hintText: 'Enter characters to include (e.g., abcDEF123!@#)',
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
              TextFormField(
                key: ValueKey(_password),
                initialValue: _password,
                readOnly: true,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Generated Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
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