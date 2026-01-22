import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/medicine.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/services/notification_service.dart';

enum MedicineState { initial, loading, loaded, error }

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _repository;
  final Uuid _uuid = const Uuid();

  MedicineProvider({required MedicineRepository repository})
      : _repository = repository;

  List<Medicine> _medicines = [];
  MedicineState _state = MedicineState.initial;
  String? _errorMessage;

  // Getters
  List<Medicine> get medicines => _medicines;
  MedicineState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _medicines.isEmpty;
  int get medicineCount => _medicines.length;

  /// Load all medicines from storage
  Future<void> loadMedicines() async {
    _state = MedicineState.loading;
    notifyListeners();

    try {
      _medicines = _repository.getAllMedicines();
      _state = MedicineState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = MedicineState.error;
      _errorMessage = 'Failed to load medicines: ${e.toString()}';
      debugPrint(_errorMessage);
    }

    notifyListeners();
  }

  /// Add a new medicine
  Future<bool> addMedicine({
    required String name,
    required String dosage,
    required int hour,
    required int minute,
    List<int> selectedDays = const [],
  }) async {
    try {
      final medicine = Medicine(
        id: _uuid.v4(),
        name: name.trim(),
        dosage: dosage.trim(),
        hour: hour,
        minute: minute,
        isActive: true,
        selectedDays: selectedDays,
      );

      await _repository.addMedicine(medicine);
      await NotificationService.instance.scheduleMedicineReminder(medicine);

      // Reload to get sorted list
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add medicine: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Update an existing medicine
  Future<bool> updateMedicine(Medicine medicine) async {
    try {
      await _repository.updateMedicine(medicine);

      // Reschedule notification
      await NotificationService.instance.cancelMedicineReminder(medicine);
      if (medicine.isActive) {
        await NotificationService.instance.scheduleMedicineReminder(medicine);
      }

      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update medicine: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Delete a medicine
  Future<bool> deleteMedicine(Medicine medicine) async {
    try {
      await NotificationService.instance.cancelMedicineReminder(medicine);
      await _repository.deleteMedicine(medicine.id);
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete medicine: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Toggle medicine active state
  Future<bool> toggleMedicineActive(Medicine medicine) async {
    final updatedMedicine = medicine.copyWith(isActive: !medicine.isActive);
    return updateMedicine(updatedMedicine);
  }

  /// Delete all medicines
  Future<bool> deleteAllMedicines() async {
    try {
      await NotificationService.instance.cancelAllReminders();
      await _repository.deleteAllMedicines();
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete all medicines: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
