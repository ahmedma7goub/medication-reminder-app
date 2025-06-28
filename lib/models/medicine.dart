class Medicine {
  int? id;
  String name;
  String dosage;
  String type; // e.g., Pill, Syrup, Injection
  int stock; // Number of pills/doses remaining
  String scheduleType; // e.g., 'daily', 'specific_days'
  List<String>? days; // e.g., ['Monday', 'Wednesday']
  List<String> times; // e.g., ['08:00', '20:00']

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.stock,
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
      'type': type,
      'stock': stock,
      'scheduleType': scheduleType,
      'days': days?.join(','),
      'times': times.join(','),
    };
  }

  // Extract a Medicine object from a Map object
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      type: map['type'],
      stock: map['stock'],
      scheduleType: map['scheduleType'],
      days: map['days'] != null ? (map['days'] as String).split(',') : null,
      times: (map['times'] as String).split(','),
    );
  }
}
