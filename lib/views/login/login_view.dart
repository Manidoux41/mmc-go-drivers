import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../viewmodels/fleet_admin_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../models/subscription_tier.dart';
import '../../models/user.dart';
import '../dashboard/dashboard_view.dart';
import '../admin/admin_settings_view.dart';
import '../subscription/paywall_view.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo MMC Go Drivers
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/logoMMCGo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MMC Go Drivers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'L\'outil universel des transporteurs',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSettingsView()),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Configuration DB'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: viewModel.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Identifiant',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: viewModel.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  viewModel.isLoading
                      ? CircularProgressIndicator(color: Theme.of(context).primaryColor)
                      : ElevatedButton(
                          onPressed: () async {
                            final success = await viewModel.login();

                            if (success && context.mounted) {
                              // Synchronisation du user avec le SubscriptionViewModel
                              final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                              subVM.setUser(viewModel.currentUser!);

                              // Synchronisation avec le PlanningViewModel pour le calendrier individuel
                              final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                              planningVM.setCurrentDriver(viewModel.currentUser!.id);

                              // Chargement initial des véhicules
                              final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                              vehicleVM.fetchVehicles();

                              // Redirection systématique vers le Dashboard pour les utilisateurs déjà inscrits
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const DashboardView()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'SE CONNECTER',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterView()),
                          );
                        },
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
