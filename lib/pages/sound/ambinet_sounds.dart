import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AmbientSoundsScreen extends StatefulWidget {
  const AmbientSoundsScreen({super.key});

  @override
  State<AmbientSoundsScreen> createState() => _AmbientSoundsScreenState();
}

class _AmbientSoundsScreenState extends State<AmbientSoundsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingCode; // Tracks which sound code is playing
  bool _isPlaying = false;

  final List<Map<String, String>> _sounds = [
    {
      'name': 'Calm Voice 1',
      'file': 'voice1.mp3',
      'code': 'voice1',
    },
    {
      'name': 'Calm Voice 2',
      'file': 'voice2.mp3',
      'code': 'voice2',
    },
    {
      'name': 'Calm Voice 3',
      'file': 'voice3.mp3',
      'code': 'voice3',
    },
    {
      'name': 'Calm Voice 4',
      'file': 'voice4.mp3',
      'code': 'voice4',
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
        // Use AssetSource for local assets
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
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_left_outlined, size: 36, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ambient Sounds',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select calming sounds to help\nyou focus, relax, or sleep.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sounds List
              Expanded(
                child: ListView.separated(
                  itemCount: _sounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final sound = _sounds[index];
                    final isThisPlaying = _currentlyPlayingCode == sound['code'] && _isPlaying;

                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF558B60), // Green color similar to mock
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
                                color: Colors.black,
                                fontFamily: 'Unknown', // Using default sans-serif bold as per image
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _toggleSound(sound['code']!, sound['file']!),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2), // Blue button
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
