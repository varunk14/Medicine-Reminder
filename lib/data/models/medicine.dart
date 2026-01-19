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

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.isActive = true,
  });

  /// Creates a copy of this Medicine with the given fields replaced
  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    int? hour,
    int? minute,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Returns the time in minutes since midnight for sorting
  int get timeInMinutes => hour * 60 + minute;

  /// Generates a unique notification ID from the medicine ID
  int get notificationId => id.hashCode.abs() % 2147483647;

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, dosage: $dosage, time: $hour:$minute, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
