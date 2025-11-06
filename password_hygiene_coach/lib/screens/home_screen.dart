import 'package:flutter/material.dart';
import 'LessonCoachScreen.dart';
import 'password_generator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) =>
                    Icon(Icons.lock_rounded, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
        ),
        title: const Text('Password Hygiene Coach'),
        centerTitle: false,

        //Top navigation bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _TopMenuBar(
            onHome: () {},
            onLessons: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LessonCoachScreen()),
              );
            },
            onGenerator: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen()),
              );
            },
            onTester: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password Strength Tester coming soon!')),
            ),
          ),
        ),
      ),

      // background colouring
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.18),
                  theme.colorScheme.tertiary.withOpacity(0.14),
                  theme.colorScheme.secondary.withOpacity(0.12),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // hero row
                      Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _BigLogo(diameter: isWide ? 420 : 280),
                          SizedBox(width: isWide ? 28 : 0, height: isWide ? 0 : 20),
                          Expanded(
                            child: _TextPanel(
                              height: isWide ? 260 : 220,
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Text(
                                  'Welcome to KeyWise, a password hygiene coach application that helps you learn, build, and maintain strong and secure passwords. Through interactive lessons, quizzes, and tools like a password generator and strength tester, KeyWise guides you toward safer online habits and better digital security.',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24, // 👈 Increased text size
                                    color: theme.colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // colorful action cards
                      LayoutBuilder(
                        builder: (_, c) {
                          final twoCols = isWide || c.maxWidth > 560;
                          final ratio = twoCols ? 16 / 6 : 16 / 5;
                          return GridView.count(
                            crossAxisCount: twoCols ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: ratio,
                            children: [
                              _FeatureCard(
                                color: theme.colorScheme.primary,
                                icon: Icons.menu_book_rounded,
                                title: 'Lessons & Quizzes',
                                subtitle: 'Learn the essentials and test yourself',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LessonCoachScreen()),
                                  );
                                },
                              ),
                              _FeatureCard(
                                color: theme.colorScheme.tertiary,
                                icon: Icons.password_rounded,
                                title: 'Password Generator',
                                subtitle: 'Create strong, unique passwords instantly',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen()),
                                  );
                                },
                              ),
                              _FeatureCard(
                                color: theme.colorScheme.secondary,
                                icon: Icons.security_rounded,
                                title: 'Strength Tester',
                                subtitle: 'Check how secure your passwords really are',
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password Strength Tester coming soon!')),
                                ),
                              ),
                              _FeatureCard(
                                color: theme.colorScheme.error,
                                icon: Icons.insights_rounded,
                                title: 'Tips & Best Practices',
                                subtitle: 'Get quick, practical advice for stronger passwords',
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tips coming soon!')),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ─────────────── Top Menu Bar ─────────────── */

class _TopMenuBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onLessons;
  final VoidCallback onGenerator;
  final VoidCallback onTester;

  const _TopMenuBar({
    required this.onHome,
    required this.onLessons,
    required this.onGenerator,
    required this.onTester,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 8),
            _MenuChip(text: 'Home', icon: Icons.home_rounded, onTap: onHome),
            _MenuChip(text: 'Lessons', icon: Icons.menu_book_rounded, onTap: onLessons),
            _MenuChip(text: 'Generator', icon: Icons.password_rounded, onTap: onGenerator),
            _MenuChip(text: 'Strength Tester', icon: Icons.security_rounded, onTap: onTester),
          ],
        ),
      ),
    );
  }
}

class _MenuChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuChip({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ActionChip(
        onPressed: onTap,
        avatar: Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
    );
  }
}

/* ─────────────── Big Logo ─────────────── */

class _BigLogo extends StatelessWidget {
  final double diameter;
  const _BigLogo({required this.diameter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.cover,
            width: diameter * 0.9,
            height: diameter * 0.9,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.close_rounded,
              size: 100,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────── Panels & Cards ─────────────── */

class _TextPanel extends StatelessWidget {
  final double height;
  final Widget child;
  const _TextPanel({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;

    return Material(
      color: color.withOpacity(0.95),
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: onColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: onColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: onColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: onColor, fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(color: onColor.withOpacity(0.95)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: onColor),
            ],
          ),
        ),
      ),
    );
  }
}
