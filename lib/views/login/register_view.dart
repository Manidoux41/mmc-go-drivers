import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Image.asset('assets/icon/logoMMCGo.png', height: 100),
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
                prefixIcon: Icon(Icons.badge, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Identifiant / Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock_clock, color: Theme.of(context).primaryColor),
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
                      
                      // Synchronisation des identifiants avec le ViewModel
                      viewModel.usernameController.text = _emailController.text;
                      viewModel.passwordController.text = _passwordController.text;

                      final success = await viewModel.register(_fullNameController.text);
                      
                      if (!mounted) return;

                      if (success) {
                        // Synchronisation du user avec le SubscriptionViewModel
                        final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                        subVM.setUser(viewModel.currentUser!);

                        // Synchronisation avec le PlanningViewModel pour le calendrier individuel
                        final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                        planningVM.setCurrentDriver(viewModel.currentUser!.id);

                        // Chargement initial des véhicules
                        final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                        vehicleVM.fetchVehicles();

                        // Redirection vers le Paywall comme demandé pour les nouveaux utilisateurs sans forfait
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PaywallView()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
