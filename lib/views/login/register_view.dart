import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../subscription/paywall_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Rejoignez MMC Go Drivers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.badge, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Identifiant / Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_clock, color: Colors.green),
              ),
            ),
            const SizedBox(height: 40),
            viewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                        );
                        return;
                      }
                      
                      // On utilise le login existant pour simuler la création + connexion
                      viewModel.usernameController.text = _emailController.text;
                      final success = await viewModel.login();
                      
                      if (success && mounted) {
                        // Synchronisation du user avec le SubscriptionViewModel
                        final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                        subVM.setUser(viewModel.currentUser!);

                        // Redirection vers le Paywall comme demandé pour les nouveaux utilisateurs sans forfait
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PaywallView()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('S\'INSCRIRE ET CHOISIR UN FORFAIT'),
                  ),
          ],
        ),
      ),
    );
  }
}
