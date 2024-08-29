class NotificationPreferences {
  bool receivePromotions;
  bool receiveUpdates;
  bool receiveReminders;
  String frequency;

  NotificationPreferences({
    required this.receivePromotions,
    required this.receiveUpdates,
    required this.receiveReminders,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'receivePromotions': receivePromotions,
      'receiveUpdates': receiveUpdates,
      'receiveReminders': receiveReminders,
      'frequency': frequency,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      receivePromotions: map['receivePromotions'] ?? false,
      receiveUpdates: map['receiveUpdates'] ?? false,
      receiveReminders: map['receiveReminders'] ?? false,
      frequency: map['frequency'] ?? 'daily',
    );
  }
}
