import 'package:flutter/material.dart';

/// Types of nodes in the path
enum NodeType {
  regular,    // Star node
  chest,      // Treasure chest
  milestone,  // Numbered badge
  character,  // Duo character illustration
  trophy,     // End trophy
}

/// Section difficulty level with theme colors
class Section {
  final int id;
  final String name;
  final String description;
  final Color color;
  final String dividerText;

  const Section({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.dividerText,
  });

  // Colour / name palette that cycles when there are more than 6 months
  static const _colors = [
    Color(0xFF58CC02), // green
    Color(0xFF1CB0F6), // blue
    Color(0xFFCE82FF), // purple
    Color(0xFFFF9600), // orange
    Color(0xFFFF4B4B), // red
    Color(0xFFFFD700), // gold
  ];

  static const _phaseNames = [
    'Foundation', 'Building', 'Progress',
    'Advanced',   'Expert',   'Master',
  ];

  static const _dividerTexts = [
    'Start your journey',  'Build consistency',
    'Push further',        'Level up',
    'Elite territory',     'Final push',
  ];

  /// Build one Section for the given month number (1-based).
  static Section forMonth(int month) {
    final i = (month - 1) % _colors.length;
    return Section(
      id: month,
      name: 'Month $month',
      description: _phaseNames[i],
      color: _colors[i],
      dividerText: _dividerTexts[i],
    );
  }
}

/// Represents a single node in the progress path
class ProgressNode {
  final int id;
  final String title;
  final String emoji;
  final int durationMinutes;
  final NodeStatus status;
  final int xpReward;
  final Offset position; // Position on the path (0.0-1.0 for x and y)
  final NodeType type;
  final Section section;

  const ProgressNode({
    required this.id,
    required this.title,
    required this.emoji,
    required this.durationMinutes,
    required this.status,
    required this.xpReward,
    required this.position,
    required this.section,
    this.type = NodeType.regular,
  });

  ProgressNode copyWith({
    int? id,
    String? title,
    String? emoji,
    int? durationMinutes,
    NodeStatus? status,
    int? xpReward,
    Offset? position,
    NodeType? type,
    Section? section,
  }) {
    return ProgressNode(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      position: position ?? this.position,
      type: type ?? this.type,
      section: section ?? this.section,
    );
  }
}

/// Status of a progress node
enum NodeStatus {
  locked,    // Not yet available
  active,    // Current node to complete
  completed, // Already completed
}

/// Generates a progress path based on onboarding data
class ProgressPathGenerator {
  /// Number of nodes (days) per section (month).
  static const int nodesPerSection = 30;

  /// Generate day-by-day nodes driven by onboarding choices.
  ///
  /// * [startingMinutes]      – effective start commitment in minutes.
  ///   Set by both [StartTimeScreen] (preset) and [CustomTimeScreen] (custom),
  ///   both of which write to [User.startingCommitmentMinutes].
  /// * [ultimateGoalMinutes]  – the user's long-term goal (FutureGoalScreen).
  /// * [completedNodes]       – sessions completed so far (advances active node).
  /// * [goalSpeedMonths]      – months to reach the goal (GoalSpeedScreen, 1–6).
  ///   1 month → 30 nodes, 4 months → 120 nodes, etc.
  ///
  /// Example: start=30, goal=90, speed=1 month
  ///   → 30 nodes, Day 1 = 30 min, Day 30 = 90 min (linear ramp).
  static List<ProgressNode> generatePath({
    required int startingMinutes,
    required int ultimateGoalMinutes,
    required int completedNodes,
    double goalSpeedMonths = 4.0,
  }) {
    final totalNodes    = (goalSpeedMonths * 30).round().clamp(7, 365);
    final sections      = _buildSections(totalNodes);
    final pathPositions = _generatePathPositions(totalNodes);

    final nodes = <ProgressNode>[];
    for (int i = 0; i < totalNodes; i++) {
      // Linear ramp: Day 1 (i=0) = startingMinutes, Day N (i=totalNodes-1) = ultimateGoalMinutes
      final t    = totalNodes > 1 ? i / (totalNodes - 1) : 0.0;
      final mins = (startingMinutes + (ultimateGoalMinutes - startingMinutes) * t).round();

      NodeStatus status;
      if (i < completedNodes) {
        status = NodeStatus.completed;
      } else if (i == completedNodes) {
        status = NodeStatus.active;
      } else {
        status = NodeStatus.locked;
      }

      final sectionIdx = (i ~/ nodesPerSection).clamp(0, sections.length - 1);

      nodes.add(ProgressNode(
        id: i,
        title: 'Day ${i + 1}',
        emoji: _getNodeEmoji(i, totalNodes),
        durationMinutes: mins,
        status: status,
        xpReward: _calculateXPReward(mins),
        position: pathPositions[i],
        type: NodeType.regular,
        section: sections[sectionIdx],
      ));
    }

    return nodes;
  }

  /// Build a list of month-based sections for [totalNodes] days.
  static List<Section> _buildSections(int totalNodes) {
    final count = ((totalNodes - 1) ~/ nodesPerSection) + 1;
    return List.generate(count, (i) => Section.forMonth(i + 1));
  }
  
  /// Generate winding path positions (Duolingo S-curve zigzag)
  static List<Offset> _generatePathPositions(int count) {
    final positions = <Offset>[];

    // X offsets cycle left → centre → right → centre for a readable S-curve
    const xPattern = [0.50, 0.33, 0.50, 0.67];

    for (int i = 0; i < count; i++) {
      final y = count > 1 ? i / (count - 1) : 0.0;
      final x = xPattern[i % xPattern.length];
      positions.add(Offset(x, y));
    }

    return positions;
  }

  /// Get emoji for node based on progress through the path
  static String _getNodeEmoji(int index, int total) {
    final progress = index / total;
    
    if (progress < 0.2) return '🌱';
    if (progress < 0.4) return '🔥';
    if (progress < 0.6) return '⚡';
    if (progress < 0.8) return '💪';
    return '👑';
  }
  
  /// Calculate XP reward based on duration
  static int _calculateXPReward(int minutes) {
    return (minutes * 2.5).round(); // 2.5 XP per minute
  }
}
