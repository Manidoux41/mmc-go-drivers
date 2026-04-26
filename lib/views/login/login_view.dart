import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../models/subscription_tier.dart';
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
                  // Emplacement pour l'icône MMC Go Drivers
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 60, color: Colors.green.shade800),
                        Positioned(
                          right: 35,
                          bottom: 35,
                          child: Icon(Icons.local_taxi, size: 30, color: Colors.green.shade600),
                        ),
                        Positioned(
                          left: 35,
                          bottom: 35,
                          child: Icon(Icons.local_shipping, size: 30, color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MMC Go Drivers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
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
                      prefixIcon: const Icon(Icons.person, color: Colors.green),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : ElevatedButton(
                          onPressed: () async {
                            final success = await viewModel.login();
                            if (success && context.mounted) {
                              // Synchronisation du user avec le SubscriptionViewModel
                              final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                              subVM.setUser(viewModel.currentUser!);

                              // Synchronisation avec le PlanningViewModel pour le calendrier individuel
                              final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                              planningVM.setCurrentDriver(viewModel.currentUser!.username);

                              if (viewModel.currentUser!.tier == SubscriptionTier.free) {
                                // Rediriger vers le Paywall si aucun forfait (free)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PaywallView()),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardView()),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
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
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
