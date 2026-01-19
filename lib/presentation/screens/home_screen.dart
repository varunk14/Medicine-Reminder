import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/medicine_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/medicine_card.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        actions: [
          Consumer<MedicineProvider>(
            builder: (context, provider, _) {
              if (provider.medicines.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Delete all',
                  onPressed: () => _showDeleteAllConfirmation(context, provider),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case MedicineState.loading:
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );

            case MedicineState.error:
              return _buildErrorState(context, provider);

            case MedicineState.initial:
            case MedicineState.loaded:
              if (provider.isEmpty) {
                return const EmptyState();
              }
              return _buildMedicineList(context, provider);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMedicine(context),
        tooltip: 'Add medicine',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicineList(BuildContext context, MedicineProvider provider) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => provider.loadMedicines(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: provider.medicines.length,
        itemBuilder: (context, index) {
          final medicine = provider.medicines[index];
          return MedicineCard(
            medicine: medicine,
            onDelete: () => provider.deleteMedicine(medicine),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, MedicineProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadMedicines(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMedicineScreen(),
      ),
    );
  }

  void _showDeleteAllConfirmation(
      BuildContext context, MedicineProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Medicines'),
        content: const Text(
          'Are you sure you want to delete all medicines? This will also cancel all reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteAllMedicines();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
