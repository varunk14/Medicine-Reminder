import 'package:hive/hive.dart';
import '../models/medicine.dart';

class MedicineRepository {
  static const String _boxName = 'medicines';

  Box<Medicine> get _box => Hive.box<Medicine>(_boxName);

  /// Retrieves all medicines sorted by time
  List<Medicine> getAllMedicines() {
    final medicines = _box.values.toList();
    // Sort by time (hour * 60 + minute)
    medicines.sort((a, b) => a.timeInMinutes.compareTo(b.timeInMinutes));
    return medicines;
  }

  /// Retrieves a single medicine by ID
  Medicine? getMedicineById(String id) {
    try {
      return _box.values.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Adds a new medicine to the database
  Future<void> addMedicine(Medicine medicine) async {
    await _box.put(medicine.id, medicine);
  }

  /// Updates an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _box.put(medicine.id, medicine);
  }

  /// Deletes a medicine by ID
  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }

  /// Deletes all medicines
  Future<void> deleteAllMedicines() async {
    await _box.clear();
  }

  /// Gets the count of medicines
  int get medicineCount => _box.length;

  /// Checks if a medicine exists
  bool medicineExists(String id) {
    return _box.containsKey(id);
  }
}
