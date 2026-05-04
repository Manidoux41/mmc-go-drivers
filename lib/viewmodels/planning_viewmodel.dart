import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../models/planning_activity.dart';
import '../models/vehicle.dart';
import '../services/supabase_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import 'vehicle_viewmodel.dart';

enum PlanningViewMode { day, week, month }

class PlanningViewModel extends ChangeNotifier {
  final VehicleViewModel vehicleViewModel;
  String? _currentDriverId;
  
  DateTime _selectedDate = DateTime.now();
  PlanningViewMode _viewMode = PlanningViewMode.day;

  List<PlanningActivity> _activities = [];
  bool _isLoading = false;

  PlanningViewModel({required this.vehicleViewModel});

  DateTime get selectedDate => _selectedDate;
  PlanningViewMode get viewMode => _viewMode;
  List<PlanningActivity> get allActivities => _activities;
  bool get isLoading => _isLoading;

  void setCurrentDriver(String? driverId) {
    _currentDriverId = driverId;
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = SupabaseService.client.from('activities').select();
      
      if (_currentDriverId != null) {
        query = query.eq('driver_id', _currentDriverId!);
      }

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
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && _currentDriverId != null) {
      _isLoading = true;
      notifyListeners();

      try {
        // 1. Image -> PDF
        final pdfFile = await PdfService.imageToPdf(File(pickedFile.path));

        // 2. Upload to Storage
        final fileName = 'planning_${_currentDriverId}_${date.millisecondsSinceEpoch}.pdf';
        final storagePath = await StorageService.uploadPlanningPdf(pdfFile, fileName);

        if (storagePath != null) {
          // 3. Create Activity
          final activity = PlanningActivity(
            id: '', // Supabase générera l'id
            title: 'Planning Photo du ${date.day}/${date.month}',
            type: ActivityType.photo_planning,
            startTime: date.copyWith(hour: 8),
            endTime: date.copyWith(hour: 18),
            driverId: _currentDriverId,
            filePath: storagePath,
          );

          await addActivity(activity);
        }
      } catch (e) {
        debugPrint("Erreur upload photo planning : $e");
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(PlanningActivity activity) async {
    try {
      await SupabaseService.client
          .from('activities')
          .insert(activity.toJson());
      
      await fetchActivities();
    } catch (e) {
      debugPrint("Erreur add activity : ${e.toString()}");
    }
  }

  Future<void> removeActivity(String activityId) async {
    try {
      await SupabaseService.client
          .from('activities')
          .delete()
          .eq('id', activityId);
      
      await fetchActivities();
    } catch (e) {
      debugPrint("Erreur remove activity : ${e.toString()}");
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
}
