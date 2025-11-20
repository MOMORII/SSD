import 'dart:ui'; // Import for ImageFilter (used for the frosted glass blur effect).
import 'package:flutter/material.dart'; // Core Flutter material design library.
import '../models/lesson.dart'; // Import the Lesson data model.

/// A StatefulWidget that presents the content of a lesson (slides) using a PageView.
class LessonSlidesViewer extends StatefulWidget {
  /// The Lesson data object containing contentSlides.
  final Lesson lesson;
  /// Callback function to navigate the user to the quiz view.
  final VoidCallback onStartQuiz;
  /// Callback function to navigate the user back to the lesson selection list.
  final VoidCallback onBackToLessons;

  /// Constructor requiring the lesson data and navigation callbacks.
  const LessonSlidesViewer({
    super.key,
    required this.lesson,
    required this.onStartQuiz,
    required this.onBackToLessons,
  });

  @override
  State<LessonSlidesViewer> createState() => _LessonSlidesViewerState();
}

class _LessonSlidesViewerState extends State<LessonSlidesViewer> {
  /// Controller for the PageView, managing scrolling and page state.
  late PageController _pageController;
  /// Tracks the currently visible slide index.
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize PageController, setting viewportFraction to show part of the adjacent slides.
    _pageController = PageController(viewportFraction: 0.85); 
  }

  @override
  void dispose() {
    // Dispose of the PageController to prevent memory leaks.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.lesson.contentSlides;

    // Stack allows layering the background, PageView, and overlay elements (buttons, arrows, dots).
    return Stack(
      alignment: Alignment.center,
      children: [
        // --- BACKGROUND GRADIENT ---
        Container(
          decoration: const BoxDecoration(
            // Uses the same background gradient as the selection list for visual consistency.
            gradient: LinearGradient(
              colors: [Color(0xFF2A2A72), Color(0xFF009FFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // --- MAIN PAGEVIEW WITH ANIMATED SLIDES ---
        PageView.builder(
          controller: _pageController,
          itemCount: slides.length,
          // Updates the state whenever the page changes to trigger UI updates (arrows, dots, button).
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final tip = slides[index];
            // Regex to extract a title if the content starts with bold markdown (**Title**).
            final titleRegex = RegExp(r'^\*\*(.*?)\*\*'); 
            String title = 'Tip ${index + 1}';
            String description = tip;

            final match = titleRegex.firstMatch(tip);
            if (match != null) {
              // If title pattern is found, extract it and update the description.
              title = match.group(1)?.trim() ?? title;
              description = tip.substring(match.end).trim();
            }

            // Smooth transition effect for cards as they move to and from center.
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  // Calculate the position difference (value) relative to the current page.
                  value = (_pageController.page ?? _currentPage).toDouble() - index;
                  // Clamp and invert the value to create a scale factor (closer slides are larger, 0.8 to 1.0).
                  value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0).toDouble();
                }
                return Transform.scale(
                  // Apply the calculated scale factor to the slide card.
                  scale: Curves.easeOut.transform(value),
                  child: Opacity(
                    // Apply opacity based on the scale for a fading effect.
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // The 'frosted glass' card design starts here:
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    // BackdropFilter applies a real blur effect to anything rendered behind it.
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Slide Title
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Slide Description Content
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // --- PAGE INDICATORS (DOTS) ---
        Positioned(
          // Adjusts position lower on the last slide to make room for buttons.
          bottom: _currentPage == slides.length - 1 ? 100 : 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Generates a dot for every slide.
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                // Active dot is wider (20) than inactive dots (10).
                width: _currentPage == index ? 20 : 10, 
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white // Active dot is solid white.
                      : Colors.white.withOpacity(0.5), // Inactive is semi-transparent.
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    // Glow effect for the active dot.
                    if (_currentPage == index)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- ACTION BUTTONS (LAST SLIDE) ---
        // Only shows the buttons when the user is on the final slide.
        if (_currentPage == slides.length - 1)
          Positioned(
            bottom: 40,
            child: Column(
              children: [
                // Primary action: Start Quiz button.
                ElevatedButton.icon(
                  onPressed: widget.onStartQuiz, // Calls the parent's navigation function.
                  icon: const Icon(Icons.quiz),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.orangeAccent.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Secondary action: Back to Lessons button.
                TextButton(
                  onPressed: widget.onBackToLessons, // Calls the parent's navigation function.
                  child: const Text(
                    'Back to Lessons',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}