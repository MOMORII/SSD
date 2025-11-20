import 'package:flutter/material.dart'; // Core Flutter framework.
import 'package:password/services/database_helper.dart'; // Service class for database operations (e.g., SQLite).
import 'package:password/models/lesson.dart'; // Data model for a single lesson.

// Imports for custom widgets, using prefixes to prevent naming conflicts.
import 'package:password/widgets/lesson_selection_list.dart' as selection_list;
import 'package:password/widgets/lesson_slides_viewer.dart';
import 'package:password/widgets/quiz_widget.dart';
import 'package:password/widgets/quiz_results_widget.dart';

/// --- STATE ENUM ---
/// Defines the different viewing modes/states for a single selected lesson.
enum LessonViewState { 
  slides, // Viewing the lesson content slides.
  quiz, // Taking the quiz associated with the lesson.
  results // Viewing the results of the completed quiz.
}

/// --- LESSON STATE MODEL ---
/// A simple immutable model class to hold the specific state data for a lesson.
class LessonStateData {
  /// The current view state (slides, quiz, or results).
  final LessonViewState viewState;
  /// The score achieved if the state is LessonViewState.results.
  final int finalScore;

  /// Constructor with default values.
  const LessonStateData({
    this.viewState = LessonViewState.slides,
    this.finalScore = 0,
  });

  /// Helper method to reset the state back to the defaults (slides view, score 0).
  LessonStateData reset() => const LessonStateData();

  /// Helper method to reset the state and explicitly switch to the quiz view.
  LessonStateData resetToQuiz() =>
      const LessonStateData(viewState: LessonViewState.quiz, finalScore: 0);

  /// Helper method to switch the state to results and set the final score.
  LessonStateData toResults(int score) =>
      LessonStateData(viewState: LessonViewState.results, finalScore: score);
}

/// --- MAIN CONTROLLER SCREEN ---
/// The main screen responsible for fetching data and controlling lesson flow.
class LessonCoachScreen extends StatefulWidget {
  const LessonCoachScreen({super.key});

  @override
  State<LessonCoachScreen> createState() => _LessonCoachScreenState();
}

class _LessonCoachScreenState extends State<LessonCoachScreen> {
  // Future that will hold the list of all available lessons loaded from the database.
  late final Future<List<Lesson>> _lessonsFuture;
  // The currently selected lesson, or null if viewing the list.
  Lesson? _selectedLesson;
  // Map to store the unique state (LessonStateData) for each lesson, keyed by lesson ID.
  final Map<int, LessonStateData> _lessonStateMap = {};

  @override
  void initState() {
    super.initState();
    // Start loading lessons as soon as the widget is initialized.
    _lessonsFuture = _loadLessonsSafely();
    // Check and seed the database if necessary (runs asynchronously).
    _ensureLessonsSeeded();
  }

  /// Attempts to reseed the database with lessons if it is empty.
  Future<void> _ensureLessonsSeeded() async {
    try {
      // Calls a database helper method to ensure initial data exists.
      await DatabaseHelper.instance.reseedLessonsIfEmpty();
      // await DatabaseHelper.instance.forceResetLessons(); // Commented out for production use
    } catch (e) {
      // Logs any failure during the seeding process.
      debugPrint('⚠️ Lesson reseed check failed: $e');
    }
  }

  /// Asynchronously fetches all lessons from the database, including error handling.
  Future<List<Lesson>> _loadLessonsSafely() async {
    try {
      final lessons = await DatabaseHelper.instance.getAllLessons();
      return lessons;
    } catch (e, st) {
      // Logs detailed error information if fetching fails.
      debugPrint('💥 Error fetching lessons: $e\n$st');
      return []; // Returns an empty list on failure to prevent app crash.
    }
  }

  /// Callback function triggered when a user selects a lesson from the list.
  void _selectLesson(Lesson lesson) {
    setState(() {
      _selectedLesson = lesson;
      // Ensure the lesson has an entry in the state map, initializing if necessary.
      _lessonStateMap.putIfAbsent(lesson.id, () => const LessonStateData());
      
      final currentState = _lessonStateMap[lesson.id]!;
      // Automatically reset the view to slides (unless it was just viewing results).
      if (currentState.viewState != LessonViewState.results) {
        _lessonStateMap[lesson.id] = currentState.reset();
      }
      // Note: If viewState was 'results', it stays on 'results' so the score remains visible on re-selection.
    });
  }

  /// Function to navigate back from a selected lesson view to the main lesson list.
  void _goBackToLessons() {
    if (_selectedLesson != null) {
      final int lessonId = _selectedLesson!.id;
      // Ensure the selected lesson's state is reset before returning to list.
      _updateLessonState(lessonId, const LessonStateData()); 
      setState(() => _selectedLesson = null); // Clear the selection.
    }
  }

  /// Utility function to update the state of a specific lesson in the map.
  void _updateLessonState(int lessonId, LessonStateData newState) {
    // Check if the widget is still in the widget tree before calling setState.
    if (!mounted) return; 
    setState(() => _lessonStateMap[lessonId] = newState);
  }

  /// Determines and builds the correct content widget based on the current lesson state.
  Widget _buildLessonContent(Lesson lesson) {
    // Get the current state data for the selected lesson.
    final stateData = _lessonStateMap[lesson.id] ?? const LessonStateData();

    // Define callback handlers for navigation within the lesson flow.
    void onQuizFinished(int score) =>
        _updateLessonState(lesson.id, stateData.toResults(score));

    void onBackToSlides() => _updateLessonState(
          lesson.id,
          // Retain the final score when going back to slides from results.
          LessonStateData(
            viewState: LessonViewState.slides,
            finalScore: stateData.finalScore,
          ),
        );

    void onRetry() => _updateLessonState(lesson.id, stateData.resetToQuiz()); // Start the quiz again.

    // Use a switch statement to render the appropriate widget based on the current state.
    switch (stateData.viewState) {
      case LessonViewState.slides:
        return LessonSlidesViewer(
          // Key ensures widget is rebuilt correctly when state changes or lesson changes.
          key: ValueKey('slides-${lesson.id}-${stateData.finalScore}'), 
          lesson: lesson,
          onStartQuiz: () => _updateLessonState(
            lesson.id,
            const LessonStateData(viewState: LessonViewState.quiz),
          ),
          onBackToLessons: _goBackToLessons,
        );

      case LessonViewState.quiz:
        return QuizWidget(
          key: ValueKey('quiz-${lesson.id}-${stateData.viewState}'),
          lesson: lesson,
          onQuizFinished: onQuizFinished,
          onBackToContent: onBackToSlides,
        );

      case LessonViewState.results:
        return QuizResultsWidget(
          key: ValueKey('results-${lesson.id}-${stateData.finalScore}'),
          lesson: lesson,
          stateData: stateData,
          onBackToLessons: _goBackToLessons,
          onRetry: onRetry,
          onBackToSlides: onBackToSlides,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLessonSelected = _selectedLesson != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isLessonSelected ? _selectedLesson!.title : 'Lesson Contents'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // Shows a back button if a lesson is selected, otherwise null (no back button).
        leading: isLessonSelected
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToLessons,
              )
            : null,
      ),
      // FutureBuilder handles the asynchronous loading of lessons.
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          // 1. Loading state: Show spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error state: Show error message.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '💥 Error loading lessons.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // 3. Data Loaded: Check for empty list.
          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return const Center(
              child: Text('No lessons available. Please check your database.'),
            );
          }

          // 4. Data Loaded: If no lesson is selected, show the list.
          if (!isLessonSelected) {
            // Uses the prefixed import name.
            return selection_list.LessonSelectionList(
              key: const ValueKey('LessonSelectionList'),
              lessons: lessons,
              onSelectLesson: _selectLesson,
            );
          }

          // 5. Data Loaded: If a lesson IS selected, show its content (slides/quiz/results).
          // AnimatedSwitcher provides a smooth transition between the slides, quiz, and results widgets.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _buildLessonContent(_selectedLesson!), // Call the builder method to show the correct widget.
          );
        },
      ),
    );
  }
}