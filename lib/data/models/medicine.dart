import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final int hour;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  final bool isActive;

  /// Days of the week when reminder should trigger.
  /// Empty list means daily (all days).
  /// Values: 1=Monday, 2=Tuesday, ..., 7=Sunday (DateTime.weekday format)
  @HiveField(6)
  final List<int> selectedDays;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.isActive = true,
    this.selectedDays = const [],
  });

  /// Creates a copy of this Medicine with the given fields replaced
  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    int? hour,
    int? minute,
    bool? isActive,
    List<int>? selectedDays,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  /// Returns true if this is a daily reminder (no specific days selected)
  bool get isDaily => selectedDays.isEmpty;

  /// Returns formatted string of selected days (e.g., "Sun", "Mon, Wed, Fri")
  String get selectedDaysText {
    if (isDaily) return 'Daily';
    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(selectedDays)..sort();
    return sortedDays.map((d) => dayNames[d]).join(', ');
  }

  /// Returns the time in minutes since midnight for sorting
  int get timeInMinutes => hour * 60 + minute;

  /// Generates a unique notification ID from the medicine ID
  int get notificationId => id.hashCode.abs() % 2147483647;

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, dosage: $dosage, time: $hour:$minute, active: $isActive, days: $selectedDaysText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
