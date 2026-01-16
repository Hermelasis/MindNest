import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodEntry {
  final DateTime dateTime;
  final String emoji;
  final int score;
  final String journal;

  MoodEntry({
    required this.dateTime,
    required this.emoji,
    required this.score,
    required this.journal,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'emoji': emoji,
      'score': score,
      'journal': journal,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      emoji: json['emoji'],
      score: json['score'],
      journal: json['journal'],
    );
  }
}

class MoodService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference _getUserMoodCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to access mood entries.");
    }
    return _firestore.collection('users').doc(user.uid).collection('moods');
  }

  // Mapping emojis to scores
  // 😀(5), ☺️(4), 🙂(3), 😞(2), 😡(1)
  static const Map<String, int> emojiScores = {
    '😀': 5,
    '☺️': 4,
    '🙂': 3,
    '😞': 2,
    '😡': 1,
  };

  static Future<void> addEntry(String emoji, String journal) async {
    final collection = _getUserMoodCollection();
    
    final int score = emojiScores[emoji] ?? 3;
    final entry = MoodEntry(
      dateTime: DateTime.now(),
      emoji: emoji,
      score: score,
      journal: journal,
    );

    await collection.add(entry.toJson());
  }

  static Future<List<MoodEntry>> getEntries() async {
    final collection = _getUserMoodCollection();
    final snapshot = await collection.orderBy('dateTime', descending: true).get();
    
    return snapshot.docs.map((doc) {
      return MoodEntry.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  static Future<List<MoodEntry>> getEntriesForLast7Days() async {
    final collection = _getUserMoodCollection();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final snapshot = await collection
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .orderBy('dateTime', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      return MoodEntry.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Returns a map of Weekday (1=Mon) -> Average Score
  static Future<Map<int, double>> getWeeklyAverages() async {
    final entries = await getEntriesForLast7Days();
    final Map<int, List<int>> dayScores = {};

    for (var entry in entries) {
      final weekday = entry.dateTime.weekday;
      if (!dayScores.containsKey(weekday)) {
        dayScores[weekday] = [];
      }
      dayScores[weekday]!.add(entry.score);
    }

    final Map<int, double> averages = {};
    dayScores.forEach((key, value) {
      final avg = value.reduce((a, b) => a + b) / value.length;
      averages[key] = avg;
    });

    return averages;
  }

  static Future<double> getWeeklyAverageScore() async {
    final entries = await getEntriesForLast7Days();
    if (entries.isEmpty) return 0;
    
    final sum = entries.fold(0, (prev, e) => prev + e.score);
    return sum / entries.length;
  }

  static Future<String> getMostCommonMood() async {
    final entries = await getEntriesForLast7Days();
    if (entries.isEmpty) return '🙂';

    final Map<String, int> counts = {};
    for (var e in entries) {
      counts[e.emoji] = (counts[e.emoji] ?? 0) + 1;
    }

    var mostCommon = entries.first.emoji;
    var maxCount = 0;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostCommon = key;
      }
    });

    return mostCommon;
  }

  static String getLabelForScore(double score) {
    if (score >= 4.5) return 'Very Happy';
    if (score >= 3.5) return 'Happy';
    if (score >= 2.5) return 'Neutral';
    if (score >= 1.5) return 'Sad';
    if (score >= 1.0) return 'Angry';
    return 'Neutral';
  }

  static Future<String> generateSummary() async {
    final entries = await getEntriesForLast7Days();
    if (entries.isEmpty) {
      return "Start tracking your mood to see insights here!";
    }

    // Sort by date ascending for trend analysis
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Trend Analysis
    int rising = 0;
    int falling = 0;
    for (int i = 1; i < entries.length; i++) {
        if (entries[i].score > entries[i-1].score) {
          rising++;
        } else if (entries[i].score < entries[i-1].score) falling++;
    }

    String trendText;
    if (rising > falling) {
      trendText = "Your mood has been improving lately.";
    } else if (falling > rising) {
      trendText = "You've had a few ups and downs recently.";
    } else {
      trendText = "Your mood has been relatively stable.";
    }

    // Keyword extraction
    final keywords = ['stress', 'exam', 'family', 'tired', 'excited', 'calm', 'happy', 'sad', 'work', 'school'];
    final List<String> foundKeywords = [];
    
    for (var e in entries) {
      for (var k in keywords) {
        if (e.journal.toLowerCase().contains(k)) {
          if (!foundKeywords.contains(k)) foundKeywords.add(k);
        }
      }
    }

    String keywordText = "";
    if (foundKeywords.isNotEmpty) {
      keywordText = " Your journal mentions ${foundKeywords.join(', ')}, which might be influencing your mood.";
    }

    double avg = await getWeeklyAverageScore();
    String avgLabel = getLabelForScore(avg);

    String advice = "";
    if (avg < 3.0) {
      advice = " Consider trying some breathing exercises or 'Calm' sounds to help lift your spirits.";
    } else {
      advice = " Keep up the great work and continue prioritizing your peace!";
    }

    return "You felt mostly $avgLabel this week. $trendText$keywordText$advice";
  }
}
