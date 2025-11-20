import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

// Entropy calculation (Stength meter logic)
class PasswordStrength {
  // Calculate the estimated cryptographic entropy in bits.
  // Entropy = L * log2(N), where L is length and R is character pool size.
  static double calculateEntropy(String password) {
    if (password.isEmpty) return 0.0;

    // Estimate the size of the character pool (R) used in the password.
    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += Charsets.lowercase.length;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += Charsets.uppercase.length;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += Charsets.numbers.length;
    if (password.contains(RegExp(r'[!@#\$%^&*()-_=+[]{}|;:,.<>?/~`]'))) poolSize += Charsets.symbols.length;
    if (poolSize == 0) return 0.0;

    // L * log2(N)
    final double entropy = password.length * (log(poolSize) / log(2));
    return entropy;
  }

  // Converts entropy bits to a visual strength level
  static String getStrengthLabel(double entropy) {
    if (entropy < 30) return 'Very Weak';
    if (entropy < 60) return 'Weak';
    if (entropy < 80) return 'Moderate';
    if (entropy < 100) return 'Strong';
    return 'Very Strong';
  }

  // Converts entropy bits to a color for meter

  static Color getStrengthColor(double entropy) {
    if (entropy < 30) return Color(0xFFFF0000); // Red
    if (entropy < 60) return Color(0xFFFFA500); // Orange
    if (entropy < 80) return Color(0xFFFFFF00); // Yellow
    if (entropy < 100) return Color(0xFF9ACD32); // YellowGreen
    return Color(0xFF008000); // Green
  } 

}

class PasswordGenerator {
  static String generate ({
    required int length,
    required bool useLowercase,
    required bool useUppercase,
    required bool useNumbers,
    required bool useSymbols,
  }) {
    String charPool = '';
    if (useLowercase) charPool += Charsets.lowercase;
    if (useUppercase) charPool += Charsets.uppercase; 
    if (useNumbers) charPool += Charsets.numbers;
    if (useSymbols) charPool += Charsets.symbols;

    // Use a cryptographically secure random number generator
    final random = Random.secure();
    final buffer= StringBuffer();

    // Ensure at least one character from each selected set is used
    final requiredChars = <String>[];
    if (useLowercase) requiredChars.add(Charsets.lowercase);
    if (useUppercase) requiredChars.add(Charsets.uppercase);
    if (useNumbers) requiredChars.add(Charsets.numbers);
    if (useSymbols) requiredChars.add(Charsets.symbols);

    // Add one required character from each set
    for (String set in requiredChars) {
      if (buffer.length < length) 
      buffer.write(set[random.nextInt(set.length)]);
    }

    
  // Fill the rest of the length from the complete charpool
  while (buffer.length < length) {
    buffer.write(charPool[random.nextInt(charPool.length)]);
  }

  // Shuffle the result to prevent predictable sequences
  final resultList = buffer.toString().split('');
  resultList.shuffle(random);

  return resultList.join();
  }

  static String generateWithInput({
    required int length,
    required String input,
  }) {
    final random = Random.secure();
    final defaults =
        Charsets.lowercase + Charsets.uppercase + Charsets.numbers + Charsets.symbols;

    // Step 1: If user input is shorter, fill with random defaults
    String pool = input;
    while (pool.length < length) {
      pool += defaults[random.nextInt(defaults.length)];
    }

    // Step 2: Trim if longer (the UI already warns)
    if (pool.length > length) {
      pool = pool.substring(0, length);
    }

    // Step 3: Shuffle for randomness
    final chars = pool.split('');
    chars.shuffle(random);
    return chars.join();
  }
}