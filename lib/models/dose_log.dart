class DoseLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime timestamp;
  final String status;

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isTaken => status == 'taken';
  bool get isMissed => status == 'missed';

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory DoseLog.fromDbMap(Map<String, dynamic> map) => DoseLog(
        id: map['id'],
        medicationId: map['medicationId'],
        medicationName: map['medicationName'],
        timestamp: DateTime.parse(map['timestamp']),
        status: map['status'],
      );
}
