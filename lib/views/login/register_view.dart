import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/subscription_viewmodel.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/views/subscription/paywall_view.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Image.asset('assets/icon/logoMMCGo.png', height: 100),
            const SizedBox(height: 20),
            Text(
              l10n.joinMMC,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.badge, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '${l10n.username} / ${l10n.email}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
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
                          SnackBar(content: Text(l10n.passwordsDoNotMatch)),
                        );
                        return;
                      }
                      
                      // Synchronisation des identifiants avec le ViewModel
                      viewModel.usernameController.text = _emailController.text;
                      viewModel.passwordController.text = _passwordController.text;

                      final success = await viewModel.register(_fullNameController.text);
                      
                      if (!mounted) return;

                      if (success) {
                        // ... existing success logic ...
                        final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
                        subVM.setUser(viewModel.currentUser!);

                        final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
                        planningVM.setCurrentDriver(viewModel.currentUser!.id);

                        final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                        vehicleVM.fetchVehicles(ownerId: viewModel.currentUser!.id);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PaywallView()),
                          (route) => false,
                        );
                      } else if (viewModel.errorMessage != null) {
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.registerAndChoosePlan),
                  ),
          ],
        ),
      ),
    );
  }
}
