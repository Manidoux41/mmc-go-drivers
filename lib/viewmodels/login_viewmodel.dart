import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/services/mongo_auth_service.dart';
import 'planning_viewmodel.dart';
import 'vehicle_viewmodel.dart';
import 'fleet_admin_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginViewModel() {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final userId = await MongoAuthService.getCurrentSessionUserId();
      if (userId != null) {
        await _fetchProfile(userId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur vérification session : $e");
    }
  }

  Future<bool> login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profileData = await MongoAuthService.signIn(
        email: email,
        password: password,
      );

      if (profileData != null) {
        _currentUser = User.fromJson(profileData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Identifiants incorrects";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      debugPrint("Erreur connexion : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String fullName) async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    print('LoginViewModel: Starting register for $email');
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "L'email et le mot de passe sont requis";
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _errorMessage = "Le mot de passe doit faire au moins 6 caractères";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('LoginViewModel: Calling MongoAuthService.signUp...');
      final profileData = await MongoAuthService.signUp(
        email: email,
        password: password,
        metadata: {
          'full_name': fullName,
          'tier': 'free',
        },
      );

      if (profileData != null) {
        print('LoginViewModel: signUp successful, mapping user...');
        _currentUser = User.fromJson(profileData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Une erreur inconnue est survenue lors de l'inscription";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      print('LoginViewModel: Error during registration: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshProfile(BuildContext context) async {
    if (_currentUser != null) {
      await _fetchProfile(_currentUser!.id);
      
      if (_currentUser != null && context.mounted) {
        final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
        final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
        final fleetVM = Provider.of<FleetAdminViewModel>(context, listen: false);
        
        // Configuration des clients (Diamant vs Master)
        planningVM.setCustomClient(_currentUser!.customMongoUri);
        vehicleVM.setCustomClient(_currentUser!.customMongoUri);
        fleetVM.setCustomClient(_currentUser!.customMongoUri);

        // Crucial : Définir le conducteur actuel pour le planning
        planningVM.setCurrentDriver(_currentUser!.id);

        // Forcer la récupération des véhicules pour cet utilisateur précis
        await vehicleVM.fetchVehicles(ownerId: _currentUser!.id);
      }

      notifyListeners();
    }
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await MongoService.profiles.findOne(where.eq('id', userId));
      
      if (data != null) {
        _currentUser = User.fromJson(data);
        debugPrint("Profil chargé : ${_currentUser?.username} - Tier: ${_currentUser?.tier.name}");
      }
    } catch (e) {
      debugPrint("Erreur critique fetch profile : ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await MongoAuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
