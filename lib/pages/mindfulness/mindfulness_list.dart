import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MindfulnessList extends StatefulWidget {
  const MindfulnessList({super.key});

  @override
  State<MindfulnessList> createState() => _MindfulnessListState();
}

class _MindfulnessListState extends State<MindfulnessList> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  Duration? _currentDuration;
  final Map<String, Duration> _durations = {};

  final List<Map<String, String>> _items = [
    {
      'id': 'body_scan',
      'title': 'Body Scan Meditation',
      'subtitle': 'Release tension from head to toe',
      'asset': 'mindfulnessadvice.mp3',
    },
    {
      'id': 'loving_kindness',
      'title': 'Loving Kindness',
      'subtitle': 'Release tension from head to toe',
      'asset': 'mindfulnessadvice.mp3',
    },
    {
      'id': 'mindful_walking',
      'title': 'Mindful Walking',
      'subtitle': 'Release tension from head to toe',
      'asset': 'mindfulnessadvice.mp3',
    },
    {
      'id': 'gratitude',
      'title': 'Gratitude Practice',
      'subtitle': 'Release tension from head to toe',
      'asset': 'mindfulnessadvice.mp3',
    },
    {
      'id': 'stress_release',
      'title': 'Stress Release',
      'subtitle': 'Release tension from head to toe',
      'asset': 'mindfulnessadvice.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      setState(() {
        _currentDuration = d;
        if (_playingId != null) {
          _durations[_playingId!] = d;
        }
      });
    });
    _player.onPlayerComplete.listen((_) {
      setState(() {
        _playingId = null;
        _currentDuration = null;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAsset(String id, String fileName) async {
    try {
      // stop previous
      await _player.stop();
      setState(() {
        _playingId = id;
        _currentDuration = null;
      });

      // Use AssetSource for local assets
      await _player.play(AssetSource('audio/$fileName'));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to play audio: $e')));
      setState(() {
        _playingId = null;
        _currentDuration = null;
      });
    }
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0) return '$m min';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Mindfulness',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Text(
                  'Choose a guided exercise to center your mind and find peace',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Items List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _items.map((item) {
                    final id = item['id']!;
                    final title = item['title']!;
                    final subtitle = item['subtitle']!;
                    final asset = item['asset']!;
                    final isPlaying = _playingId == id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.blue.withOpacity(0.15) 
                          : const Color(0xFFE1F5FE), // Lighter blue
                        borderRadius: BorderRadius.circular(20),
                        border: isDark 
                          ? Border.all(color: Colors.blue.withOpacity(0.2)) 
                          : null,
                      ),
                      child: Row(
                        children: [
                          // Play Button
                          GestureDetector(
                            onTap: () async {
                              if (isPlaying) {
                                await _player.pause();
                                setState(() => _playingId = null);
                              } else {
                                await _playAsset(id, asset);
                              }
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF448AFF),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                if (isPlaying && _currentDuration != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Playing: ${_formatDuration(_currentDuration)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          
                          // Time
                          const Text(
                            '10 min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                              fontFamily: 'Serif',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
