import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../models/vehicle.dart';

class VehicleView extends StatelessWidget {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Flotte d\'Autocars'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VehicleViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = viewModel.vehicles[index];
              return _buildVehicleCard(context, viewModel, vehicle);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleViewModel viewModel, Vehicle vehicle) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.directions_bus, color: Colors.white),
            ),
            title: Text('${vehicle.brand} ${vehicle.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(vehicle.registration, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(vehicle.fuelLabel, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem(Icons.height, 'Hauteur', '${vehicle.height}m'),
                _buildSpecItem(Icons.straighten, 'Longueur', '${vehicle.length}m'),
                _buildSpecItem(Icons.aspect_ratio, 'Largeur', '${vehicle.width}m'),
                _buildSpecItem(Icons.monitor_weight_outlined, 'Poids/PTAC', '${vehicle.unladenWeight}t/${vehicle.ptac}t'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kilométrage actuel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${vehicle.mileage.toInt()} km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUpdateMileageDialog(context, viewModel, vehicle),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Mettre à jour'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  void _showUpdateMileageDialog(BuildContext context, VehicleViewModel viewModel, Vehicle vehicle) {
    final controller = TextEditingController(text: vehicle.mileage.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mise à jour : ${vehicle.registration}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nouveau kilométrage (km)',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final newKm = double.tryParse(controller.text);
              if (newKm != null) {
                viewModel.updateMileage(vehicle.id, newKm);
              }
              Navigator.pop(context);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}
