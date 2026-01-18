import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String pick(List<String> responses) {
  final rand = Random();
  return responses[rand.nextInt(responses.length)];
}

class HomeDashbourd extends StatefulWidget {
  const HomeDashbourd({super.key});

  @override
  State<HomeDashbourd> createState() => _HomeDashbourdState();
}

class _HomeDashbourdState extends State<HomeDashbourd> {
  final List<Map<String, String>> _quotes = [
    {'text': 'You deserve every bit of happiness today.', 'emoji': '☀️'},
    {
      'text': 'Be gentle with yourself — you are doing your best.',
      'emoji': '🌸',
    },
    {'text': 'Your heart deserves peace.', 'emoji': '🕊️'},
    {'text': 'Small steps still move you forward.', 'emoji': '✨'},
    {'text': 'You are allowed to rest without guilt.', 'emoji': '🤗'},
    {'text': 'Even quiet progress is progress.', 'emoji': '💫'},
    {'text': 'Your feelings are valid.', 'emoji': '💞'},
    {'text': 'Today is a fresh beginning.', 'emoji': '🌄'},
    {'text': 'Your mind is worthy of calm.', 'emoji': '🌊'},
    {'text': 'Breathe… you are safe right now.', 'emoji': '😌'},
  ];

  late int _currentQuoteIndex;
  Timer? _timer;

  // New State Variables
  final AudioPlayer _player = AudioPlayer();
  bool _sosMode = false;
  int _streak = 0;
  String _lastDay = "";
  int _selectedIndex = 0;

  // Chat State
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'text': 'Hello. How is your heart feeling today?'},
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentQuoteIndex = Random().nextInt(_quotes.length);
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streak = prefs.getInt('streak') ?? 0;
      _lastDay = prefs.getString('lastDay') ?? '';
    });
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    if (_lastDay != today) {
      setState(() {
        _streak++;
        _lastDay = today;
      });
      await prefs.setInt('streak', _streak);
      await prefs.setString('lastDay', _lastDay);
    }
  }

  void _onItemTapped(int index) {
    // 0: Home
    // 1: Wellness
    // 2: SOS Calm
    // 3: Guide
    // 4: Streak

    if (index == 0) {
      // Home
      if (_sosMode) {
        _player.stop();
        setState(() {
          _sosMode = false;
        });
      }
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Wellness
      if (_sosMode) {
        _player.stop();
        setState(() => _sosMode = false);
      }
      setState(() {
        _selectedIndex = 1;
      });
    } else if (index == 2) {
      // SOS Calm
      setState(() {
        _sosMode = true;
        _selectedIndex = 2;
      });
      _player.play(AssetSource('audio/voice3.mp3'));
      _updateStreak();
    } else if (index == 3) {
      // Guide (Chat)
      if (_sosMode) {
        _player.stop();
        setState(() => _sosMode = false);
      }
      setState(() {
        _selectedIndex = 3;
      });
    } else if (index == 4) {
      // Streak (Action)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🔥 You are on a $_streak day calm streak!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Do not change index
    }
  }

  void _handleSendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _chatController.clear();
    });

    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Bot Response Logic
    String response;
    final lower = text.toLowerCase();

    // � CRISIS — ALWAYS FIRST
    if (lower.contains('kill') ||
        lower.contains('killed') ||
        lower.contains('die') ||
        lower.contains('suicide') ||
        lower.contains('end my life') ||
        lower.contains('want to die')) {
      response = pick([
        "I’m really sorry you’re feeling this much pain. You don’t have to go through this alone. Please reach out to someone you trust or a health professional right now.",
        "I’m really glad you told me this. You deserve help and care. Please talk to someone close to you or a professional immediately.",
        "This sounds very serious, and your life matters. Please seek immediate help from someone you trust or a healthcare provider."
      ]);
    }
    // 😔 BAD / AWFUL / SAD
    else if (lower.contains('bad') ||
        lower.contains('awful') ||
        lower.contains('sad') ||
        lower.contains('terrible') ||
        lower.contains('horrible') ||
        lower.contains('down')) {
      response = pick([
        "I’m really sorry you’re feeling this way. It’s okay to have hard days.",
        "That sounds heavy. You’re not weak for feeling like this.",
        "Bad moments don’t define you. Let’s take this one breath at a time.",
        "I hear you. Even when things feel awful, they can change."
      ]);
    }
    // 😰 ANXIOUS / WORRIED
    else if (lower.contains('anxious') ||
        lower.contains('anxiety') ||
        lower.contains('worried') ||
        lower.contains('nervous') ||
        lower.contains('scared')) {
      response = pick([
        "It sounds like your thoughts are racing. Let’s slow them down together.",
        "Anxiety can feel overwhelming. Try taking one slow breath right now.",
        "You’re safe in this moment. Focus on your breathing for a few seconds.",
        "Let’s gently calm your nervous system with a slow breath."
      ]);
    }
    // � TIRED / EXHAUSTED
    else if (lower.contains('tired') ||
        lower.contains('exhausted') ||
        lower.contains('sleepy') ||
        lower.contains('burned out') ||
        lower.contains('drained')) {
      response = pick([
        "Your body sounds tired. Even a short rest can help.",
        "You’ve been carrying a lot. A small pause might feel good right now.",
        "Being tired is your body asking for care.",
        "Let’s slow things down and give yourself a moment."
      ]);
    }
    // 😡 ANGRY / FRUSTRATED
    else if (lower.contains('angry') ||
        lower.contains('mad') ||
        lower.contains('frustrated') ||
        lower.contains('annoyed')) {
      response = pick([
        "Strong emotions can build up inside. Let’s release some of that tension.",
        "Anger often means something matters to you. Take a slow breath.",
        "It’s okay to feel angry. Let’s calm the body first.",
        "Let that tension soften with a deep breath."
      ]);
    }
    // 😕 CONFUSED / LOST
    else if (lower.contains('confused') ||
        lower.contains('lost') ||
        lower.contains('don’t know') ||
        lower.contains('unsure')) {
      response = pick([
        "It’s okay not to have answers right now.",
        "Feeling unsure is part of being human.",
        "Let’s focus on one calm moment instead of everything.",
        "You don’t need clarity right now — just calm."
      ]);
    }
    // 😊 GOOD / HAPPY / NICE
    else if (lower.contains('good') ||
        lower.contains('happy') ||
        lower.contains('fine') ||
        lower.contains('okay') ||
        lower.contains('nice')) {
      response = pick([
        "I’m really glad you’re feeling okay. Let’s protect that calm today.",
        "That’s good to hear. Stay gentle with yourself.",
        "Nice moments matter. Take a breath and enjoy it.",
        "I’m happy you’re feeling better right now."
      ]);
    }
    // 👋 GREETINGS
    else if (lower.contains('hi') ||
        lower.contains('hello') ||
        lower.contains('hey')) {
      response = pick([
        "Hello. I’m here with you.",
        "Hi there. How are you feeling right now?",
        "Hey. You can tell me what’s on your mind.",
        "I’m here. How is your heart feeling today?"
      ]);
    }
    // 🌱 DEFAULT
    else {
      response = pick([
        "Thank you for sharing. Would you like a short breathing moment?",
        "I’m listening. Tell me a little more if you want.",
        "I’m here with you. How does your body feel right now?",
        "Would a calm breathing moment help right now?"
      ]);
    }

    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'bot', 'text': response});
        });
        // Check if attached to prevent error if user navigated away
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _quickTile(
    BuildContext context, {
    required String label,
    required String emoji,
    required String routeName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(routeName),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.indigo.withOpacity(0.2) // Darker lavender for dark mode
              : const Color(
                  0xFFC5CAE9,
                ).withOpacity(0.5), // Lavender blue background
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Serif',
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(bool isDark, Color onSurface) {
    final currentQuote = _quotes[_currentQuoteIndex];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Serif',
                      color: isDark
                          ? const Color(0xFF81C784)
                          : Colors.black, // Soft green in dark mode
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/settings'),
                  icon: Icon(
                    Icons.settings,
                    size: 30,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Catchy Title
            Text(
              'HOW ARE YOU\nFEELING TODAY?',
              style: TextStyle(
                fontSize: 40,
                height: 1.1,
                fontWeight: FontWeight.w400,
                fontFamily: 'Serif',
                color: onSurface,
              ),
            ),

            const SizedBox(height: 32),

            // Mood Quote Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.pink.withOpacity(0.1)
                    : const Color(0xFFFAF0F1), // Very light pink
                borderRadius: BorderRadius.circular(8),
                border: isDark
                    ? Border.all(color: Colors.pink.withOpacity(0.2))
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    currentQuote['emoji']!,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQuote['text']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Serif',
                fontStyle: FontStyle.italic,
                color: isDark
                    ? const Color(0xFF4CAF50)
                    : Colors.black, // Dark green accent
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _quickTile(
                  context,
                  label: 'mindfulness',
                  emoji: '💥',
                  routeName: '/mindfulness',
                ),
                _quickTile(
                  context,
                  label: 'breathing',
                  emoji: '❤️',
                  routeName: '/breathing',
                ),
                _quickTile(
                  context,
                  label: 'journal',
                  emoji: '✍️',
                  routeName: '/journal',
                ),
                _quickTile(
                  context,
                  label: 'sound',
                  emoji: '🎶',
                  routeName: '/sound',
                ),
                _quickTile(
                  context,
                  label: 'calm down',
                  emoji: '🧘',
                  routeName: '/calm',
                ),
                _quickTile(
                  context,
                  label: 'insights',
                  emoji: '💫',
                  routeName: '/insights',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sleep Mode Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/sleep'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'sleep mode',
                  style: TextStyle(
                    color: Color(0xFFBFF23B), // Lime accent
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.95), // Full screen dark container
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, color: Colors.white, size: 80),
            const SizedBox(height: 24),
            const Text(
              "Breathe Slowly…",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontFamily: 'Serif',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () => _onItemTapped(0), // return to home
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                foregroundColor: Colors.white,
              ),
              child: const Text("I'm Feeling Better"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "MindNest Guide",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark
                              ? Colors.indigoAccent.withOpacity(0.2)
                              : const Color(0xFFE8EAF6))
                        : (isDark ? Colors.grey[800] : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isUser
                          ? const Radius.circular(12)
                          : Radius.zero,
                      bottomRight: isUser
                          ? Radius.zero
                          : const Radius.circular(12),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B263B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Type how you feel...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: isDark ? Colors.indigoAccent : Colors.indigo,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _handleSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessGuide(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wellness Guide",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildWellnessCard(
            isDark,
            title: "Eating for Calm",
            icon: Icons.restaurant,
            color: Colors.lightGreen,
            items: [
              "Drink water often",
              "Eat fruits and vegetables",
              "Avoid too much sugar at night",
            ],
          ),
          const SizedBox(height: 16),
          _buildWellnessCard(
            isDark,
            title: "Healthy Routine",
            icon: Icons.schedule,
            color: Colors.orangeAccent,
            items: [
              "Sleep at the same time daily",
              "Start morning without phone",
              "Walk at least 10 minutes",
            ],
          ),
          const SizedBox(height: 16),
          _buildWellnessCard(
            isDark,
            title: "Mind Care",
            icon: Icons.psychology,
            color: Colors.lightBlue,
            items: [
              "Take 1-minute breathing breaks",
              "Write thoughts when stressed",
              "Be patient with yourself",
            ],
          ),
          const SizedBox(height: 16),
          _buildWellnessCard(
            isDark,
            title: "Night Reset",
            icon: Icons.nights_stay,
            color: Colors.indigoAccent,
            items: [
              "Dim lights before bed",
              "No screen 30 minutes before sleep",
              "Calm breathing audio",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessCard(
    bool isDark, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Serif',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "•",
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            if (_selectedIndex == 1)
              _buildWellnessGuide(isDark)
            else if (_selectedIndex == 3)
              _buildChatInterface(isDark)
            else
              _buildHomeContent(isDark, onSurface),

            // SOS Overlay (On Top if active)
            if (_sosMode) Positioned.fill(child: _buildSOSOverlay()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedItemColor: isDark ? Colors.white : Colors.indigo,
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? const Color(0xFF1B263B) : Colors.white,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'SOS Calm'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Streak',
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'GOOD MORNING, THERE';
    } else if (hour < 17) {
      return 'GOOD AFTERNOON, THERE';
    } else {
      return 'GOOD EVENING, THERE';
    }
  }
}
