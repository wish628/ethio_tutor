import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';

/// Achievement badge widget with locked/unlocked states
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked
                        ? const LinearGradient(
                            colors: [
                              AppColors.achievementGold,
                              Color(0xFFFFF4A3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUnlocked ? null : AppColors.achievementLocked,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: AppColors.achievementGold.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                
                // Icon
                Icon(
                  _getIconForCategory(achievement.category),
                  size: 30,
                  color: isUnlocked ? Colors.white : Colors.grey[400],
                ),
                
                // Shimmer effect for unlocked badges
                if (isUnlocked)
                  Shimmer.fromColors(
                    baseColor: Colors.transparent,
                    highlightColor: Colors.white.withOpacity(0.3),
                    period: const Duration(milliseconds: 2000),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Title
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.textPrimary : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.lessons:
        return Icons.school;
      case AchievementCategory.streaks:
        return Icons.local_fire_department;
      case AchievementCategory.accuracy:
        return Icons.stars;
      case AchievementCategory.vocabulary:
        return Icons.book;
      case AchievementCategory.practice:
        return Icons.timer;
    }
  }
}
