import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CalmExercisesScreen extends StatefulWidget {
  const CalmExercisesScreen({super.key});

  @override
  State<CalmExercisesScreen> createState() => _CalmExercisesScreenState();
}

class _CalmExercisesScreenState extends State<CalmExercisesScreen> {
  VideoPlayerController? _controller;
  String? _currentlyPlayingCode;
  bool _isPlaying = false;

  final List<Map<String, String>> _exercises = [
    {
      'name': 'Natural Yoga',
      'description': 'Release tension from head to toe',
      'duration': '10 min',
      'file': 'video1.mp4',
      'code': 'yoga_natural',
    },
    {
      'name': 'Morning Yoga',
      'description': 'Start your day with gentle flow',
      'duration': '10 min',
      'file': 'video2.mp4',
      'code': 'yoga_morning',
    },
    {
      'name': 'Night Yoga',
      'description': 'Prepare your body for restful sleep',
      'duration': '10 min',
      'file': 'video1.mp4',
      'code': 'yoga_night',
    },
    {
      'name': 'Stress Release',
      'description': 'Focus on breathing and stretching',
      'duration': '10 min',
      'file': 'video2.mp4',
      'code': 'stress_release',
    },
  ];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleVideo(String code, String fileName) async {
    if (_currentlyPlayingCode == code && _controller != null) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
        setState(() => _isPlaying = false);
      } else {
        await _controller!.play();
        setState(() => _isPlaying = true);
      }
      return;
    }

    // Stop and dispose old controller
    await _controller?.dispose();
    setState(() {
      _controller = null;
      _currentlyPlayingCode = code;
      _isPlaying = false;
    });

    try {
      final controller = VideoPlayerController.asset('assets/Video/$fileName');
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      
      if (mounted) {
        setState(() {
          _controller = controller;
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_left_outlined, size: 36, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'calm down',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Video Player Section (Centered and Big)
            if (_controller != null && _controller!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _exercises.firstWhere((e) => e['code'] == _currentlyPlayingCode)['name']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _exercises.firstWhere((e) => e['code'] == _currentlyPlayingCode)['description']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_controller!.value.isPlaying) {
                          await _controller!.pause();
                          setState(() => _isPlaying = false);
                        } else {
                          await _controller!.play();
                          setState(() => _isPlaying = true);
                        }
                      },
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  'Choose a guided exercise to center your mind and find peace.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                    fontFamily: 'Serif',
                  ),
                ),
              ),

            // Exercises List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final isThisPlaying = _currentlyPlayingCode == exercise['code'];

                  return InkWell(
                    onTap: () => _toggleVideo(exercise['code']!, exercise['file']!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isThisPlaying ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isThisPlaying ? Colors.blue : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/onbourding1.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  exercise['duration']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isThisPlaying)
                            const Icon(Icons.graphic_eq, color: Colors.blue)
                          else
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
