import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/models/subscription_tier.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<LoginViewModel>(context, listen: false).currentUser;
      Provider.of<VehicleViewModel>(context, listen: false).fetchVehicles(ownerId: user?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginViewModel>(context).currentUser;
    final tier = user?.tier ?? SubscriptionTier.free;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myFleet),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VehicleViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = viewModel.vehicles[index];
              return _buildVehicleCard(context, viewModel, vehicle, user?.id);
            },
          );
        },
      ),
      floatingActionButton: (tier.index >= SubscriptionTier.professional.index)
          ? FloatingActionButton(
              onPressed: () => _showAddVehicleDialog(context, user?.id),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleViewModel viewModel, Vehicle vehicle, String? userId) {
    final l10n = AppLocalizations.of(context)!;
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
            subtitle: Text('${vehicle.registration} ${vehicle.parkNumber != null ? "• ${l10n.parkNumber}: ${vehicle.parkNumber}" : ""}', 
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  _showAddVehicleDialog(context, userId, vehicle: vehicle);
                } else if (val == 'delete') {
                  _confirmDelete(context, viewModel, vehicle, userId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem(Icons.height, l10n.height, '${vehicle.height}m'),
                _buildSpecItem(Icons.straighten, l10n.length, '${vehicle.length}m'),
                _buildSpecItem(Icons.aspect_ratio, l10n.width, '${vehicle.width}m'),
                _buildSpecItem(Icons.monitor_weight_outlined, l10n.ptac, '${vehicle.ptac}t'),
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
                    Text('${l10n.energy}: ${vehicle.fuelLabel}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('${vehicle.mileage.toInt()} km', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUpdateMileageDialog(context, viewModel, vehicle),
                  icon: const Icon(Icons.speed, size: 16),
                  label: const Text('KM'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  void _showAddVehicleDialog(BuildContext context, String? userId, {Vehicle? vehicle}) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = vehicle != null;
    final registrationController = TextEditingController(text: vehicle?.registration);
    final brandController = TextEditingController(text: vehicle?.brand);
    final modelController = TextEditingController(text: vehicle?.model);
    final heightController = TextEditingController(text: vehicle?.height.toString());
    final lengthController = TextEditingController(text: vehicle?.length.toString());
    final widthController = TextEditingController(text: vehicle?.width.toString());
    final weightController = TextEditingController(text: vehicle?.unladenWeight.toString());
    final ptacController = TextEditingController(text: vehicle?.ptac.toString());
    final parkController = TextEditingController(text: vehicle?.parkNumber);
    final mileageController = TextEditingController(text: vehicle?.mileage.toString());
    FuelType selectedFuel = vehicle?.fuelType ?? FuelType.diesel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? l10n.editVehicle : l10n.addVehicle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: registrationController, decoration: InputDecoration(labelText: l10n.registrationRequired)),
                TextField(controller: parkController, decoration: InputDecoration(labelText: l10n.parkNumber)),
                Row(
                  children: [
                    Expanded(child: TextField(controller: brandController, decoration: InputDecoration(labelText: l10n.brand))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: modelController, decoration: InputDecoration(labelText: l10n.model))),
                  ],
                ),
                DropdownButtonFormField<FuelType>(
                  value: selectedFuel,
                  decoration: InputDecoration(labelText: l10n.energy),
                  items: FuelType.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedFuel = val!),
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: heightController, decoration: InputDecoration(labelText: '${l10n.height} (m)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: widthController, decoration: InputDecoration(labelText: '${l10n.width} (m)'), keyboardType: TextInputType.number)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: lengthController, decoration: InputDecoration(labelText: '${l10n.length} (m)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: ptacController, decoration: InputDecoration(labelText: '${l10n.ptac} (t)'), keyboardType: TextInputType.number)),
                  ],
                ),
                TextField(controller: mileageController, decoration: InputDecoration(labelText: l10n.initialMileage), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (registrationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.registrationRequired), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final newVehicle = Vehicle(
                  id: vehicle?.id ?? '',
                  registration: registrationController.text,
                  brand: brandController.text,
                  model: modelController.text,
                  height: double.tryParse(heightController.text) ?? 3.5,
                  length: double.tryParse(lengthController.text) ?? 12.0,
                  width: double.tryParse(widthController.text) ?? 2.5,
                  unladenWeight: double.tryParse(weightController.text) ?? 12.0,
                  ptac: double.tryParse(ptacController.text) ?? 19.0,
                  fuelType: selectedFuel,
                  parkNumber: parkController.text,
                  mileage: double.tryParse(mileageController.text) ?? 0,
                  ownerId: userId,
                );

                final vm = Provider.of<VehicleViewModel>(context, listen: false);
                bool success;
                if (isEdit) {
                  success = await vm.updateVehicle(newVehicle);
                } else {
                  success = await vm.addVehicle(newVehicle);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? l10n.vehicleModified : l10n.vehicleSaved),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    String error = isEdit ? 'Échec de la modification' : 'Limite de 5 véhicules atteinte ou erreur réseau';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehicleViewModel viewModel, Vehicle vehicle, String? userId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.delete} ?'),
        content: Text(l10n.deleteConfirmVehicle(vehicle.registration)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              viewModel.deleteVehicle(vehicle.id, ownerId: userId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showUpdateMileageDialog(BuildContext context, VehicleViewModel viewModel, Vehicle vehicle) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: vehicle.mileage.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mise à jour : ${vehicle.registration}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.newMileage,
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final newKm = double.tryParse(controller.text);
              if (newKm != null) {
                viewModel.updateMileage(vehicle.id, newKm);
              }
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
