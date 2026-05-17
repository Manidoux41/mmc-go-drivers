import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/planning_activity.dart';
import '../models/vehicle.dart';
import '../services/supabase_service.dart';
import '../services/pdf_service.dart';
import 'vehicle_viewmodel.dart';

enum PlanningViewMode { day, week, month }

class PlanningViewModel extends ChangeNotifier {
  final VehicleViewModel vehicleViewModel;
  String? _currentDriverId;
  SupabaseClient? _customClient; // Client spécifique pour Diamant décentralisé
  
  DateTime _selectedDate = DateTime.now();
  PlanningViewMode _viewMode = PlanningViewMode.day;

  List<PlanningActivity> _activities = [];
  bool _isLoading = false;

  PlanningActivity? _clipboardActivity; // Pour le copier-coller
  PlanningActivity? get clipboardActivity => _clipboardActivity;

  final cal.DeviceCalendarPlugin _calendarPlugin = cal.DeviceCalendarPlugin();

  PlanningViewModel({required this.vehicleViewModel}) {
    tz.initializeTimeZones();
  }

  DateTime get selectedDate => _selectedDate;
  PlanningViewMode get viewMode => _viewMode;
  List<PlanningActivity> get allActivities => _activities;
  bool get isLoading => _isLoading;

  SupabaseClient get _db => _customClient ?? SupabaseService.client;

  void setCustomClient(String? url, String? anonKey) {
    if (url != null && anonKey != null) {
      _customClient = SupabaseClient(url, anonKey);
    } else {
      _customClient = null;
    }
  }

  void setCurrentDriver(String? driverId) {
    _currentDriverId = driverId;
    fetchActivities();
  }

  void clear() {
    _activities = [];
    _currentDriverId = null;
    _customClient = null;
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _db.from('activities').select();
      
      if (_currentDriverId != null) {
        query = query.eq('driver_id', _currentDriverId!);
      }
// ...

      final data = await query;
      
      _activities = (data as List).map((json) {
        final vehicleId = json['vehicle_id'];
        Vehicle? vehicle;
        
        if (vehicleId != null && vehicleViewModel.vehicles.isNotEmpty) {
          try {
            vehicle = vehicleViewModel.vehicles.firstWhere((v) => v.id == vehicleId);
          } catch (_) {
            // Véhicule non trouvé dans la liste locale
          }
        }

        return PlanningActivity.fromJson(json, vehicle: vehicle);
      }).toList();
    } catch (e) {
      debugPrint("Erreur fetch activities : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadPhotoPlanning(DateTime date) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null && _currentDriverId != null) {
      _isLoading = true;
      notifyListeners();

      try {
        if (kIsWeb) {
          debugPrint('L\'envoi de planning photo n\'est pas encore disponible sur le Web.');
          _isLoading = false;
          notifyListeners();
          return;
        }

        final File imageFile = File(pickedFile.path);
        
        // 1. Image -> PDF
        final pdfFile = await PdfService.imageToPdf(imageFile);

        if (pdfFile != null) {
          // 2. Upload to Storage
          final fileName = 'planning_${_currentDriverId}_${date.millisecondsSinceEpoch}.pdf';
          
          // Utiliser le client de stockage approprié (custom ou défaut)
          final storageClient = _db.storage;
          final String? storagePath = await _uploadToClientStorage(storageClient, pdfFile, fileName);

          if (storagePath != null) {
            // 3. Create Activity
            final activity = PlanningActivity(
              id: '', // Supabase générera l'id
              title: 'Planning Photo du ${date.day}/${date.month}',
              type: ActivityType.photo_planning,
              startTime: DateTime(date.year, date.month, date.day, 8, 0),
              endTime: DateTime(date.year, date.month, date.day, 18, 0),
              driverId: _currentDriverId,
              filePath: storagePath,
            );

            await addActivity(activity);
          }
        }
      } catch (e) {
        debugPrint("Erreur upload photo planning : $e");
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _uploadToClientStorage(SupabaseStorageClient storage, File file, String fileName) async {
    try {
      // On s'assure d'abord que le bucket existe
      try { await storage.createBucket('plannings', const BucketOptions(public: true)); } catch (_) {}
      
      final path = await storage.from('plannings').upload(fileName, file);
      return path;
    } catch (e) {
      debugPrint('Erreur storage spécifique: $e');
      return null;
    }
  }

  Future<bool> addActivity(PlanningActivity activity, {bool syncToCalendar = false}) async {
    try {
      await _db
          .from('activities')
          .insert(activity.toJson());
      
      if (syncToCalendar) {
        await _syncToDeviceCalendar(activity);
      }
      
      await fetchActivities();
      return true;
    } catch (e) {
      debugPrint("ERREUR AJOUT ACTIVITÉ : ${e.toString()}");
      return false;
    }
  }

  Future<void> _syncToDeviceCalendar(PlanningActivity activity) async {
    try {
      var permissionsGranted = await _calendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _calendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) return;
      }

      final calendars = await _calendarPlugin.retrieveCalendars();
      if (calendars.isSuccess && calendars.data != null && calendars.data!.isNotEmpty) {
        // On prend le premier calendrier éditable (souvent le principal)
        final targetCalendar = calendars.data!.firstWhere((c) => !c.isReadOnly!, orElse: () => calendars.data!.first);
        
        final event = cal.Event(
          targetCalendar.id,
          title: "Mission MMC Go: ${activity.title}",
          description: activity.departure != null ? "De ${activity.departure} à ${activity.arrival}" : "Activité professionnelle",
          start: tz.TZDateTime.from(activity.startTime, tz.local),
          end: tz.TZDateTime.from(activity.endTime, tz.local),
        );

        await _calendarPlugin.createOrUpdateEvent(event);
        debugPrint("CALENDAR : Synchronisé avec l'agenda du téléphone");
      }
    } catch (e) {
      debugPrint("CALENDAR ERROR : $e");
    }
  }

  Future<bool> removeActivity(String activityId) async {
    try {
      await _db
          .from('activities')
          .delete()
          .eq('id', activityId);
      
      await fetchActivities();
      return true;
    } catch (e) {
      debugPrint("ERREUR SUPPRESSION ACTIVITÉ : ${e.toString()}");
      return false;
    }
  }

  Future<bool> updateActivity(PlanningActivity activity) async {
    try {
      await _db
          .from('activities')
          .update(activity.toJson())
          .eq('id', activity.id);
      
      await fetchActivities();
      return true;
    } catch (e) {
      debugPrint("ERREUR UPDATE ACTIVITÉ : ${e.toString()}");
      return false;
    }
  }

  List<PlanningActivity> getActivitiesForDriver(String driverId, DateTime date) {
    return _activities.where((a) => 
      a.driverId == driverId && 
      a.startTime.year == date.year && 
      a.startTime.month == date.month && 
      a.startTime.day == date.day
    ).toList();
  }

  List<PlanningActivity> getFilteredActivitiesForDriver(String driverId, DateTime startDate, int days) {
    final endDate = startDate.add(Duration(days: days));
    return _activities.where((a) => 
      a.driverId == driverId && 
      a.startTime.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
      a.startTime.isBefore(endDate)
    ).toList();
  }

  List<PlanningActivity> get filteredActivities {
    return _activities.where((activity) {
      if (_viewMode == PlanningViewMode.day) {
        return activity.startTime.year == _selectedDate.year &&
            activity.startTime.month == _selectedDate.month &&
            activity.startTime.day == _selectedDate.day;
      } else if (_viewMode == PlanningViewMode.week) {
        final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1)).copyWith(hour: 0, minute: 0);
        final weekEnd = weekStart.add(const Duration(days: 7));
        return activity.startTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            activity.startTime.isBefore(weekEnd);
      } else {
        return activity.startTime.year == _selectedDate.year &&
            activity.startTime.month == _selectedDate.month;
      }
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<String> checkRSE(List<PlanningActivity> activities) {
    if (activities.isEmpty) return [];
    List<String> warnings = [];

    // 1. Calcul de l'Amplitude (max 12h)
    activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    final first = activities.first.startTime;
    final last = activities.last.endTime;
    final amplitude = last.difference(first);
    if (amplitude.inHours > 12) {
      warnings.add("Amplitude de ${amplitude.inHours}h dépasse la recommandation (12h).");
    }

    // 2. Temps de conduite cumulé (max 9h)
    Duration totalDriving = Duration.zero;
    for (var a in activities) {
      if (a.isDriving) {
        totalDriving += a.duration;
      }
    }
    if (totalDriving.inHours >= 9) {
      warnings.add("Conduite totale (${totalDriving.inHours}h ${totalDriving.inMinutes % 60}m) proche ou dépasse 9h.");
    }

    // 3. Coupure (Pause 45min après 4h30)
    // Prototype simplifié
    Duration continuousDriving = Duration.zero;
    for (var a in activities) {
      if (a.isDriving) {
        continuousDriving += a.duration;
        if (continuousDriving.inMinutes > 270) {
          warnings.add("Alerte : >4h30 de conduite sans coupure de 45min.");
          break;
        }
      }
    }
    return warnings;
  }

  void setViewMode(PlanningViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void next() {
    if (_viewMode == PlanningViewMode.day) {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    } else if (_viewMode == PlanningViewMode.week) {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    } else {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }
    notifyListeners();
  }

  void previous() {
    if (_viewMode == PlanningViewMode.day) {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    } else if (_viewMode == PlanningViewMode.week) {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    } else {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    }
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  void copyActivity(PlanningActivity activity) {
    _clipboardActivity = activity;
    notifyListeners();
  }

  Future<bool> pasteActivity(DateTime targetDate) async {
    if (_clipboardActivity == null) return false;
    
    final newActivity = _clipboardActivity!.copyWithDate(targetDate);
    // On ne synchronise pas forcément l'agenda par défaut lors d'un coller, 
    // ou on peut laisser le choix. Ici on simplifie.
    return await addActivity(newActivity);
  }

  void clearClipboard() {
    _clipboardActivity = null;
    notifyListeners();
  }
}
