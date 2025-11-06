import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/password_utils.dart';

/// --- MAIN CONTROLLER SCREEN ---
/// The main screen responsible for controlling the password strength flow.
class StrengthFeedbackScreen extends StatefulWidget {
  const StrengthFeedbackScreen({super.key});

  @override
  State<StrengthFeedbackScreen> createState() => _StrengthFeedbackScreenState();
}

class _StrengthFeedbackScreenState extends State<StrengthFeedbackScreen> {
  // Future that will hold any initial async load (e.g., local settings, assets).
  late final Future<void> _initFuture;

  // The currently entered password and controller to update it programmatically.
  String _password = '';
  final TextEditingController _controller = TextEditingController();

  // Whether the password field should obscure text.
  bool _obscure = true;

  // Values derived from utils/password_utils.dart
  double _entropy = 0.0;
  String _label = 'Very Weak';
  Color _color = Colors.red;
  double _progress = 0.0; // 0.0 .. 1.0 mapped from entropy

  @override
  void initState() {
    super.initState();
    _initFuture = _loadResources();
    _updateMetrics(''); // initialize UI for empty password
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    // placeholder for loading assets, common-password list, or DB init.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  void _updateMetrics(String v) {
    final entropy = PasswordStrength.calculateEntropy(v);
    final label = PasswordStrength.getStrengthLabel(entropy);
    final color = PasswordStrength.getStrengthColor(entropy);
    final progress = (entropy / 100.0).clamp(0.0, 1.0);

    setState(() {
      _password = v;
      _entropy = entropy;
      _label = label;
      _color = color;
      _progress = progress;
      // ensure textfield reflects programmatic changes
      if (_controller.text != v) _controller.text = v;
    });
  }

  void _onPasswordChanged(String v) => _updateMetrics(v);

  Future<void> _generatePassword() async {
    final generated = PasswordGenerator.generate(
      length: 16,
      useLowercase: true,
      useUppercase: true,
      useNumbers: true,
      useSymbols: true,
    );
    _updateMetrics(generated);

    // show generated password and offer to copy
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generated password'),
        content: SelectableText(generated),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: generated));
              Navigator.pop(ctx);
            },
            child: const Text('Copy'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Password Strength')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  onChanged: _onPasswordChanged,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Enter password',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        IconButton(
                          icon: const Icon(Icons.autorenew),
                          tooltip: 'Generate',
                          onPressed: _generatePassword,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _progress,
                  color: _color,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_label, style: TextStyle(color: _color, fontWeight: FontWeight.bold)),
                    Text('${_entropy.toStringAsFixed(1)} bits', style: TextStyle(color: _color)),
                  ],
                ),
                const SizedBox(height: 12),
                // Simple suggestions based on missing character classes and length
                Align(alignment: Alignment.centerLeft, child: Text('Suggestions:', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 6),
                ..._buildSuggestions(),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _password.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Password analyzed'),
                              content: Text('Strength: $_label\nEntropy: ${_entropy.toStringAsFixed(1)} bits'),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                            ),
                          );
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Analyze'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSuggestions() {
    final List<String> suggestions = [];
    if (!_password.contains(RegExp(r'[A-Z]'))) suggestions.add('Add uppercase letters.');
    if (!_password.contains(RegExp(r'[a-z]'))) suggestions.add('Add lowercase letters.');
    if (!_password.contains(RegExp(r'[0-9]'))) suggestions.add('Add numbers.');
    if (!_password.contains(RegExp(r'[!@#\$%^&*()\-\_=+\[\]{}|;:,.<>?/~`]'))) suggestions.add('Add special characters.');
    if (_password.length < 12) suggestions.add('Consider making it longer (12+ characters).');

    if (suggestions.isEmpty) {
      return [const Text('No suggestions — looks good!')];
    }

    return suggestions
        .map((s) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 18)),
                Expanded(child: Text(s)),
              ],
            ))
        .toList();
  }
}