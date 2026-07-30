import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/subscription_viewmodel.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/fleet_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/viewmodels/locale_viewmodel.dart';
import 'package:flutter01/models/subscription_tier.dart';
import 'package:flutter01/models/user.dart';
import 'package:flutter01/views/dashboard/dashboard_view.dart';
import 'package:flutter01/views/admin/admin_settings_view.dart';
import 'package:flutter01/views/subscription/paywall_view.dart';
import 'package:flutter01/views/login/register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                          color: Colors.black.withValues(alpha: 0.1),
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
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.universalTool,
                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.language, size: 20, color: Colors.blueGrey),
                        onPressed: () {
                          Provider.of<LocaleViewModel>(context, listen: false).clearLocale();
                        },
                        tooltip: l10n.changeLanguage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSettingsView()),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: Text(l10n.dbConfig),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: viewModel.usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
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
                      labelText: l10n.password,
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
                              // ... existing success logic ...
                              final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                              subVM.setUser(viewModel.currentUser!);

                              final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                              planningVM.setCustomClient(viewModel.currentUser!.customMongoUri);
                              planningVM.setCurrentDriver(viewModel.currentUser!.id);

                              final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                              vehicleVM.setCustomClient(viewModel.currentUser!.customMongoUri);
                              vehicleVM.fetchVehicles(ownerId: viewModel.currentUser!.id);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const DashboardView()),
                              );
                            } else if (viewModel.errorMessage != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
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
                          child: Text(
                            l10n.loginAction,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                  ElevatedButton.icon(
                    onPressed: () => Provider.of<LocaleViewModel>(context, listen: false).clearLocale(),
                    icon: const Icon(Icons.language),
                    label: const Text('CHOISIR LA LANGUE / SELECT LANGUAGE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      foregroundColor: Colors.teal,
                      minimumSize: const Size(200, 45),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterView()),
                          );
                        },
                        child: Text(
                          l10n.register,
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
