import 'dart:math'; // Used for mathematics constants like 'pi' for confetti directions.
import 'package:flutter/material.dart'; // Core Flutter material design library.
import 'package:confetti/confetti.dart'; // External package for confetti animation effects.
import 'package:password/models/lesson.dart'; // Import the Lesson data model.
import 'package:password/screens/LessonCoachScreen.dart'; // Import for LessonStateData structure.

/// A StatefulWidget that displays the final quiz results (score, pass/fail status)
/// and provides action buttons (retry, review slides, back to lessons).
class QuizResultsWidget extends StatefulWidget {
  /// The Lesson object containing quiz metadata (total number of questions).
  final Lesson lesson;
  /// The data object containing the user's performance, specifically the finalScore.
  final LessonStateData stateData;
  /// Callback to navigate back to the main lesson selection screen.
  final VoidCallback onBackToLessons;
  /// Callback to restart the quiz immediately.
  final VoidCallback onRetry;
  /// Callback to navigate back to the lesson slides for review.
  final VoidCallback onBackToSlides;

  const QuizResultsWidget({
    super.key,
    required this.lesson,
    required this.stateData,
    required this.onBackToLessons,
    required this.onRetry,
    required this.onBackToSlides,
  });

  @override
  State<QuizResultsWidget> createState() => _QuizResultsWidgetState();
}

class _QuizResultsWidgetState extends State<QuizResultsWidget> {
  /// Controller for managing the confetti animation playback.
  ConfettiController? _confettiController;
  /// The dynamic message shown to the user (e.g., "Perfect Score!").
  late String message;
  /// The number of particles for the confetti blast (higher for better scores).
  late int particles;
  /// The frequency of emission for the confetti blast.
  late double emissionFrequency;
  /// Flag to check for a perfect score (100%).
  late bool perfectScore;
  /// Flag to determine if the user passed the quiz (>= 75%).
  late bool passed;

  @override
  void initState() {
    super.initState();
    final totalQuestions = widget.lesson.quizzes.length;
    final score = widget.stateData.finalScore;

    // --- Score Calculation and Pass/Fail Determination ---
    // The passing score is set at 75% of the total questions, rounded up.
    final passingScore = (totalQuestions * 0.75).ceil(); 
    passed = score >= passingScore;

    // Calculate percentage for dynamic feedback messages.
    double percentage = totalQuestions > 0 ? score / totalQuestions : 0;
    perfectScore = percentage == 1.0;

    // --- Dynamic Messages & Confetti Configuration ---
    if (perfectScore) {
      message = '🎉 Perfect Score! 🎉';
      particles = 30; // Max particles for perfect score.
      emissionFrequency = 0.05;
    } else if (percentage >= 0.9) {
      message = '✨ Great Job! ✨';
      particles = 20;
      emissionFrequency = 0.05;
    } else if (percentage >= 0.7) {
      message = '🌟 Mission Accomplished! 🌟';
      particles = 15;
      emissionFrequency = 0.05;
    } else {
      // Lower scores don't trigger confetti.
      message = 'Keep Trying!';
      particles = 0;
      emissionFrequency = 0;
    }

    // Initialize and play the confetti only if particles > 0.
    if (particles > 0) {
      _confettiController = ConfettiController(duration: const Duration(seconds: 3))
        ..play();
    }
  }

  @override
  void dispose() {
    // Dispose the confetti controller to clean up resources.
    _confettiController?.dispose();
    super.dispose();
  }

  /// Helper widget to build and configure a ConfettiWidget instance.
  Widget buildConfetti(double angle, double gravity, double emissionFreq, int numberOfParticles) {
    if (_confettiController == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController!,
        // Creates a full 360-degree blast.
        blastDirectionality: BlastDirectionality.explosive, 
        shouldLoop: false,
        // Custom color palette for the confetti.
        colors: const [
          Color(0xFFFFA726),
          Color(0xFFFF7043),
          Color(0xFFFFEB3B),
          Color(0xFF66BB6A),
          Color(0xFF29B6F6),
        ],
        numberOfParticles: numberOfParticles,
        emissionFrequency: emissionFreq,
        gravity: gravity,
        // The angle (blastDirection) is set dynamically.
        blastDirection: angle, 
        minBlastForce: 6,
        maxBlastForce: 12,
        particleDrag: 0.05,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.lesson.quizzes.length;
    final score = widget.stateData.finalScore;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background gradient container, consistent with other screens.
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A2A72), Color(0xFF009FFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Main content card in the center.
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              // Styling for the "frosted glass" results card.
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pass/Fail Icon: check for passed, error for failed.
                  Icon(
                    passed ? Icons.check_circle_outline : Icons.error_outline,
                    size: 70,
                    color: passed ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  // Dynamic celebratory/encouragement message.
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      // Text color changes based on perfect score, pass, or fail.
                      color: perfectScore
                          ? Colors.orangeAccent
                          : (passed ? Colors.greenAccent : Colors.redAccent),
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Display the score achieved.
                  Text(
                    'Score: $score / $totalQuestions',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Primary Action Button: changes based on whether the user passed.
                  ElevatedButton(
                    // If passed, go back to lessons. If failed, offer retry.
                    onPressed: passed ? widget.onBackToLessons : widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed ? Colors.blueAccent.withOpacity(0.9) : Colors.redAccent.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(passed ? 'Back to Lesson Contents' : 'Retry Quiz'),
                  ),
                  const SizedBox(height: 8),
                  // Secondary Action: Review Lesson Slides.
                  TextButton(
                    onPressed: widget.onBackToSlides,
                    child: const Text(
                      'Review Lesson Slides',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Confetti Overlays ---
        // Only render confetti widgets if particles > 0.
        if (particles > 0) ...[
          // Main center blast (straight down: pi/2)
          buildConfetti(pi / 2, perfectScore ? 0.3 : 0.4, emissionFrequency, particles),
          // Additional angled blasts for a huge explosion on perfect score.
          if (perfectScore) buildConfetti(pi / 3, 0.25, 0.05, particles), // Angled left
          if (perfectScore) buildConfetti(2 * pi / 3, 0.25, 0.05, particles), // Angled right
        ],
      ],
    );
  }
}