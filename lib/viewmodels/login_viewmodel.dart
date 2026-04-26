import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login() async {
    debugPrint("Tentative de connexion avec : ${usernameController.text}");
    
    _isLoading = true;
    notifyListeners();

    // Simulation d'un petit délai
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
    
    debugPrint("Connexion réussie (simulation)");
    return true;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
