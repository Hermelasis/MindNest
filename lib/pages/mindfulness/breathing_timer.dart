import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/storage_service.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingTimerScreen extends StatefulWidget {
  const BreathingTimerScreen({super.key});

  @override
  State<BreathingTimerScreen> createState() => _BreathingTimerScreenState();
}

class _BreathingTimerScreenState extends State<BreathingTimerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isActive = false;
  BreathPhase _currentPhase = BreathPhase.inhale;
  int _counter = 4;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final storageService = StorageService();
      final url = await storageService.getDownloadURL('videos/breathing_bg.mp4');
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isActive) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isActive = true;
      _currentPhase = BreathPhase.inhale;
      _counter = 4;
    });
    _videoController?.play();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_counter > 1) {
          _counter--;
        } else {
          // Phase shift
          switch (_currentPhase) {
            case BreathPhase.inhale:
              _currentPhase = BreathPhase.hold;
              _counter = 3;
              break;
            case BreathPhase.hold:
              _currentPhase = BreathPhase.exhale;
              _counter = 4;
              break;
            case BreathPhase.exhale:
              _currentPhase = BreathPhase.inhale;
              _counter = 4;
              break;
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _videoController?.pause();
    setState(() {
      _isActive = false;
      _currentPhase = BreathPhase.inhale;
      _counter = 4;
    });
  }

  Color _getPhaseColor() {
    if (!_isActive) return const Color(0xFF7B72C2);
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return const Color(0xFFB39DDB); // Light Purple
      case BreathPhase.hold:
        return const Color(0xFF4DD0E1); // Cyan
      case BreathPhase.exhale:
        return const Color(0xFFE040FB); // Magenta
    }
  }

  String _getPhaseText() {
    if (!_isActive) return "ready?";
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return "breath in";
      case BreathPhase.hold:
        return "hold";
      case BreathPhase.exhale:
        return "breath out";
    }
  }

  String _getGuidanceText() {
    if (!_isActive) {
      return "Follow the breathing pattern to calm your mind and reduce stress.";
    }
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return "Gently fill your lungs. Imagine fresh energy entering your body.";
      case BreathPhase.hold:
        return "Pause here… feel the calm spreading through you.";
      case BreathPhase.exhale:
        return "Release everything that feels heavy.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'breathing exercise',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Serif',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Circle Indicator with Video Background
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: _getPhaseColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getPhaseColor().withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  if (_isVideoInitialized && _videoController != null)
                    ClipOval(
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: Opacity(
                          opacity: 0.6,
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getPhaseText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4)
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_counter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Serif',
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Dynamic Guidance Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _getGuidanceText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Serif',
                  ),
                ),
              ),

              const Spacer(),

              // Start/End Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _isActive ? 'end' : 'start',
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 24,
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
    );
  }
}
