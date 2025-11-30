import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final totalMinutes = progress?.totalFocusMinutes ?? 0;
    final totalSessions = progress?.completedSessions ?? 0;
    final currentStreak = progress?.currentStreak ?? 0;
    final longestStreak = progress?.longestStreak ?? 0;

    // Format total focus time
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final focusTimeDisplay = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Stats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildStatCard(
                      'Total Focus Time',
                      focusTimeDisplay,
                      Icons.timer,
                      const Color(0xFFFF6B35),
                      key: const ValueKey('stats_focus_time'),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Sessions Completed',
                      '$totalSessions',
                      Icons.check_circle,
                      Colors.green,
                      key: const ValueKey('stats_sessions'),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Current Streak',
                      '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                      Icons.local_fire_department,
                      Colors.orange,
                      key: const ValueKey('stats_streak'),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Longest Streak',
                      '$longestStreak ${longestStreak == 1 ? 'day' : 'days'}',
                      Icons.star,
                      Colors.amber,
                      key: const ValueKey('stats_best'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
