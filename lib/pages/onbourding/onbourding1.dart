import 'package:flutter/material.dart';

class Onbourding1 extends StatelessWidget {
  const Onbourding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/onbourding1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE3F2FD), // Fallback
              child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
            ),
          ),
          
          // Gradient Overlay so text is readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9), // Stronger opacity at top for text
                  Colors.white.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.3), // Darker at bottom for button ?? No, image has dark bottom maybe?
                  // Logic check: The reference likely has clear image. 
                  // Let's assume standard overlay isn't strictly needed if image is good, 
                  // but for readability let's keep it subtle or remove if "fit layout" is strict.
                  // User said "image match mobile frame", text at top.
                  // I'll add a safe area content wrapper.
                ],
                stops: const [0.0, 0.3, 0.5, 1.0], 
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'welcome to MindNest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2E7D32), // Dark Green
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Your personal sanctuary for mental wellness and mindfulness. Take a few minutes each day to nurture your mind.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Serif',
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Onboarding 1 -> Sign In (as requested)
                        Navigator.of(context).pushReplacementNamed('/sign_in');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2), // Blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'next',
                        style: TextStyle(
                          color: Color(0xFFFFC107), // Yellow text
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
