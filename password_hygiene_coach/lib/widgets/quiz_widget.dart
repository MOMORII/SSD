import 'package:flutter/material.dart'; // Core Flutter material design library.
import 'package:password/models/lesson.dart'; // Import the Lesson data model, which contains the original quiz structure.
import 'dart:math'; // Used for the Random class needed for shuffling.

/// A specialized data model for a single quiz question after its options have been shuffled.
class ShuffledQuiz {
  /// The question text itself.
  final String question;
  /// The list of answer options in their randomized order.
  final List<String> shuffledOptions;
  /// The new index of the correct answer within the `shuffledOptions` list.
  final int newCorrectIndex;

  ShuffledQuiz({
    required this.question,
    required this.shuffledOptions,
    required this.newCorrectIndex,
  });
}
/// A StatefulWidget that manages the state and display of the interactive quiz.
class QuizWidget extends StatefulWidget {
  /// The lesson data containing the original quiz questions.
  final Lesson lesson;
  /// Callback function executed when the entire quiz is finished, passing the final score.
  final Function(int score) onQuizFinished;
  /// Callback function to return to the lesson content/slides.
  final VoidCallback onBackToContent;

  const QuizWidget({
    super.key,
    required this.lesson,
    required this.onQuizFinished,
    required this.onBackToContent,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  /// The index of the current question being displayed.
  int _currentQuizIndex = 0;
  /// The index of the option selected by the user for the current question. Null if nothing selected.
  int? _selectedOptionIndex;
  /// Flag to determine if the 'Submit Answer' button has been pressed for the current question.
  bool _isAnswerSubmitted = false;
  /// The user's accumulated score across all questions.
  int _score = 0;
  /// The list of quizzes that have been processed to have their questions and options shuffled.
  late List<ShuffledQuiz> _shuffledQuizzes;

  /// Core logic to randomly order the questions and shuffle options within each question.
  void _initializeQuiz() {
    final originalQuizzes = widget.lesson.quizzes;

    // 1. Shuffle the order of the quiz questions themselves.
    originalQuizzes.shuffle();

    // 2. Map original quiz data to the new ShuffledQuiz format.
    _shuffledQuizzes = originalQuizzes.map((quiz) {
      // Pair original option strings with their original indices.
      final optionsWithIndex = quiz.options.asMap().entries.toList();
      // Shuffle the list of options.
      optionsWithIndex.shuffle(Random());

      // Find the correct option in the newly shuffled list.
      final correctOptionEntry = optionsWithIndex.firstWhere(
        (entry) => entry.key == quiz.correctIndex,
      );

      // Determine the new index of the correct answer after the shuffle.
      final newCorrectIndex = optionsWithIndex.indexOf(correctOptionEntry);

      return ShuffledQuiz(
        question: quiz.question,
        // Extract only the string values for the shuffled options list.
        shuffledOptions: optionsWithIndex.map((e) => e.value).toList(),
        newCorrectIndex: newCorrectIndex,
      );
    }).toList();

    // Reset state variables for a fresh quiz.
    _currentQuizIndex = 0;
    _selectedOptionIndex = null;
    _isAnswerSubmitted = false;
    _score = 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeQuiz(); // Start the quiz setup when the widget is created.
  }

  /// Re-initializes the quiz if the lesson data changes while the widget is active.
  @override
  void didUpdateWidget(covariant QuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson.id != oldWidget.lesson.id) {
      _initializeQuiz();
    }
  }

  /// Handles user tapping an answer option.
  void _handleOptionTap(int index) {
    // Only allow selection if the answer hasn't been submitted yet.
    if (!_isAnswerSubmitted && mounted) { 
      setState(() {
        _selectedOptionIndex = index;
      });
    }
  }

  /// Locks the user's choice and checks if it's correct.
  void _submitAnswer() {
    if (_selectedOptionIndex == null || _isAnswerSubmitted) return;

    final currentQuiz = _shuffledQuizzes[_currentQuizIndex];

    if (!mounted) return;
    setState(() {
      _isAnswerSubmitted = true;
      // Check if the selected index matches the new correct index.
      if (_selectedOptionIndex == currentQuiz.newCorrectIndex) {
        _score++; // Increment score on correct answer.
      }
    });
  }

  /// Moves to the next question or finishes the quiz.
  void _nextQuestion() {
    if (!mounted) return;

    if (_currentQuizIndex < _shuffledQuizzes.length - 1) {
      // Move to the next question and reset selection state.
      setState(() {
        _currentQuizIndex++;
        _selectedOptionIndex = null;
        _isAnswerSubmitted = false;
      });
    } else {
      // Quiz finished, call the external callback with the final score.
      widget.onQuizFinished(_score);
    }
  }

  /// Determines the color of an option tile (white/unanswered, green/correct, red/incorrect).
  Color _getOptionColor(int index, ShuffledQuiz quiz) {
    // Before submission, all options are white/unselected.
    if (!_isAnswerSubmitted || _selectedOptionIndex == null) return Colors.white70;
    // Show green for the correct answer after submission.
    if (index == quiz.newCorrectIndex) return Colors.greenAccent; 
    // Show red for the selected incorrect answer.
    if (index == _selectedOptionIndex && index != quiz.newCorrectIndex) return Colors.redAccent; 
    // Remaining incorrect options.
    return Colors.white70;
  }

  /// Determines the icon displayed next to an option (check, cancel, or none).
  IconData? _getOptionIcon(int index, ShuffledQuiz quiz) {
    if (!_isAnswerSubmitted) return null; // No custom icon before submission.
    if (index == quiz.newCorrectIndex) return Icons.check_circle_outline; // Correct icon.
    if (index == _selectedOptionIndex && index != quiz.newCorrectIndex) return Icons.cancel_outlined; // Incorrect icon.
    return null; // For unselected incorrect options.
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = _shuffledQuizzes;

    // --- Error Handling for Empty Quiz ---
    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'No quiz questions available for this lesson.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              // Button to return to content when there are no questions.
              ElevatedButton(
                onPressed: widget.onBackToContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Lesson'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuiz = quizzes[_currentQuizIndex];

    return Stack(
      children: [
        // Background gradient (consistent look)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A2A72), Color(0xFF009FFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Main quiz card container (with "frosted glass" styling)
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header (Lesson Title and Question Progress) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Current question number out of total.
                    Text(
                      'Question ${_currentQuizIndex + 1} / ${quizzes.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.white38),
                // --- Question Text ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    currentQuiz.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                // --- Answer Options List ---
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuiz.shuffledOptions.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedOptionIndex;
                      // Dynamic styling based on selected/submitted state.
                      final color = _getOptionColor(index, currentQuiz);
                      final icon = _getOptionIcon(index, currentQuiz);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            // Highlights the selected option.
                            color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : Colors.white24,
                              width: 2,
                            ),
                            boxShadow: [
                              // Glow effect on selected/submitted option.
                              if (isSelected)
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                            ],
                          ),
                          child: ListTile(
                            onTap: () => _handleOptionTap(index), // Handle user tap.
                            leading: Icon(
                              // Show correct/incorrect icons if submitted, otherwise radio buttons.
                              icon ?? (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                              color: color,
                            ),
                            title: Text(
                              currentQuiz.shuffledOptions[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                            // Trailing icon explicitly set for feedback if submitted.
                            trailing: _isAnswerSubmitted && icon != null
                                ? Icon(icon, color: color)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // --- Main Action Button (Submit / Next / View Results) ---
                ElevatedButton(
                  onPressed: !_isAnswerSubmitted
                      // If not submitted, enable if an option is selected, otherwise disable (null).
                      ? (_selectedOptionIndex != null ? _submitAnswer : null)
                      // If submitted, move to the next question/results.
                      : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    // Change color from blue (submit) to orange (next/results) after submission.
                    backgroundColor: _isAnswerSubmitted
                        ? Colors.orangeAccent
                        : Colors.blueAccent.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    !_isAnswerSubmitted
                        ? 'Submit Answer' // Prompt to submit.
                        : (_currentQuizIndex < quizzes.length - 1 ? 'Next Question' : 'View Results'), // Prompt to move on.
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                // --- Back to Content Button (Secondary Action) ---
                TextButton(
                  onPressed: widget.onBackToContent,
                  child: const Text(
                    'Back to Lesson Content',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}