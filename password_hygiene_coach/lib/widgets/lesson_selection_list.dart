import 'package:flutter/material.dart'; // Core Flutter material design library.
import '../models/lesson.dart'; // Import the Lesson data model.

/// --- LESSON SELECTION LIST WITH THEMED CARDS ---
/// A stateless widget that displays all available lessons in a themed, scrollable list.
class LessonSelectionList extends StatelessWidget {
  /// The list of Lesson objects to display.
  final List<Lesson> lessons;
  /// Callback function executed when a lesson card is tapped, passing the selected Lesson object.
  final Function(Lesson) onSelectLesson;

  /// Constructor requiring the list of lessons and the selection handler.
  const LessonSelectionList({
    super.key,
    required this.lessons,
    required this.onSelectLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // The overall container provides the screen background.
      decoration: const BoxDecoration(
        // Applies a blue/purple linear gradient for a modern, high-contrast look.
        gradient: LinearGradient(
          colors: [Color(0xFF2A2A72), Color(0xFF009FFD)], // Dark to Light Blue/Purple
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      // ListView.builder efficiently creates the list of lesson cards.
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8), // Vertical spacing between cards.
            child: GestureDetector(
              // Taps on the card trigger the external selection function.
              onTap: () => onSelectLesson(lesson),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  // 'Frosted glass' effect: partially transparent white color.
                  color: Colors.white.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(20),
                  // Slight white border to enhance the "lifted" look.
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    // Shadow for depth and separation from the gradient background.
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                // Uses a Row to arrange the icon, title, and forward arrow horizontally.
                child: Row(
                  children: [
                    // Icon representing the lesson, styled with orangeAccent.
                    Icon(
                      lesson.iconData,
                      color: Colors.orangeAccent,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    // Expanded widget ensures the title takes up available space.
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text contrasts with the dark background.
                          // Text shadow improves readability against the subtle card color.
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Standard navigation indicator icon.
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}