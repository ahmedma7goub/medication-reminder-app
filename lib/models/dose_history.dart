class DoseHistory {
  int? id;
  int medicineId;
  DateTime takenAt;

  DoseHistory({
    this.id,
    required this.medicineId,
    required this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'takenAt': takenAt.toIso8601String(),
    };
  }

  factory DoseHistory.fromMap(Map<String, dynamic> map) {
    return DoseHistory(
      id: map['id'],
      medicineId: map['medicineId'],
      takenAt: DateTime.parse(map['takenAt']),
    );
  }
}
