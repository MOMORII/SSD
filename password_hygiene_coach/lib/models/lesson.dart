import 'dart:convert'; // Import for JSON encoding/decoding operations
import 'package:flutter/material.dart'; // Import for using Flutter widgets and types like IconData
import 'quiz.dart'; // Imports the 'Quiz' class definition (assumed location)
// For the debugPrint function, useful for logging in development

/// Defines the structure for a single lesson within the application.
class Lesson {
  /// Unique identifier for the lesson (e.g., primary key from a database).
  final int id;
  /// Display title of the lesson.
  final String title;
  /// Flutter IconData object used to display a representative icon for the lesson.
  final IconData iconData;
  /// List of strings, where each string is a separate "slide" or piece of content.
  final List<String> contentSlides;
  /// List of Quiz objects associated with this lesson for assessment.
  final List<Quiz> quizzes;

  /// Standard constructor to create a Lesson instance.
  Lesson({
    required this.id,
    required this.title,
    required this.iconData,
    required this.contentSlides,
    required this.quizzes,
  });

  /// Factory constructor to create a Lesson object from a raw data map,
  /// typically retrieved from a database query (e.g., SQL/SQLite).
  factory Lesson.fromSqlMap(Map<String, dynamic> map) {
    // --- Content Slides Decoding (content_json) ---

    // Initialize an empty list for the content slides.
    List<String> slides = [];
    // Safely retrieve 'content_json' as a string, defaulting to an empty JSON list '[]' if null.
    final contentString = map['content_json'] as String? ?? '[]';

    // Proceed only if the content string is not empty after trimming.
    if (contentString.trim().isNotEmpty) {
      try {
        // Attempt to parse the JSON string into a Dart object.
        final decoded = jsonDecode(contentString);

        if (decoded is List) {
          // If the decoded content is a list (expected format: list of slide strings).
          // Map list elements to string, ensuring nulls are converted to empty strings,
          // and then filter out any resulting empty strings.
          slides = decoded.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        } else {
          // Handle case where content might be stored as a single JSON object or a raw string.
          slides = [decoded.toString()];
        }
      } catch (e) {
        // Catch any JSON parsing errors (e.g., malformed JSON).
        // Log the error for debugging purposes, including the lesson ID and the faulty content.
        debugPrint('JSON DECODE ERROR for lesson ID ${map['id']}: $e. Content was: "$contentString"');
        // Insert a clear error message as the content slide for the user.
        slides = ['**Error:** Failed to parse lesson content. Check database content_json for JSON errors.'];
      }
    }

    // Final check: if JSON parsing or content extraction resulted in an empty list,
    // provide a default message.
    if (slides.isEmpty) slides = ['No content available.'];

    // --- Quizzes Decoding (quiz_data_json) ---

    // Initialize an empty list for quizzes.
    List<Quiz> quizzes = [];
    // Safely retrieve 'quiz_data_json' as a string, defaulting to an empty JSON list '[]' if null.
    final quizJsonString = (map['quiz_data_json'] as String?)?.trim() ?? '[]';

    // Proceed only if the quiz JSON string is not empty.
    if (quizJsonString.isNotEmpty) {
      try {
        // Attempt to parse the quiz JSON string.
        final decodedQuiz = jsonDecode(quizJsonString);
        if (decodedQuiz is List) {
          // If the decoded content is a list (expected format: list of quiz objects).
          quizzes = decodedQuiz
              // Map each JSON object in the list to a Quiz instance using its factory constructor.
              .map((q) => Quiz.fromJson(q as Map<String, dynamic>)) 
              // Filter out quizzes that might be invalid (e.g., no options).
              .where((q) => q.options.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // Catch any JSON parsing errors for quizzes and default to an empty list.
        quizzes = [];
      }
    }

    // Return the newly constructed Lesson object, using safe defaults if map values are null.
    return Lesson(
      id: map['id'] as int? ?? 0, // Default ID to 0
      title: map['title'] as String? ?? 'Untitled Lesson', // Default title
      // Convert the string icon name from the database into a Flutter IconData object.
      iconData: _getIconData(map['icon_name'] as String? ?? ''), 
      contentSlides: slides, // Use the parsed and validated slides list
      quizzes: quizzes, // Use the parsed and validated quizzes list
    );
  }

  /// Private static method to map a string name (from the database) to a Flutter IconData object.
  static IconData _getIconData(String name) {
    // Map of database-friendly names to actual Flutter IconData constants.
    const Map<String, IconData> iconMap = {
      'security': Icons.security,
      'cloud_off': Icons.cloud_off,
      'warning_amber': Icons.warning_amber,
      'lock_outline': Icons.lock_outline,
      'privacy_tip': Icons.privacy_tip,
      'vpn_key': Icons.vpn_key,
      'verified_user': Icons.verified_user,
      'key': Icons.key,
      'fingerprint': Icons.fingerprint,
      'lock_open': Icons.lock_open,
      'alternate_email': Icons.alternate_email,
      'web': Icons.web,
      'history_toggle_off': Icons.history_toggle_off,
      'phone_android': Icons.phone_android,
      'restore': Icons.restore,
      'wifi_off': Icons.wifi_off,
    };
    // Look up the icon name. If not found, return a default 'help_outline' icon.
    return iconMap[name] ?? Icons.help_outline;
  }
}

/// Enumeration to represent the possible outcomes of a quiz question attempt.
enum QuizResult { 
  correct, // User selected the correct answer
  incorrect, // User selected an incorrect answer
  unanswered // User did not answer
}