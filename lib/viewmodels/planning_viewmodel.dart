import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
    // Si le chauffeur n'est pas encore défini, on ne peut pas charger son planning
    if (_currentDriverId == null) {
      debugPrint("FETCH SKIPPED : DriverId is null");
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(">>> SYNC START : Récupération pour $_currentDriverId");
      
      // On récupère tout pour être sûr de ne rien rater
      final response = await _db.from('activities').select();
      final List<dynamic> allData = response as List;
      
      debugPrint(">>> SYNC INFO : ${allData.length} lignes totales en BDD");

      _activities = allData
          .where((json) {
            // Filtrage manuel pour être sûr de l'ID
            final String? dbDriverId = json['driver_id']?.toString();
            return dbDriverId == _currentDriverId;
          })
          .map((json) {
            try {
              final vehicleId = json['vehicle_id'];
              Vehicle? vehicle;
              if (vehicleId != null && vehicleViewModel.vehicles.isNotEmpty) {
                try {
                  vehicle = vehicleViewModel.vehicles.firstWhere((v) => v.id == vehicleId);
                } catch (_) {}
              }
              return PlanningActivity.fromJson(json, vehicle: vehicle);
            } catch (e) {
              debugPrint(">>> ERROR PARSING : $e");
              // Fallback minimal en cas d'erreur de parsing JSON
              return PlanningActivity(
                id: json['id']?.toString() ?? 'err',
                title: json['title']?.toString() ?? 'Erreur',
                type: ActivityType.trip,
                startTime: DateTime.tryParse(json['start_time']?.toString() ?? '') ?? DateTime.now(),
                endTime: DateTime.tryParse(json['end_time']?.toString() ?? '') ?? DateTime.now(),
                driverId: _currentDriverId,
              );
            }
          }).toList();
      
      debugPrint(">>> SYNC SUCCESS : ${_activities.length} activités pour vous");
    } catch (e) {
      debugPrint(">>> SYNC ERROR : $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadPhotoPlanning(DateTime date, {ImageSource source = ImageSource.camera}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

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
        debugPrint("IMAGE PICKED : ${imageFile.path}");
        
        // 1. Image -> PDF
        final pdfFile = await PdfService.imageToPdf(imageFile);

        if (pdfFile != null) {
          debugPrint("PDF GENERATED : ${pdfFile.path}");
          
          // 2. Upload to Storage
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'planning_${_currentDriverId}_$timestamp.pdf';
          
          final storageClient = _db.storage;
          final String? storagePath = await _uploadToClientStorage(storageClient, pdfFile, fileName);

          if (storagePath != null) {
            debugPrint("UPLOAD SUCCESS : $storagePath");
            
            // 3. Create Activity
            final activity = PlanningActivity(
              id: '', 
              title: 'Planning Photo du ${date.day}/${date.month}',
              type: ActivityType.photo_planning,
              // Forcer un horaire précis pour éviter les conflits de fuseau horaire
              startTime: DateTime(date.year, date.month, date.day, 0, 0, 1),
              endTime: DateTime(date.year, date.month, date.day, 23, 59, 59),
              driverId: _currentDriverId,
              filePath: storagePath,
            );

            await addActivity(activity);
          } else {
            debugPrint("UPLOAD FAILED");
          }
        } else {
          debugPrint("PDF GENERATION FAILED");
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
      // 1. Vérifier si le bucket existe, sinon le créer
      final List<Bucket> buckets = await storage.listBuckets();
      final bool exists = buckets.any((b) => b.id == 'plannings');
      
      if (!exists) {
        debugPrint("STORAGE : Création du bucket 'plannings'...");
        await storage.createBucket('plannings', const BucketOptions(public: true));
      }
      
      // 2. Upload du fichier
      final path = await storage.from('plannings').upload(fileName, file);
      debugPrint("STORAGE : Upload réussi sur le chemin : $path");
      return path;
    } catch (e) {
      debugPrint('STORAGE ERROR FATALE : $e');
      // Tentative désespérée : si l'erreur était juste la vérification, essayer l'upload direct
      try {
        final path = await storage.from('plannings').upload(fileName, file);
        return path;
      } catch (_) {
        return null;
      }
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
      // 1. Trouver l'activité pour voir s'il y a un fichier attaché
      final activity = _activities.firstWhere((a) => a.id == activityId);
      
      // 2. Supprimer le fichier du storage si présent
      if (activity.filePath != null) {
        try {
          await _db.storage.from('plannings').remove([activity.filePath!]);
          debugPrint("STORAGE : Fichier supprimé : ${activity.filePath}");
        } catch (e) {
          debugPrint("STORAGE ERROR : Impossible de supprimer le fichier : $e");
        }
      }

      // 3. Supprimer de la base de données
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
    debugPrint("FILTERING for date: $_selectedDate");
    debugPrint("TOTAL ACTIVITIES available: ${_activities.length}");
    
    final results = _activities.where((activity) {
      if (_viewMode == PlanningViewMode.day) {
        final isSameDay = activity.startTime.year == _selectedDate.year &&
            activity.startTime.month == _selectedDate.month &&
            activity.startTime.day == _selectedDate.day;
        return isSameDay;
      } else if (_viewMode == PlanningViewMode.week) {
        final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        final weekEnd = weekStart.add(const Duration(days: 7));
        return activity.startTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            activity.startTime.isBefore(weekEnd);
      } else {
        return activity.startTime.year == _selectedDate.year &&
            activity.startTime.month == _selectedDate.month;
      }
    }).toList();
    
    debugPrint("FILTERED RESULTS: ${results.length}");
    
    return results..sort((a, b) {
      if (a.type == ActivityType.photo_planning) return -1;
      if (b.type == ActivityType.photo_planning) return 1;
      return a.startTime.compareTo(b.startTime);
    });
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

  Future<void> pickAndUploadPdf(DateTime date) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null && _currentDriverId != null) {
        _isLoading = true;
        notifyListeners();

        final File pdfFile = File(result.files.single.path!);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'planning_upload_${_currentDriverId}_$timestamp.pdf';
        
        final storageClient = _db.storage;
        final String? storagePath = await _uploadToClientStorage(storageClient, pdfFile, fileName);

        if (storagePath != null) {
          final activity = PlanningActivity(
            id: '',
            title: 'Planning PDF importé (${date.day}/${date.month})',
            type: ActivityType.photo_planning,
            startTime: DateTime(date.year, date.month, date.day, 0, 0, 1),
            endTime: DateTime(date.year, date.month, date.day, 23, 59, 59),
            driverId: _currentDriverId,
            filePath: storagePath,
          );

          await addActivity(activity);
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur import PDF : $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  String getPublicUrl(String path) {
    return _db.storage.from('plannings').getPublicUrl(path);
  }
}
