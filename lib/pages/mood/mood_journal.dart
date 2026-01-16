import 'package:flutter/material.dart';
import '../../services/mood_services.dart';
import 'reflection_page.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  String? _selectedEmoji;
  final TextEditingController _journalController = TextEditingController();

  final List<String> _emojis = ['😞', '😡', '🙂', '☺️', '😀'];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_selectedEmoji == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood emoji')),
      );
      return;
    }

    try {
      await MoodService.addEntry(
        _selectedEmoji!,
        _journalController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood entry saved!')),
        );
        setState(() {
          _selectedEmoji = null;
          _journalController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Global background color applies
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_circle_left_outlined,
                            size: 36, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(width: 8),
                    const Text(
                      'MOOD JOURNAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.history,
                            size: 32, color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReflectionPage(),
                            ),
                          );
                        }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'HOW ARE YOU FEELING? TAKE A MOMENT\nTO REFLECT ON YOUR EMOTIONS.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 24),

                // Mood Selector
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'select your mood',
                        style: TextStyle(
                          color: Color(0xFF1976D2), // Blue
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _emojis.map((emoji) => _buildMoodEmoji(emoji)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Daily Reflection
                const Text(
                  'Daily Reflection',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E97FD).withOpacity(0.8), // Muted purple
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _journalController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'share your thoughts here...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2), // Medium blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'save entry',
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFFCDDC39), // Lime green/yellow text
                        fontFamily: 'Serif',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // See Reflection Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReflectionPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      // backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF1976D2), width: 2),
                      ),
                    ),
                    child: const Text(
                      'see reflection',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1976D2),
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
      ),
    );
  }

  Widget _buildMoodEmoji(String emoji) {
    final isSelected = _selectedEmoji == emoji;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmoji = emoji;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isSelected ? 48 : 36),
        ),
      ),
    );
  }
}
