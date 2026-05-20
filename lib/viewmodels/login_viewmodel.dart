import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
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

  LoginViewModel() {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final session = SupabaseService.client.auth.currentSession;
      if (session?.user != null) {
        await _fetchProfile(session!.user.id);
        // Le Dashboard s'occupera de la synchronisation via refreshProfile au démarrage
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
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _fetchProfile(response.user!.id);
        
        if (_currentUser != null) {
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Erreur connexion : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String fullName) async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return false;
    if (password.length < 6) {
      debugPrint("Le mot de passe doit faire au moins 6 caractères");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        // Petit délai pour laisser le trigger Supabase créer le profil
        await Future.delayed(const Duration(seconds: 1));
        await _fetchProfile(response.user!.id);
        
        if (_currentUser == null) {
          debugPrint("ATTENTION : Utilisateur créé mais profil introuvable. Avez-vous exécuté le script SQL ?");
          // Création manuelle du profil en secours si RLS le permet
          try {
            await SupabaseService.client.from('profiles').insert({
              'id': response.user!.id,
              'username': email,
              'full_name': fullName,
              'tier': 'free'
            });
            await _fetchProfile(response.user!.id);
          } catch (e) {
            debugPrint("Échec de la création manuelle du profil : $e");
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return _currentUser != null;
      }
    } catch (e) {
      debugPrint("Erreur inscription : ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> refreshProfile(BuildContext context) async {
    if (_currentUser != null) {
      await _fetchProfile(_currentUser!.id);
      
      if (_currentUser != null && context.mounted) {
        final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
        final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
        final fleetVM = Provider.of<FleetAdminViewModel>(context, listen: false);
        
        // Configuration des clients (Diamant vs Master)
        planningVM.setCustomClient(_currentUser!.customSupabaseUrl, _currentUser!.customSupabaseAnonKey);
        vehicleVM.setCustomClient(_currentUser!.customSupabaseUrl, _currentUser!.customSupabaseAnonKey);
        fleetVM.setCustomClient(_currentUser!.customSupabaseUrl, _currentUser!.customSupabaseAnonKey);

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
      // On sélectionne explicitement tous les champs pour être sûr d'avoir le tier à jour
      final data = await SupabaseService.client
          .from('profiles')
          .select('id, username, full_name, tier, custom_supabase_url, custom_supabase_anon_key')
          .eq('id', userId)
          .maybeSingle();
      
      if (data != null) {
        _currentUser = User.fromJson(data);
        debugPrint("Profil chargé : ${_currentUser?.username} - Tier: ${_currentUser?.tier.name}");
      }
    } catch (e) {
      debugPrint("Erreur critique fetch profile : ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
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
