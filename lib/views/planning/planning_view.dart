import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/models/planning_activity.dart';
import 'package:flutter01/models/subscription_tier.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/services/pdf_service.dart';
import 'package:flutter01/services/storage_service.dart';
import 'package:flutter01/views/navigation/navigation_view.dart';
import 'package:flutter01/views/planning/pdf_viewer_page.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({super.key});

  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
      final user = loginVM.currentUser;
      final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
      final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
      
      if (user != null) {
        planningVM.setCurrentDriver(user.id);
        vehicleVM.fetchVehicles(ownerId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPlanning),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              final vm = context.read<PlanningViewModel>();
              PdfService.generateAndSharePlanning(vm.selectedDate, vm.filteredActivities);
            },
            tooltip: l10n.exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => context.read<PlanningViewModel>().goToToday(),
            tooltip: l10n.today,
          ),
          Consumer<PlanningViewModel>(
            builder: (context, vm, child) {
              if (vm.clipboardActivity != null) {
                return IconButton(
                  icon: const Icon(Icons.content_paste, color: Colors.orangeAccent),
                  onPressed: () async {
                    final success = await vm.pasteActivity(vm.selectedDate);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.missionPasted)),
                      );
                    }
                  },
                  tooltip: l10n.pasteMission,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<PlanningViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rseWarnings = viewModel.checkRSE(viewModel.filteredActivities);
          return Column(
            children: [
              _buildViewModeSelector(context, viewModel),
              _buildDateNavigation(context, viewModel),
              if (rseWarnings.isNotEmpty && viewModel.viewMode == PlanningViewMode.day)
                _buildRSEWarnings(rseWarnings),
              Expanded(
                child: viewModel.filteredActivities.isEmpty
                    ? _buildEmptyState(context)
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
      floatingActionButton: Consumer<LoginViewModel>(
        builder: (context, loginVM, child) {
          final tier = loginVM.currentUser?.tier ?? SubscriptionTier.free;
          if (tier.index >= SubscriptionTier.professional.index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'btn_add_mission',
                  onPressed: () => _showManualAddMissionDialog(context),
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add_task, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'btn_scan_planning',
                  onPressed: () => _showDatePickerForPhoto(context),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add_a_photo, color: Colors.white),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showDatePickerForPhoto(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final currentSelectedDate = context.read<PlanningViewModel>().selectedDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentSelectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'SÉLECTIONNEZ LA DATE DU PLANNING',
      cancelText: l10n.cancel,
      confirmText: l10n.continueAction,
    );

    if (pickedDate != null && context.mounted) {
      _showPhotoSourceDialog(context, pickedDate);
    }
  }

  void _showPhotoSourceDialog(BuildContext context, DateTime targetDate) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Source pour le ${DateFormat('dd/MM/yyyy', Localizations.localeOf(context).toString()).format(targetDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo (Appareil)'),
              onTap: () {
                Navigator.pop(context);
                context.read<PlanningViewModel>().uploadPhotoPlanning(
                  targetDate,
                  source: ImageSource.camera,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir un screenshot (Galerie)'),
              onTap: () {
                Navigator.pop(context);
                context.read<PlanningViewModel>().uploadPhotoPlanning(
                  targetDate,
                  source: ImageSource.gallery,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Charger un fichier PDF'),
              onTap: () {
                Navigator.pop(context);
                context.read<PlanningViewModel>().pickAndUploadPdf(targetDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddMissionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final departureController = TextEditingController();
    final arrivalController = TextEditingController();
    final descriptionController = TextEditingController();
    
    DateTime startTime = DateTime.now().copyWith(hour: 8, minute: 0);
    DateTime endTime = DateTime.now().copyWith(hour: 10, minute: 0);
    bool syncCalendar = true;
    Vehicle? selectedVehicle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addPersonalMission),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre (ex: Service Scolaire 41)')),
                TextField(controller: departureController, decoration: InputDecoration(labelText: l10n.departure)),
                TextField(controller: arrivalController, decoration: InputDecoration(labelText: l10n.arrival)),
                TextField(
                  controller: descriptionController, 
                  decoration: const InputDecoration(labelText: 'Description / Notes (Optionnel)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Consumer<VehicleViewModel>(
                  builder: (context, vehicleVM, child) {
                    if (vehicleVM.vehicles.isEmpty) {
                      return const Text('Aucun véhicule enregistré', style: TextStyle(fontSize: 12, color: Colors.orange));
                    }
                    return DropdownButtonFormField<Vehicle>(
                      value: selectedVehicle ?? vehicleVM.vehicles.first,
                      decoration: const InputDecoration(labelText: 'Véhicule assigné'),
                      items: vehicleVM.vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.registration))).toList(),
                      onChanged: (v) => setDialogState(() => selectedVehicle = v),
                    );
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: const Text('Début', style: TextStyle(fontSize: 12)),
                  subtitle: Text(DateFormat('HH:mm').format(startTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startTime));
                    if (time != null) setDialogState(() => startTime = startTime.copyWith(hour: time.hour, minute: time.minute));
                  },
                ),
                ListTile(
                  title: const Text('Fin', style: TextStyle(fontSize: 12)),
                  subtitle: Text(DateFormat('HH:mm').format(endTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endTime));
                    if (time != null) setDialogState(() => endTime = endTime.copyWith(hour: time.hour, minute: time.minute));
                  },
                ),
                CheckboxListTile(
                  title: const Text('Ajouter à l\'agenda du téléphone', style: TextStyle(fontSize: 12)),
                  value: syncCalendar,
                  onChanged: (val) => setDialogState(() => syncCalendar = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                final loginVM = Provider.of<LoginViewModel>(context, listen: false);
                final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                
                final activity = PlanningActivity(
                  id: '', 
                  title: titleController.text,
                  type: ActivityType.trip,
                  startTime: DateTime(planningVM.selectedDate.year, planningVM.selectedDate.month, planningVM.selectedDate.day, startTime.hour, startTime.minute),
                  endTime: DateTime(planningVM.selectedDate.year, planningVM.selectedDate.month, planningVM.selectedDate.day, endTime.hour, endTime.minute),
                  departure: departureController.text,
                  arrival: arrivalController.text,
                  description: descriptionController.text,
                  vehicle: selectedVehicle ?? (vehicleVM.vehicles.isNotEmpty ? vehicleVM.vehicles.first : null),
                  driverId: loginVM.currentUser?.id,
                );

                await planningVM.addActivity(activity, syncToCalendar: syncCalendar);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission ajoutée et synchronisée')));
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('HH:mm');
    final accentColor = _getAccentColor(context, activity.type);
    final vm = context.read<PlanningViewModel>();
    final isPhoto = activity.type == ActivityType.photo_planning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPhoto ? Colors.teal.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isPhoto ? Colors.teal.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3)
          )
        ],
        border: Border(
          left: BorderSide(color: accentColor, width: isPhoto ? 10 : 6),
        ),
      ),
      child: ListTile(
        leading: isPhoto ? const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.picture_as_pdf, color: Colors.white)) : null,
        onTap: () {
          if (activity.type == ActivityType.photo_planning && activity.filePath != null) {
            final url = vm.getPublicUrl(activity.filePath!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pdfUrl: url,
                  title: activity.title,
                ),
              ),
            );
          } else {
            _showActivityDetails(context, activity);
          }
        },
        onLongPress: () {
          _showActivityOptions(context, vm, activity);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              activity.type == ActivityType.photo_planning ? 'Planning PDF' : '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () => _showEditMissionDialog(context, activity),
              tooltip: l10n.edit,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDeleteMission(context, vm, activity),
              tooltip: l10n.delete,
            ),
            const Spacer(),
            if (activity.type != ActivityType.photo_planning)
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
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Text('${l10n.bus}: ${activity.busNumber}', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: activity.type == ActivityType.photo_planning
          ? Icon(Icons.picture_as_pdf, color: accentColor)
          : (activity.type == ActivityType.bc 
            ? IconButton(
                icon: const Icon(Icons.navigation, color: Colors.purple),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationView(activity: activity))),
              )
            : Icon(_getTypeIconData(activity.type), color: accentColor.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context, PlanningViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<PlanningViewMode>(
        segments: [
          ButtonSegment(value: PlanningViewMode.day, label: Text(l10n.day)),
          ButtonSegment(value: PlanningViewMode.week, label: Text(l10n.week)),
          ButtonSegment(value: PlanningViewMode.month, label: Text(l10n.month)),
        ],
        selected: {viewModel.viewMode},
        onSelectionChanged: (Set<PlanningViewMode> newSelection) {
          viewModel.setViewMode(newSelection.first);
        },
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context, PlanningViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    String locale = Localizations.localeOf(context).toString();
    String dateText;
    
    if (viewModel.viewMode == PlanningViewMode.day) {
      dateText = DateFormat('EEEE d MMMM', locale).format(viewModel.selectedDate);
    } else if (viewModel.viewMode == PlanningViewMode.week) {
      final weekStart = viewModel.selectedDate.subtract(Duration(days: viewModel.selectedDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      dateText = l10n.fromTo(DateFormat('d MMMM', locale).format(weekStart), DateFormat('d MMMM', locale).format(weekEnd));
    } else {
      dateText = DateFormat('MMMM yyyy', locale).format(viewModel.selectedDate);
    }
    
    // Fallback if formatting fails or is empty
    if (dateText.isEmpty) {
      dateText = "${viewModel.selectedDate.day}/${viewModel.selectedDate.month}/${viewModel.selectedDate.year}";
    } else {
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noTrips, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, PlanningActivity activity) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE d MMMM', Localizations.localeOf(context).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(Icons.calendar_today, 'Date', dateFormat.format(activity.startTime)),
              _buildDetailRow(Icons.access_time, 'Horaires', '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)}'),
              if (activity.busNumber != null) _buildDetailRow(Icons.directions_bus, l10n.vehicle, activity.busNumber!),
              if (activity.departure != null) _buildDetailRow(Icons.location_on, 'Itinéraire', '${activity.departure} ➔ ${activity.arrival}'),
              if (activity.description != null && activity.description!.isNotEmpty)
                _buildDetailRow(Icons.description, 'Description', activity.description!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel))],
      ),
    );
  }

  void _showEditMissionDialog(BuildContext context, PlanningActivity activity) {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: activity.title);
    final departureController = TextEditingController(text: activity.departure);
    final arrivalController = TextEditingController(text: activity.arrival);
    final descriptionController = TextEditingController(text: activity.description);
    final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
    
    DateTime selectedDate = activity.startTime;
    DateTime startTime = activity.startTime;
    DateTime endTime = activity.endTime;
    Vehicle? selectedVehicle = activity.vehicle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier la mission'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
                const SizedBox(height: 10),
                if (vehicleVM.vehicles.isNotEmpty)
                  DropdownButtonFormField<Vehicle>(
                    value: selectedVehicle ?? vehicleVM.vehicles.first,
                    decoration: const InputDecoration(labelText: 'Véhicule assigné'),
                    items: vehicleVM.vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.registration))).toList(),
                    onChanged: (v) => setDialogState(() => selectedVehicle = v),
                  ),
                ListTile(
                  title: const Text('Date', style: TextStyle(fontSize: 12)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Début', style: TextStyle(fontSize: 12)),
                        subtitle: Text(DateFormat('HH:mm').format(startTime)),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startTime));
                          if (time != null) setDialogState(() => startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, time.hour, time.minute));
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Fin', style: TextStyle(fontSize: 12)),
                        subtitle: Text(DateFormat('HH:mm').format(endTime)),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endTime));
                          if (time != null) setDialogState(() => endTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, time.hour, time.minute));
                        },
                      ),
                    ),
                  ],
                ),
                TextField(controller: departureController, decoration: const InputDecoration(labelText: 'Départ')),
                TextField(controller: arrivalController, decoration: const InputDecoration(labelText: 'Arrivée')),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                final vVM = Provider.of<VehicleViewModel>(context, listen: false);
                
                final updatedActivity = PlanningActivity(
                  id: activity.id,
                  title: titleController.text,
                  type: activity.type,
                  startTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute),
                  endTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute),
                  departure: departureController.text,
                  arrival: arrivalController.text,
                  description: descriptionController.text,
                  driverId: activity.driverId,
                  vehicle: selectedVehicle ?? (vVM.vehicles.isNotEmpty ? vVM.vehicles.first : null),
                  filePath: activity.filePath,
                );

                final success = await planningVM.updateActivity(updatedActivity);
                if (context.mounted && success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission mise à jour')));
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityOptions(BuildContext context, PlanningViewModel vm, PlanningActivity activity) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier cette mission'),
              onTap: () {
                vm.copyActivity(activity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mission copiée. Allez à une autre date pour la coller.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text(l10n.edit, style: const TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.pop(context);
                _showEditMissionDialog(context, activity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteMission(context, vm, activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMission(BuildContext context, PlanningViewModel vm, PlanningActivity activity) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.delete} ?'),
        content: Text('Voulez-vous vraiment supprimer "${activity.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final success = await vm.removeActivity(activity.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission supprimée')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
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
      case ActivityType.photo_planning: return Colors.teal;
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
      case ActivityType.photo_planning: return Icons.picture_as_pdf;
    }
  }
}
