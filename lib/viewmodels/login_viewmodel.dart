import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user.dart';
import '../services/supabase_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
        _isLoading = false;
        notifyListeners();
        return true;
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

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      _currentUser = User.fromJson(data);
    } catch (e) {
      debugPrint("Erreur fetch profile : ${e.toString()}");
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
