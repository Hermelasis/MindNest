import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingCode;
  bool _isPlaying = false;

  // Re-using sounds but with specific context if needed. 
  // Assuming same files as Ambient Sounds for now as per plan.
  final List<Map<String, String>> _sounds = [
    {
      'name': 'Sleep Voice 1',
      'file': 'voice1.mp3',
      'code': 'voice1',
    },
    {
      'name': 'Sleep Voice 2',
      'file': 'voice2.mp3',
      'code': 'voice2',
    },
    {
      'name': 'Sleep Voice 3',
      'file': 'voice3.mp3',
      'code': 'voice3',
    },
    {
      'name': 'Sleep Voice 4',
      'file': 'voice4.mp3',
      'code': 'voice4',
    },
    {
      'name': 'Sleep Voice 5',
      'file': 'voice5.mp3',
      'code': 'voice5',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(String code, String fileName) async {
    if (_currentlyPlayingCode == code && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentlyPlayingCode != code) {
        await _audioPlayer.stop();
      }

      try {
        await _audioPlayer.play(AssetSource('audio/$fileName'));
        setState(() {
          _currentlyPlayingCode = code;
          _isPlaying = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing sound: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4044C9), // Deep Bluish Purple matching the image
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_left_outlined, size: 36, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'sleep mode',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                            color: Colors.black, // Main title black
                          ),
                        ),
                        Text(
                          '"A well-spent day brings happy sleep."',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Serif',
                            color: Colors.black, // Quote black
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
          
                // Sound List
                ..._sounds.map((sound) {
                  final isThisPlaying = _currentlyPlayingCode == sound['code'] && _isPlaying;
                  return Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142918), // Very dark green/black
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sound['name']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Text is black in the image, surprisingly legible on dark green? 
                              // Actually looking at image, "Rain Sounds" is black.
                              fontFamily: 'Unknown', 
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _toggleSound(sound['code']!, sound['file']!),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3), // Bright Blue Button
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isThisPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isThisPlaying ? 'Pause' : 'Play',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          
                const SizedBox(height: 16),
          
                // Sleep Tips
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C6BC0), // Lighter purple/blue overlay
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Sleep Tips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'zZ',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Keep your bedroom cool and dark'),
                      _buildTip('Avoid screens 30 minutes before bed'),
                      _buildTip('Try deep breathing to relax your body'),
                      _buildTip('Maintain a consistent sleep schedule'),
                    ],
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

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• • ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Serif',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
