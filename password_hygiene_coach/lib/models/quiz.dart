import 'dart:math'; // Import for the Random class, used for shuffling options.
import 'package:flutter/foundation.dart'; // Import for debugPrint, used for logging errors in debug mode.
import 'package:flutter/material.dart'; // Included but not strictly necessary for this model class.

/// Defines the data structure for a single quiz question.
class Quiz {
  /// The text of the quiz question.
  final String question;
  /// The list of potential answers (options) for the question.
  final List<String> options;
  /// The index within the 'options' list that holds the correct answer.
  final int correctIndex;

  /// Standard constructor for creating a Quiz instance.
  Quiz({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  /// Factory constructor to safely create a Quiz object from a JSON map (e.g., loaded from a file or database).
  factory Quiz.fromJson(Map<String, dynamic> json) {
    // Safely extract the question text, defaulting if null or missing.
    final quizQuestion = (json['question'] as String?)?.trim() ?? 'Missing Question Text';

    // Safely decode options: check if 'options' is a List, then convert all elements to strings.
    final List<String> optionsList = (json['options'] is List)
        ? List<String>.from(json['options'].map((o) => o.toString()))
        : []; // Default to an empty list if not a valid list.

    // Try to retrieve the correct index using snake_case ('correct_index'), 
    // and fall back to camelCase ('correctIndex') for flexibility.
    final dynamic rawCorrectIndex = json['correct_index'] ?? json['correctIndex']; 

    // Validate and sanitize the index: ensures it is an integer, or defaults to -1 if invalid.
    final int parsedIndex = (rawCorrectIndex is int) ? rawCorrectIndex : -1;

    // Data validation check: ensures options exist, and the index is within the valid range [0, length - 1].
    if (optionsList.isEmpty || parsedIndex < 0 || parsedIndex >= optionsList.length) {
      // Log a warning if the quiz data appears invalid.
      debugPrint(
        '⚠️ Invalid quiz data for "$quizQuestion" '
        '(options=${optionsList.length}, correct_index=$parsedIndex)',
      );
      // Return a partially-valid Quiz with a safe but incorrect index (-1) to prevent crashes.
      return Quiz(
        question: quizQuestion,
        options: optionsList,
        correctIndex: -1, // Invalid index marks it as unusable/incorrect.
      );
    }

    // Return a fully validated and correctly constructed Quiz object.
    return Quiz(
      question: quizQuestion,
      options: optionsList,
      correctIndex: parsedIndex,
    );
  }

  /// Converts the Quiz object back into a JSON-compatible map (for saving or transmitting).
  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        // Use snake_case ('correct_index') for consistent output formatting.
        'correct_index': correctIndex, 
      };

  /// Creates a copy of the Quiz object with its options randomly reordered.
  /// This is essential to prevent users from memorizing option positions.
  Quiz copyWithShuffledOptions() {
    // Prevent shuffling if the data is invalid.
    if (options.isEmpty || correctIndex < 0 || correctIndex >= options.length) {
      return this; // Return the original (invalid) object.
    }

    // Create a mutable copy of the options list.
    final shuffled = List<String>.from(options);
    // Shuffle the list in place using a random seed.
    shuffled.shuffle(Random());

    // The critical step: Find the new index of the original correct answer 
    // in the newly shuffled list.
    final newCorrectIndex = shuffled.indexOf(options[correctIndex]);

    // Return a new Quiz instance with the shuffled options and the updated correct index.
    return Quiz(
      question: question,
      options: shuffled,
      correctIndex: newCorrectIndex,
    );
  }
}