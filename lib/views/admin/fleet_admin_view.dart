import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/fleet_admin_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../models/vehicle.dart';
import '../../models/planning_activity.dart';
import '../../services/pdf_service.dart';
import 'package:intl/intl.dart';

class FleetAdminView extends StatelessWidget {
  const FleetAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Console d\'Administration Entreprise'),
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Conducteurs'),
              Tab(icon: Icon(Icons.directions_bus_filled_outlined), text: 'Véhicules'),
              Tab(icon: Icon(Icons.calendar_view_week), text: 'Planning Flotte'),
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

class _ManageDriversTab extends StatefulWidget {
  const _ManageDriversTab();

  @override
  State<_ManageDriversTab> createState() => _ManageDriversTabState();
}

class _ManageDriversTabState extends State<_ManageDriversTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FleetAdminViewModel>(context, listen: false).fetchDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FleetAdminViewModel>(context);
    return Scaffold(
      body: viewModel.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: viewModel.drivers.length,
            itemBuilder: (context, index) {
              final driver = viewModel.drivers[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(driver.fullName ?? 'Sans nom'),
                subtitle: Text(driver.username),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => viewModel.removeDriver(driver.id),
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
}

void _showAddDriverDialog(BuildContext context) {
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ajouter un conducteur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Identifiant / Email')),
          TextField(controller: fullNameController, decoration: const InputDecoration(labelText: 'Nom Complet')),
          TextField(
            controller: passwordController, 
            decoration: const InputDecoration(labelText: 'Mot de passe provisoire'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
              Provider.of<FleetAdminViewModel>(context, listen: false).addDriver(
                usernameController.text, 
                fullNameController.text,
                passwordController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conducteur créé avec succès')),
              );
            }
          },
          child: const Text('Créer le compte'),
        ),
      ],
    ),
  );
}

class _ManageVehiclesTab extends StatefulWidget {
  const _ManageVehiclesTab();

  @override
  State<_ManageVehiclesTab> createState() => _ManageVehiclesTabState();
}

class _ManageVehiclesTabState extends State<_ManageVehiclesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleViewModel>(context, listen: false).fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VehicleViewModel>(context);
    return Scaffold(
      body: viewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
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
    final fleetVM = Provider.of<FleetAdminViewModel>(context);
    final planningVM = Provider.of<PlanningViewModel>(context);

    return Column(
      children: [
        Container(
          color: Colors.blueGrey.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubTabButton(0, 'Assignation', Icons.edit_calendar),
                _buildSubTabButton(1, 'Vue Jour', Icons.view_day),
                _buildSubTabButton(2, 'Vue Semaine', Icons.view_week),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.blueGrey),
                  onPressed: () {
                    final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
                    Map<String, List<PlanningActivity>> data = {};
                      for (var driver in fleetVM.drivers) {
                        data[driver.fullName ?? driver.username] = planningVM.getFilteredActivitiesForDriver(driver.id, weekStart, 7);
                      }
                    PdfService.generateWeeklyPlanning(weekStart, data);
                  },
                  tooltip: 'Exporter la semaine en PDF',
                ),
              ],
            ),
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

class _ManagePlanningTab extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const _ManagePlanningTab({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    final drivers = Provider.of<FleetAdminViewModel>(context).drivers;
    return Scaffold(
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: onDateChanged,
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
                  onTap: () {
                    if (drivers.isNotEmpty) {
                      _showAddMissionDialog(context, selectedDate, drivers.first);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (drivers.isNotEmpty) {
            _showAddMissionDialog(context, selectedDate, drivers.first);
          }
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.edit_calendar, color: Colors.white),
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
          border: TableBorder.all(color: Colors.grey.shade300),
          columns: [
            const DataColumn(label: Text('Conducteur', style: TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: Text('Missions du jour', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: fleetVM.drivers.map((driver) {
            final activities = planningVM.getActivitiesForDriver(driver.id, date);
            return DataRow(cells: [
              DataCell(Text(driver.fullName ?? driver.username, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(
                InkWell(
                  onTap: () => _showDayEditDialog(context, driver, date, activities),
                  child: Container(
                    width: double.maxFinite,
                    constraints: const BoxConstraints(minWidth: 200),
                    child: activities.isEmpty 
                      ? const Text('Aucune mission (Cliquer pour ajouter)', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      : Wrap(
                          spacing: 8,
                          children: activities.map((a) => Chip(
                            label: Text('${DateFormat('HH:mm').format(a.startTime)}: ${a.title}', style: const TextStyle(fontSize: 10)),
                            backgroundColor: Colors.blueGrey.shade50,
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                  ),
                ),
              ),
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
          border: TableBorder.all(color: Colors.grey.shade300),
          columnSpacing: 20,
          columns: [
            const DataColumn(label: Text('Conducteur', style: TextStyle(fontWeight: FontWeight.bold))),
            ...days.map((d) => DataColumn(label: Text(DateFormat('EEE dd/MM').format(d), style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
          rows: fleetVM.drivers.map((driver) {
            return DataRow(cells: [
              DataCell(Text(driver.fullName ?? driver.username, style: const TextStyle(fontWeight: FontWeight.bold))),
              ...days.map((d) {
                final activities = planningVM.getActivitiesForDriver(driver.id, d);
                return DataCell(
                  InkWell(
                    onTap: () => _showDayEditDialog(context, driver, d, activities),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: activities.isEmpty 
                        ? const Icon(Icons.add, size: 16, color: Colors.grey)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${activities.length} mission(s)', style: const TextStyle(fontSize: 11)),
                              const Icon(Icons.edit, size: 12, color: Colors.blueGrey),
                            ],
                          ),
                    ),
                  ),
                );
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

void _showDayEditDialog(BuildContext context, dynamic driver, DateTime date, List<PlanningActivity> activities) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Planning: ${driver.fullName} (${DateFormat('dd/MM').format(date)})'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Aucune mission prévue.'),
              )
            else
              ...activities.map((a) => ListTile(
                leading: const Icon(Icons.directions_bus, size: 18),
                title: Text(a.title),
                subtitle: Text('${DateFormat('HH:mm').format(a.startTime)} - ${DateFormat('HH:mm').format(a.endTime)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    Provider.of<PlanningViewModel>(context, listen: false).removeActivity(a.id);
                    Navigator.pop(context);
                  },
                ),
              )),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddMissionDialog(context, date, driver);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une mission'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
      ],
    ),
  );
}

void _showAddMissionDialog(BuildContext context, DateTime date, dynamic selectedDriver) {
  final titleController = TextEditingController();
  final departureController = TextEditingController();
  final arrivalController = TextEditingController();
  final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
  
  Vehicle? selectedVehicle = vehicleVM.vehicles.isNotEmpty ? vehicleVM.vehicles.first : null;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Programmer pour ${selectedDriver.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre de la mission')),
              TextField(controller: departureController, decoration: const InputDecoration(labelText: 'Départ')),
              TextField(controller: arrivalController, decoration: const InputDecoration(labelText: 'Arrivée')),
              const SizedBox(height: 10),
              if (vehicleVM.vehicles.isNotEmpty)
                DropdownButtonFormField<Vehicle>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(labelText: 'Véhicule assigné'),
                  items: vehicleVM.vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.registration))).toList(),
                  onChanged: (v) => setDialogState(() => selectedVehicle = v),
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
                driverId: selectedDriver.id,
              );
              Provider.of<PlanningViewModel>(context, listen: false).addActivity(activity);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission ajoutée')));
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    ),
  );
}
