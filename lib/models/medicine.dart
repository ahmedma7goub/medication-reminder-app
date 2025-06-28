class Medicine {
  int? id;
  String name;
  String dosage;
  String scheduleType; // e.g., 'daily', 'specific_days'
  List<String>? days; // e.g., ['Monday', 'Wednesday']
  List<String> times; // e.g., ['08:00', '20:00']

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.scheduleType,
    this.days,
    required this.times,
  });

  // Convert a Medicine object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'scheduleType': scheduleType,
      'days': days?.join(','), // Store list as comma-separated string
      'times': times.join(','), // Store list as comma-separated string
    };
  }

  // Extract a Medicine object from a Map object
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      scheduleType: map['scheduleType'],
      days: map['days']?.split(','),
      times: map['times'].split(','),
    );
  }
}
