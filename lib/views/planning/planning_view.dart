import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../models/planning_activity.dart';
import '../../services/pdf_service.dart';
import '../navigation/navigation_view.dart';

class PlanningView extends StatelessWidget {
  const PlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              final vm = context.read<PlanningViewModel>();
              PdfService.generateAndSharePlanning(vm.selectedDate, vm.filteredActivities);
            },
            tooltip: "Exporter en PDF",
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => context.read<PlanningViewModel>().goToToday(),
            tooltip: "Aujourd'hui",
          ),
        ],
      ),
      body: Consumer<PlanningViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildViewModeSelector(context, viewModel),
              _buildDateNavigation(context, viewModel),
              Expanded(
                child: viewModel.filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: viewModel.filteredActivities.length,
                        itemBuilder: (context, index) {
                          final activity = viewModel.filteredActivities[index];
                          return _buildActivityCard(context, activity);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context, PlanningViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<PlanningViewMode>(
        segments: const [
          ButtonSegment(value: PlanningViewMode.day, label: Text('Jour')),
          ButtonSegment(value: PlanningViewMode.week, label: Text('Semaine')),
          ButtonSegment(value: PlanningViewMode.month, label: Text('Mois')),
        ],
        selected: {viewModel.viewMode},
        onSelectionChanged: (Set<PlanningViewMode> newSelection) {
          viewModel.setViewMode(newSelection.first);
        },
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context, PlanningViewModel viewModel) {
    String locale = 'fr_FR';
    String dateText;
    
    try {
      if (viewModel.viewMode == PlanningViewMode.day) {
        dateText = DateFormat('EEEE d MMMM', locale).format(viewModel.selectedDate);
      } else if (viewModel.viewMode == PlanningViewMode.week) {
        final weekStart = viewModel.selectedDate.subtract(Duration(days: viewModel.selectedDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        dateText = "Du ${DateFormat('d MMMM', locale).format(weekStart)} au ${DateFormat('d MMMM', locale).format(weekEnd)}";
      } else {
        dateText = DateFormat('MMMM yyyy', locale).format(viewModel.selectedDate);
      }
    } catch (e) {
      if (viewModel.viewMode == PlanningViewMode.day) {
        dateText = DateFormat('EEEE d MMMM').format(viewModel.selectedDate);
      } else if (viewModel.viewMode == PlanningViewMode.week) {
        final weekStart = viewModel.selectedDate.subtract(Duration(days: viewModel.selectedDate.weekday - 1));
        dateText = "Week of ${DateFormat('d MMMM').format(weekStart)}";
      } else {
        dateText = DateFormat('MMMM yyyy').format(viewModel.selectedDate);
      }
    }

    if (dateText.isNotEmpty) {
      dateText = dateText[0].toUpperCase() + dateText.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => viewModel.previous(),
          ),
          Expanded(
            child: Text(
              dateText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => viewModel.next(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun trajet prévu pour cette période',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, PlanningActivity activity) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              _getTypeIcon(activity.type, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text(activity.title)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildDetailRow(Icons.calendar_today, 'Date', dateFormat.format(activity.startTime)),
                _buildDetailRow(Icons.access_time, 'Horaires', '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}'),
                _buildDetailRow(Icons.timer, 'Durée', '${activity.duration.inMinutes} minutes'),
                if (activity.busNumber != null)
                  _buildDetailRow(Icons.directions_bus, 'Véhicule', activity.busNumber!),
                if (activity.departure != null)
                  _buildDetailRow(Icons.location_on, 'Départ', activity.departure!),
                if (activity.arrival != null)
                  _buildDetailRow(Icons.flag, 'Arrivée', activity.arrival!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Icon _getTypeIcon(ActivityType type, {double size = 24}) {
    switch (type) {
      case ActivityType.ps: return Icon(Icons.login, color: Colors.blue, size: size);
      case ActivityType.fs: return Icon(Icons.logout, color: Colors.red, size: size);
      case ActivityType.trip: return Icon(Icons.directions_bus, color: Colors.green, size: size);
      case ActivityType.nettoyage: return Icon(Icons.cleaning_services, color: Colors.orange, size: size);
      case ActivityType.hlp: return Icon(Icons.arrow_forward, color: Colors.grey, size: size);
      case ActivityType.bc: return Icon(Icons.groups, color: Colors.purple, size: size);
    }
  }

  Widget _buildActivityCard(BuildContext context, PlanningActivity activity) {
    final timeFormat = DateFormat('HH:mm');
    
    Color accentColor;
    IconData icon;
    
    switch (activity.type) {
      case ActivityType.ps:
        accentColor = Colors.blue;
        icon = Icons.login;
        break;
      case ActivityType.fs:
        accentColor = Colors.red;
        icon = Icons.logout;
        break;
      case ActivityType.trip:
        accentColor = Colors.green;
        icon = Icons.directions_bus;
        break;
      case ActivityType.nettoyage:
        accentColor = Colors.orange;
        icon = Icons.cleaning_services;
        break;
      case ActivityType.hlp:
        accentColor = Colors.grey;
        icon = Icons.arrow_forward;
        break;
      case ActivityType.bc:
        accentColor = Colors.purple;
        icon = Icons.groups;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: (activity.type == ActivityType.trip || activity.type == ActivityType.bc) ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _showActivityDetails(context, activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Colonne Heure
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeFormat.format(activity.startTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                    Text(
                      timeFormat.format(activity.endTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const VerticalDivider(width: 20),
                // Icône du type
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 15),
                // Détails
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: (activity.type == ActivityType.trip || activity.type == ActivityType.bc) ? Colors.black : Colors.black87,
                        ),
                      ),
                      if (activity.departure != null && activity.arrival != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${activity.departure} ➔ ${activity.arrival}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      if (activity.type == ActivityType.bc)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Billet Collectif (BC)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ),
                      if (activity.busNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Véhicule: ${activity.busNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions Spécifiques BC
                if (activity.type == ActivityType.bc)
                  IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.purple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NavigationView(activity: activity)),
                      );
                    },
                  )
                else
                // Durée
                Text(
                  '${activity.duration.inMinutes} min',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
