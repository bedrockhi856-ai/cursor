/// Message model for mentor chat
class MentorMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  
  const MentorMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });
  
  MentorMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return MentorMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

enum MessageType {
  text,
  choice,
  typing,
}

/// Choice option for multiple choice questions
class MentorChoice {
  final String id;
  final String text;
  final String? emoji;
  
  const MentorChoice({
    required this.id,
    required this.text,
    this.emoji,
  });
}

/// User assessment data collected during conversation
class UserAssessment {
  final String? focusAbility;
  final String? pastStruggles;
  final String? motivation;
  final String? distractions;
  final int? startingMinutes;
  
  const UserAssessment({
    this.focusAbility,
    this.pastStruggles,
    this.motivation,
    this.distractions,
    this.startingMinutes,
  });
  
  UserAssessment copyWith({
    String? focusAbility,
    String? pastStruggles,
    String? motivation,
    String? distractions,
    int? startingMinutes,
  }) {
    return UserAssessment(
      focusAbility: focusAbility ?? this.focusAbility,
      pastStruggles: pastStruggles ?? this.pastStruggles,
      motivation: motivation ?? this.motivation,
      distractions: distractions ?? this.distractions,
      startingMinutes: startingMinutes ?? this.startingMinutes,
    );
  }
  
  bool get isComplete => 
    focusAbility != null && 
    motivation != null && 
    startingMinutes != null;
}

/// Generated study plan
class StudyPlan {
  final List<WeekPlan> weeks;
  final String encouragement;
  
  const StudyPlan({
    required this.weeks,
    required this.encouragement,
  });
  
  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    final weeklyPlan = json['weeklyPlan'] as List<dynamic>;
    return StudyPlan(
      weeks: weeklyPlan.map((w) => WeekPlan.fromJson(w)).toList(),
      encouragement: json['encouragement'] ?? "You've got this!",
    );
  }
}

class WeekPlan {
  final int week;
  final int minutes;
  final String theme;
  
  const WeekPlan({
    required this.week,
    required this.minutes,
    required this.theme,
  });
  
  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      week: json['week'] ?? 1,
      minutes: json['minutes'] ?? 5,
      theme: json['theme'] ?? 'Focus',
    );
  }
}
