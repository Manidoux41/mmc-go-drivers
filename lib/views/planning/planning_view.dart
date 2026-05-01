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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
          final rseWarnings = viewModel.checkRSE(viewModel.filteredActivities);
          return Column(
            children: [
              _buildViewModeSelector(context, viewModel),
              _buildDateNavigation(context, viewModel),
              if (rseWarnings.isNotEmpty && viewModel.viewMode == PlanningViewMode.day)
                _buildRSEWarnings(rseWarnings),
              Expanded(
                child: viewModel.filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: viewModel.filteredActivities.length,
                        itemBuilder: (context, index) {
                          final activity = viewModel.filteredActivities[index];
                          return _buildActivityBlock(context, activity);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRSEWarnings(List<String> warnings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Alertes RSE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $w', style: const TextStyle(color: Colors.red, fontSize: 13)),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityBlock(BuildContext context, PlanningActivity activity) {
    final timeFormat = DateFormat('HH:mm');
    final accentColor = _getAccentColor(context, activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        border: Border(left: BorderSide(color: accentColor, width: 6)),
      ),
      child: ListTile(
        onTap: () => _showActivityDetails(context, activity),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
            ),
            const Spacer(),
            Text(
              '${activity.duration.inMinutes}m',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(activity.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (activity.departure != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${activity.departure} ➔ ${activity.arrival}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            if (activity.busNumber != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Text('Bus: ${activity.busNumber}', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: activity.type == ActivityType.bc 
          ? IconButton(
              icon: const Icon(Icons.navigation, color: Colors.purple),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationView(activity: activity))),
            )
          : Icon(_getTypeIconData(activity.type), color: accentColor.withOpacity(0.5)),
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
    
    if (viewModel.viewMode == PlanningViewMode.day) {
      dateText = DateFormat('EEEE d MMMM', locale).format(viewModel.selectedDate);
    } else if (viewModel.viewMode == PlanningViewMode.week) {
      final weekStart = viewModel.selectedDate.subtract(Duration(days: viewModel.selectedDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      dateText = "Du ${DateFormat('d MMMM', locale).format(weekStart)} au ${DateFormat('d MMMM', locale).format(weekEnd)}";
    } else {
      dateText = DateFormat('MMMM yyyy', locale).format(viewModel.selectedDate);
    }

    if (dateText.isNotEmpty) {
      dateText = dateText[0].toUpperCase() + dateText.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => viewModel.previous()),
          Expanded(child: Text(dateText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => viewModel.next()),
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
          Text('Aucun trajet prévu pour cette période', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, PlanningActivity activity) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(Icons.calendar_today, 'Date', dateFormat.format(activity.startTime)),
            _buildDetailRow(Icons.access_time, 'Horaires', '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}'),
            if (activity.busNumber != null) _buildDetailRow(Icons.directions_bus, 'Véhicule', activity.busNumber!),
            if (activity.departure != null) _buildDetailRow(Icons.location_on, 'Itinéraire', '${activity.departure} ➔ ${activity.arrival}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text('$label: $value', style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getAccentColor(BuildContext context, ActivityType type) {
    switch (type) {
      case ActivityType.ps: return Colors.blue;
      case ActivityType.fs: return Colors.red;
      case ActivityType.trip: return Theme.of(context).primaryColor;
      case ActivityType.nettoyage: return Colors.orange;
      case ActivityType.hlp: return Colors.blueGrey;
      case ActivityType.bc: return Colors.purple;
    }
  }

  IconData _getTypeIconData(ActivityType type) {
    switch (type) {
      case ActivityType.ps: return Icons.login;
      case ActivityType.fs: return Icons.logout;
      case ActivityType.trip: return Icons.directions_bus;
      case ActivityType.nettoyage: return Icons.cleaning_services;
      case ActivityType.hlp: return Icons.arrow_forward;
      case ActivityType.bc: return Icons.groups;
    }
  }
}
