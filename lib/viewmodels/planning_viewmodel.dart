import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, where;
import 'package:flutter01/models/planning_activity.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/services/pdf_service.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';

enum PlanningViewMode { day, week, month }

class PlanningViewModel extends ChangeNotifier {
  final VehicleViewModel vehicleViewModel;
  String? _currentDriverId;
  Db? _customClient; // Client spécifique pour Diamant décentralisé
  
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

  DbCollection _getCollection(String name) {
    if (_customClient != null) {
      return _customClient!.collection(name);
    }
    return MongoService.db.collection(name);
  }

  void setCustomClient(String? uri) async {
    if (uri != null) {
      _customClient = await MongoService.createClient(uri);
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
    if (_currentDriverId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _getCollection('activities')
          .find(where.eq('driver_id', _currentDriverId!))
          .toList();
      
      _activities = response.map((json) {
        final vehicleId = json['vehicle_id'];
        Vehicle? vehicle;
        if (vehicleId != null && vehicleViewModel.vehicles.isNotEmpty) {
          try {
            vehicle = vehicleViewModel.vehicles.firstWhere((v) => v.id == vehicleId);
          } catch (_) {}
        }
        return PlanningActivity.fromJson(json, vehicle: vehicle);
      }).toList();
    } catch (e) {
      debugPrint("FETCH ERROR : $e");
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
          
          // 2. Upload (Simulation de stockage)
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'planning_${_currentDriverId}_$timestamp.pdf';
          
          // Dans une version MongoDB Atlas, on stockerait soit en GridFS, soit on uploaderait vers S3
          // Pour l'instant, on stocke le nom du fichier comme référence
          final String storagePath = fileName; 

          debugPrint("UPLOAD SUCCESS : $storagePath");
          
          // 3. Create Activity
          final activity = PlanningActivity(
            id: '', 
            title: 'Planning Photo du ${date.day}/${date.month}',
            type: ActivityType.photo_planning,
            startTime: DateTime(date.year, date.month, date.day, 0, 0, 1),
            endTime: DateTime(date.year, date.month, date.day, 23, 59, 59),
            driverId: _currentDriverId,
            filePath: storagePath,
          );

          await addActivity(activity);
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

  Future<bool> addActivity(PlanningActivity activity, {bool syncToCalendar = false}) async {
    try {
      final json = activity.toJson();
      if (_currentDriverId != null && json['driver_id'] == null) {
        json['driver_id'] = _currentDriverId;
      }
      
      await _getCollection('activities').insertOne(json);
      
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
      await _getCollection('activities').deleteOne(where.eq('id', activityId));
      await fetchActivities();
      return true;
    } catch (e) {
      debugPrint("ERREUR SUPPRESSION ACTIVITÉ : ${e.toString()}");
      return false;
    }
  }

  Future<bool> updateActivity(PlanningActivity activity) async {
    try {
      await _getCollection('activities').replaceOne(
        where.eq('id', activity.id),
        activity.toJson(),
      );
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
    final results = _activities.where((activity) {
      if (_viewMode == PlanningViewMode.day) {
        return activity.startTime.year == _selectedDate.year &&
            activity.startTime.month == _selectedDate.month &&
            activity.startTime.day == _selectedDate.day;
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
    
    return results..sort((a, b) {
      if (a.type == ActivityType.photo_planning) return -1;
      if (b.type == ActivityType.photo_planning) return 1;
      return a.startTime.compareTo(b.startTime);
    });
  }

  List<String> checkRSE(List<PlanningActivity> activities) {
    if (activities.isEmpty) return [];
    List<String> warnings = [];

    activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    final first = activities.first.startTime;
    final last = activities.last.endTime;
    final amplitude = last.difference(first);
    if (amplitude.inHours > 12) {
      warnings.add("Amplitude de ${amplitude.inHours}h dépasse la recommandation (12h).");
    }

    Duration totalDriving = Duration.zero;
    for (var a in activities) {
      if (a.isDriving) {
        totalDriving += a.duration;
      }
    }
    if (totalDriving.inHours >= 9) {
      warnings.add("Conduite totale (${totalDriving.inHours}h ${totalDriving.inMinutes % 60}m) proche ou dépasse 9h.");
    }

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

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
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
    return await addActivity(newActivity);
  }

  Future<void> pickAndUploadPdf(DateTime date) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null && _currentDriverId != null) {
        _isLoading = true;
        notifyListeners();

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'planning_upload_${_currentDriverId}_$timestamp.pdf';
        
        final activity = PlanningActivity(
          id: '',
          title: 'Planning PDF importé (${date.day}/${date.month})',
          type: ActivityType.photo_planning,
          startTime: DateTime(date.year, date.month, date.day, 0, 0, 1),
          endTime: DateTime(date.year, date.month, date.day, 23, 59, 59),
          driverId: _currentDriverId,
          filePath: fileName,
        );

        await addActivity(activity);

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
    // Dans une version cloud, on générerait une URL signée ou publique
    return path;
  }
}
