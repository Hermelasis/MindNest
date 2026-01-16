import 'package:flutter/material.dart';
import '../../services/mood_services.dart';

class MoodInsightsScreen extends StatefulWidget {
  const MoodInsightsScreen({super.key});

  @override
  State<MoodInsightsScreen> createState() => _MoodInsightsScreenState();
}

class _MoodInsightsScreenState extends State<MoodInsightsScreen> {
  Map<int, double> _weeklyAverages = {};
  double _averageScore = 0;
  String _mostCommonEmoji = '🙂';
  String _summary = 'Loading insights...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final weeklyAvgs = await MoodService.getWeeklyAverages();
      final avgScore = await MoodService.getWeeklyAverageScore();
      final mostCommon = await MoodService.getMostCommonMood();
      final summary = await MoodService.generateSummary();

      if (mounted) {
        setState(() {
          _weeklyAverages = weeklyAvgs;
          _averageScore = avgScore;
          _mostCommonEmoji = mostCommon;
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summary = "Error loading insights: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Global background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
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
                      'mood insights',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_isLoading)
                const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
              else ...[
                const SizedBox(height: 16),
                
                // Chart Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.show_chart, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: const [
                                 Text(
                                  'This Week',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                               ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: _buildCustomBarChart(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Average\nMood',
                          value: _averageScore.toStringAsFixed(1),
                          subtitle: 'out of 5',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Most\nCommon',
                          content: Text(_mostCommonEmoji, style: const TextStyle(fontSize: 50)),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Emotional Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF26A69A), // Teal color
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emotional Summary',
                        style: TextStyle(
                          color:Colors.white, // Orange/Red
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                         _summary,
                         style: const TextStyle(
                           color: Colors.white,
                           fontSize: 18, 
                           height: 1.5, 
                           fontWeight: FontWeight.w500
                         ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Assuming Map keys 1..7 for Mon..Sun
    // _weeklyAverages might be sparse vs full, handled by default 0

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        // index 0 -> Mon(1), index 6 -> Sun(7)
        final weekday = index + 1;
        final val = _weeklyAverages[weekday] ?? 0.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20, 
              // Scale: Max 5. 5 -> 160 height
              height: (val / 5) * 160, 
              // Min height for visibility
              constraints: const BoxConstraints(minHeight: 4),
              decoration: BoxDecoration(
                 color: _getColorForScore(val),
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        );
      }),
    );
  }
  
  Color _getColorForScore(double score) {
      if (score >= 4.5) return Colors.green; // Very Happy
      if (score >= 3.5) return Colors.lightGreen; // Happy
      if (score >= 2.5) return Colors.amber; // Neutral
      if (score >= 1.5) return Colors.orange; // Sad
      if (score > 0) return Colors.red; // Angry
      return Colors.grey.shade300; // No Data
  }

  Widget _buildStatCard({required String title, String? value, String? subtitle, Widget? content, required Color color}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180), 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE91E63), 
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 12),
          if (content != null) content,
          if (value != null)
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
