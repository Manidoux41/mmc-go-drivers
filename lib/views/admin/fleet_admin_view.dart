import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/fleet_admin_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../models/vehicle.dart';
import '../../models/planning_activity.dart';
import 'package:intl/intl.dart';

class FleetAdminView extends StatelessWidget {
  const FleetAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration Flotte (Diamant)'),
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Conducteurs'),
              Tab(icon: Icon(Icons.directions_bus), text: 'Véhicules'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Planning'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ManageDriversTab(),
            _ManageVehiclesTab(),
            _PlanningOverviewRoot(),
          ],
        ),
      ),
    );
  }
}

class _ManageDriversTab extends StatelessWidget {
  const _ManageDriversTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FleetAdminViewModel>(context);
    return Scaffold(
      body: ListView.builder(
        itemCount: viewModel.drivers.length,
        itemBuilder: (context, index) {
          final driver = viewModel.drivers[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(driver.fullName ?? 'Sans nom'),
            subtitle: Text('@${driver.username}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => viewModel.removeDriver(driver.username),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDriverDialog(context),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un conducteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Identifiant')),
            TextField(controller: fullNameController, decoration: const InputDecoration(labelText: 'Nom Complet')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Provider.of<FleetAdminViewModel>(context, listen: false)
                  .addDriver(usernameController.text, fullNameController.text);
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _ManageVehiclesTab extends StatelessWidget {
  const _ManageVehiclesTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VehicleViewModel>(context);
    return Scaffold(
      body: ListView.builder(
        itemCount: viewModel.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = viewModel.vehicles[index];
          return ListTile(
            leading: const Icon(Icons.directions_bus),
            title: Text(vehicle.registration),
            subtitle: Text('${vehicle.brand} ${vehicle.model}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleDialog(context),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final registrationController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un véhicule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: registrationController, decoration: const InputDecoration(labelText: 'Immatriculation')),
            TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Marque')),
            TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Modèle')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final newVehicle = Vehicle(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                registration: registrationController.text,
                brand: brandController.text,
                model: modelController.text,
                height: 3.5,
                length: 12.0,
                width: 2.5,
                unladenWeight: 12.0,
                ptac: 19.0,
                fuelType: FuelType.diesel,
                mileage: 0,
              );
              Provider.of<VehicleViewModel>(context, listen: false).addVehicle(newVehicle);
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _PlanningOverviewRoot extends StatefulWidget {
  const _PlanningOverviewRoot();

  @override
  State<_PlanningOverviewRoot> createState() => _PlanningOverviewRootState();
}

class _PlanningOverviewRootState extends State<_PlanningOverviewRoot> {
  int _subTab = 0; // 0: Assignation, 1: Tableau Journalier, 2: Tableau Hebdo
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blueGrey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSubTabButton(0, 'Assignation', Icons.edit_calendar),
              _buildSubTabButton(1, 'Vue Jour', Icons.view_day),
              _buildSubTabButton(2, 'Vue Semaine', Icons.view_week),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _subTab,
            children: [
              _ManagePlanningTab(
                selectedDate: _selectedDate,
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              _DailyOverviewTable(date: _selectedDate),
              _WeeklyOverviewTable(date: _selectedDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(int index, String label, IconData icon) {
    final isSelected = _subTab == index;
    return TextButton.icon(
      onPressed: () => setState(() => _subTab = index),
      icon: Icon(icon, size: 18, color: isSelected ? Colors.blueGrey : Colors.grey),
      label: Text(label, style: TextStyle(color: isSelected ? Colors.blueGrey : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }
}

class _ManagePlanningTab extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const _ManagePlanningTab({required this.selectedDate, required this.onDateChanged});

  @override
  State<_ManagePlanningTab> createState() => _ManagePlanningTabState();
}

class _ManagePlanningTabState extends State<_ManagePlanningTab> {
  @override
  Widget build(BuildContext context) {
    final planningVM = Provider.of<PlanningViewModel>(context);
    final vehicleVM = Provider.of<VehicleViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: widget.selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: widget.onDateChanged,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Missions programmées (Exemples)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blue),
                  title: const Text('Nouvelle Mission'),
                  subtitle: const Text('Cliquez sur + pour programmer une mission'),
                  onTap: () => _showAddMissionDialog(context, widget.selectedDate),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMissionDialog(context, widget.selectedDate),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.edit_calendar, color: Colors.white),
      ),
    );
  }

  void _showAddMissionDialog(BuildContext context, DateTime date) {
    final titleController = TextEditingController();
    final departureController = TextEditingController();
    final arrivalController = TextEditingController();
    final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
    final fleetVM = Provider.of<FleetAdminViewModel>(context, listen: false);
    
    Vehicle? selectedVehicle = vehicleVM.vehicles.first;
    var selectedDriver = fleetVM.drivers.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Mission du ${DateFormat('dd/MM/yyyy').format(date)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre de la mission')),
                TextField(controller: departureController, decoration: const InputDecoration(labelText: 'Départ')),
                TextField(controller: arrivalController, decoration: const InputDecoration(labelText: 'Arrivée')),
                const SizedBox(height: 10),
                DropdownButtonFormField<Vehicle>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(labelText: 'Véhicule assigné'),
                  items: vehicleVM.vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.registration))).toList(),
                  onChanged: (v) => setDialogState(() => selectedVehicle = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedDriver,
                  decoration: const InputDecoration(labelText: 'Conducteur assigné'),
                  items: fleetVM.drivers.map((d) => DropdownMenuItem(value: d, child: Text(d.fullName ?? d.username))).toList(),
                  onChanged: (d) => setDialogState(() => selectedDriver = d!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final activity = PlanningActivity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  type: ActivityType.trip,
                  startTime: DateTime(date.year, date.month, date.day, 8, 0),
                  endTime: DateTime(date.year, date.month, date.day, 10, 0),
                  departure: departureController.text,
                  arrival: arrivalController.text,
                  vehicle: selectedVehicle,
                  driverId: selectedDriver.username,
                );
                Provider.of<PlanningViewModel>(context, listen: false).addActivity(activity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission ajoutée au planning')));
              },
              child: const Text('Programmer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyOverviewTable extends StatelessWidget {
  final DateTime date;
  const _DailyOverviewTable({required this.date});

  @override
  Widget build(BuildContext context) {
    final fleetVM = Provider.of<FleetAdminViewModel>(context);
    final planningVM = Provider.of<PlanningViewModel>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade100),
          columns: [
            const DataColumn(label: Text('Conducteur')),
            const DataColumn(label: Text('Missions du jour')),
          ],
          rows: fleetVM.drivers.map((driver) {
            final activities = planningVM.getActivitiesForDriver(driver.username, date);
            return DataRow(cells: [
              DataCell(Text(driver.fullName ?? driver.username, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(activities.isEmpty 
                ? 'Aucune mission' 
                : activities.map((a) => '${DateFormat('HH:mm').format(a.startTime)}: ${a.title}').join(' / '))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _WeeklyOverviewTable extends StatelessWidget {
  final DateTime date;
  const _WeeklyOverviewTable({required this.date});

  @override
  Widget build(BuildContext context) {
    final fleetVM = Provider.of<FleetAdminViewModel>(context);
    final planningVM = Provider.of<PlanningViewModel>(context);
    
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade100),
          columns: [
            const DataColumn(label: Text('Conducteur')),
            ...days.map((d) => DataColumn(label: Text(DateFormat('EEE dd/MM').format(d)))),
          ],
          rows: fleetVM.drivers.map((driver) {
            return DataRow(cells: [
              DataCell(Text(driver.fullName ?? driver.username, style: const TextStyle(fontWeight: FontWeight.bold))),
              ...days.map((d) {
                final activities = planningVM.getActivitiesForDriver(driver.username, d);
                return DataCell(Text(activities.length.toString(), textAlign: TextAlign.center));
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
