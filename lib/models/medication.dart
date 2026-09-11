class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final String notes;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'reminderTimes': reminderTimes.join(','),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Medication.fromDbMap(Map<String, dynamic> map) => Medication(
        id: map['id'],
        name: map['name'],
        dosage: map['dosage'],
        frequency: map['frequency'],
        reminderTimes: (map['reminderTimes'] as String).isEmpty
            ? []
            : (map['reminderTimes'] as String).split(','),
        notes: map['notes'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
      );

  Medication copyWith({
    String? name,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    String? notes,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
