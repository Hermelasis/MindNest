import 'package:flutter/material.dart';

class Onbourding2 extends StatelessWidget {
  const Onbourding2({super.key});

  Widget _bullet(String text, String emoji) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Serif',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'MindNest',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 28, // Increased size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Every thing you need',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Serif',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Guided exercises, breathing timers, mood tracking, calming sounds, and sleep support - all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.black54,
                  height: 1.5,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 32),

              _bullet('Mindfulness exercises', '🧘'),
              _bullet('Mood journaling', '💭'),
              _bullet('Ambient sounds', '🎵'),
              _bullet('Sleep mode', '😴'),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/onbourding3');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'next',
                      style: TextStyle(
                        color: Color(0xFFFFC107), // Yellow text
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
