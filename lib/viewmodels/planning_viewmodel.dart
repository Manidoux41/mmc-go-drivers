import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/planning_activity.dart';
import '../models/vehicle.dart';
import 'vehicle_viewmodel.dart';

enum PlanningViewMode { day, week, month }

class PlanningViewModel extends ChangeNotifier {
  final VehicleViewModel vehicleViewModel;
  
  DateTime _selectedDate = DateTime.now();
  PlanningViewMode _viewMode = PlanningViewMode.day;

  final String _depotLocation = "Chateaudun (Dépôt)";

  PlanningViewModel({required this.vehicleViewModel});

  List<PlanningActivity> get _allActivities => [
        ..._generateDayActivities(DateTime.now()),
        ..._generateDayActivities(DateTime.now().add(const Duration(days: 1))),
        ..._generateDayActivities(DateTime.now().subtract(const Duration(days: 1))),
      ];

  List<PlanningActivity> _generateDayActivities(DateTime date) {
    DateTime day = DateTime(date.year, date.month, date.day);
    
    // On récupère un véhicule au hasard pour la journée pour la démo
    final vehicle = vehicleViewModel.vehicles[date.day % vehicleViewModel.vehicles.length];
    
    // 1. Prise de Service (PS) - 10 min
    DateTime psStart = day.add(const Duration(hours: 7, minutes: 0));
    DateTime psEnd = psStart.add(const Duration(minutes: 10));
    
    // ... rest of the timing logic stays same ...
    DateTime hlp1Start = psEnd;
    DateTime hlp1End = hlp1Start.add(const Duration(minutes: 15));
    DateTime trip1Start = hlp1End;
    DateTime trip1End = trip1Start.add(const Duration(hours: 1, minutes: 30));
    DateTime trip2Start = trip1End.add(const Duration(minutes: 15));
    DateTime trip2End = trip2Start.add(const Duration(hours: 2));
    DateTime nettoyageStart = trip2End;
    DateTime nettoyageEnd = nettoyageStart.add(const Duration(minutes: 20));
    DateTime hlp2Start = nettoyageEnd;
    DateTime hlp2End = hlp2Start.add(const Duration(minutes: 15));
    DateTime fsStart = hlp2End;
    DateTime fsEnd = fsStart.add(const Duration(minutes: 5));

    return [
      PlanningActivity(
        id: '${date.day}-PS',
        title: 'Prise de Service (PS)',
        type: ActivityType.ps,
        startTime: psStart,
        endTime: psEnd,
      ),
      PlanningActivity(
        id: '${date.day}-HLP1',
        title: 'HLP - Mise en place',
        type: ActivityType.hlp,
        startTime: hlp1Start,
        endTime: hlp1End,
        departure: _depotLocation,
        arrival: 'Gare Routière',
        vehicle: vehicle,
      ),
      PlanningActivity(
        id: '${date.day}-T1',
        title: 'Ligne 102 - Scolaire',
        type: ActivityType.trip,
        startTime: trip1Start,
        endTime: trip1End,
        departure: 'Gare Routière',
        arrival: 'Lycée Mistral',
        vehicle: vehicle,
      ),
      PlanningActivity(
        id: '${date.day}-T2',
        title: 'Navette Inter-urbaine',
        type: ActivityType.trip,
        startTime: trip2Start,
        endTime: trip2End,
        departure: 'Lycée Mistral',
        arrival: 'Centre Commercial',
        vehicle: vehicle,
      ),
      PlanningActivity(
        id: '${date.day}-BC',
        title: 'BC - Transport Touristique',
        type: ActivityType.bc,
        startTime: trip2End.add(const Duration(minutes: 30)),
        endTime: trip2End.add(const Duration(hours: 3)),
        departure: 'Office de Tourisme',
        arrival: 'Château de Châteaudun',
        vehicle: vehicle,
        stops: [
          Waypoint(name: 'Office de Tourisme', location: LatLng(48.071, 1.328)),
          Waypoint(name: 'Musée des Beaux-Arts', location: LatLng(48.075, 1.332)),
          Waypoint(name: 'Château de Châteaudun', location: LatLng(48.069, 1.325)),
        ],
      ),
      PlanningActivity(
        id: '${date.day}-NET',
        title: 'Nettoyage véhicule',
        type: ActivityType.nettoyage,
        startTime: nettoyageStart,
        endTime: nettoyageEnd,
        vehicle: vehicle,
      ),
      PlanningActivity(
        id: '${date.day}-HLP2',
        title: 'HLP - Retour Dépôt',
        type: ActivityType.hlp,
        startTime: hlp2Start,
        endTime: hlp2End,
        departure: 'Centre Commercial',
        arrival: _depotLocation,
        vehicle: vehicle,
      ),
      PlanningActivity(
        id: '${date.day}-FS',
        title: 'Fin de Service (FS)',
        type: ActivityType.fs,
        startTime: fsStart,
        endTime: fsEnd,
      ),
    ];
  }

  DateTime get selectedDate => _selectedDate;
  PlanningViewMode get viewMode => _viewMode;

  List<PlanningActivity> get filteredActivities {
    return _allActivities.where((activity) {
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
