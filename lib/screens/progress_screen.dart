import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/progress_ring.dart';
import '../theme/app_colors.dart';

/// Progress dashboard screen
class ProgressScreen extends StatefulWidget {
  final ProgressService progressService;

  const ProgressScreen({super.key, required this.progressService});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProgress? _progress;
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    
    final progress = await widget.progressService.getProgress();
    final unlocked = await widget.progressService.getUnlockedAchievements();
    final locked = await widget.progressService.getLockedAchievements();
    
    setState(() {
      _progress = progress;
      _unlockedAchievements = unlocked;
      _lockedAchievements = locked;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Progress', style: GoogleFonts.notoSansEthiopic()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats overview cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Lessons',
                      _progress!.lessonsCompleted.toString(),
                      Icons.school,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Current Streak',
                      '${_progress!.currentStreak} days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Practice Time',
                      '${_progress!.totalPracticeMinutes} min',
                      Icons.timer,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Accuracy',
                      '${(_progress!.averageAccuracy).toStringAsFixed(1)}%',
                      Icons.trending_up,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Streak visualization
              Text(
                'Streak History',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_progress!.currentStreak}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'days',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ProgressRing(
                            progress: _progress!.currentStreak > 0
                                ? (_progress!.currentStreak / 30).clamp(0, 1)
                                : 0,
                            size: 80,
                            child: Text(
                              'Goal\n30',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Best Streak',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            '${_progress!.bestStreak} days',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Language progress
              if (_progress!.languageProgress.isNotEmpty) ...[
                Text(
                  'Language Progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ..._progress!.languageProgress.entries.map((entry) {
                  final langName = entry.key == 'am' ? 'Amharic' : 'Oromo';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (entry.value / 50).clamp(0, 1),
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value} lessons',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Achievements
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${_unlockedAchievements.length} of ${Achievements.all.length} unlocked',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Unlocked achievements
              if (_unlockedAchievements.isNotEmpty) ...[
                const Text(
                  'Unlocked',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _unlockedAchievements.map((achievement) {
                    return AchievementBadge(
                      achievement: achievement,
                      isUnlocked: true,
                      onTap: () => _showAchievementDetails(achievement, true),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Locked achievements
              if (_lockedAchievements.isNotEmpty) ...[
                const Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _lockedAchievements.map((achievement) {
                    return AchievementBadge(
                      achievement: achievement,
                      isUnlocked: false,
                      onTap: () => _showAchievementDetails(achievement, false),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked ? Icons.emoji_events : Icons.lock,
                size: 64,
                color: isUnlocked ? AppColors.achievementGold : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!isUnlocked)
                Text(
                  'Required: ${achievement.requiredValue}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
