import 'package:flutter/material.dart';
import '../../services/mood_services.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  List<MoodEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await MoodService.getEntries();
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reflections: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0 && date.day == now.day) {
      return 'Today';
    } else if (diff == 1 || (diff == 0 && date.day != now.day)) {
      return 'Yesterday';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[date.weekday - 1]} - $diff days ago';
    }
  }

  String _getLabelForMood(String emoji) {
    switch (emoji) {
      case '😞': return 'Sad';
      case '😡': return 'Angry';
      case '🙂': return 'Normal';
      case '☺️': return 'Steady';
      case '😀': return 'Happy';
      default: return 'Neutral';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_left_outlined, size: 36, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Reflections',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _entries.isEmpty
                      ? const Center(child: Text("No entries yet. Start journaling!"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return _buildReflectionCard(entry);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(MoodEntry entry) {
    final label = _getLabelForMood(entry.emoji);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReflectionDetailScreen(entry: entry),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                entry.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(entry.dateTime),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.journal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ReflectionDetailScreen extends StatelessWidget {
  final MoodEntry entry;

  const ReflectionDetailScreen({super.key, required this.entry});

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    
    return "$dayName, $monthName ${date.day} ${date.year} at ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {
    String label = 'Neutral';
    switch (entry.emoji) {
      case '😞': label = 'Sad'; break;
      case '😡': label = 'Angry'; break;
      case '🙂': label = 'Normal'; break;
      case '☺️': label = 'Steady'; break;
      case '😀': label = 'Happy'; break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(
                 child: Column(
                   children: [
                      Text(
                        entry.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatFullDate(entry.dateTime),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                   ],
                 ),
               ),
               const SizedBox(height: 32),
               const Text(
                 "Journal Entry",
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: Colors.black87,
                 ),
               ),
               const SizedBox(height: 16),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey.shade200),
                 ),
                 child: Text(
                   entry.journal.isEmpty ? "No journal text for this entry." : entry.journal,
                   style: const TextStyle(
                     fontSize: 16,
                     height: 1.6,
                     color: Colors.black87,
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
