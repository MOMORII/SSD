import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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

    void _copyPassword() {
    if (_password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard!')),
    );
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
                      mainAxisSize: MainAxisSize.min, // <- important, so it doesn’t take full width
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy password',
                          onPressed: _copyPassword,
                        ),
                        IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ],
                    ),
                  ),
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
                Align(alignment: Alignment.centerLeft, child: Text('Suggestions:', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _buildSuggestions(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Gauge/Speedometer widget at bottom
                SizedBox(
                  height: 180,
                  child: _buildGauge(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGauge() {
    return CustomPaint(
      painter: GaugePainter(
        progress: _progress,
        color: _color,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
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

/// Custom painter for the gauge/speedometer
class GaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    const double startAngle = -math.pi; // left
    const double totalArc = math.pi; // semicircle
    const int segments = 5;
    const double gap = 0.06; // gap between segments (radians)
    final double totalGaps = gap * (segments - 1);
    final double sweepPerSegment = (totalArc - totalGaps) / segments;
    final double filledAngle = totalArc * progress;

    // Draw gray background arcs
    final Paint bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < segments; i++) {
      final double segStart = startAngle + i * (sweepPerSegment + gap);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), segStart, sweepPerSegment, false, bgPaint);
    }

    // Draw filled colored portion (use password strength color directly)
    final Paint fgPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, filledAngle, false, fgPaint);

    // Needle
    final double needleAngle = startAngle + filledAngle;
    final Offset needleEnd = Offset(
      center.dx + radius * 0.72 * math.cos(needleAngle),
      center.dy + radius * 0.72 * math.sin(needleAngle),
    );
    final Paint needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center cap
    final Paint capStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Paint capFill = Paint()..color = color;
    canvas.drawCircle(center, radius * 0.08, capStroke);
    canvas.drawCircle(center, radius * 0.06, capFill);

    // Numeric labels
    final List<String> labels = ['0', '25', '50', '75', '100'];
    for (int i = 0; i < labels.length; i++) {
      final double pos = i / (labels.length - 1);
      final double angle = startAngle + totalArc * pos;
      final Offset labelPos = Offset(
        center.dx + (radius + radius * 0.16) * math.cos(angle),
        center.dy + (radius + radius * 0.16) * math.sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, labelPos - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
