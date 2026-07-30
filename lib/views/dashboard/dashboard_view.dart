import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/views/login/login_view.dart';
import 'package:flutter01/views/planning/planning_view.dart';
import 'package:flutter01/views/navigation/navigation_view.dart';
import 'package:flutter01/views/vehicle/vehicle_view.dart';
import 'package:flutter01/views/contact/contact_view.dart';
import 'package:flutter01/views/documents/document_view.dart';
import 'package:flutter01/views/subscription/paywall_view.dart';
import 'package:flutter01/views/admin/fleet_admin_view.dart';
import 'package:flutter01/views/admin/super_admin_view.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/subscription_viewmodel.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/viewmodels/fleet_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/super_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/locale_viewmodel.dart';
import 'package:flutter01/models/subscription_tier.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Rafraîchir le profil à chaque arrivée sur le Dashboard pour capter les changements de tier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginViewModel>(context, listen: false).refreshProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginViewModel>(context).currentUser;
    final subVM = Provider.of<SubscriptionViewModel>(context);
    final tier = subVM.currentUser?.tier ?? user?.tier ?? SubscriptionTier.free;
// ...

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/icon/logoMMCGo.png'),
        ),
        title: Text('MMC Go - ${l10n.dashboard}'),
        actions: [
          _buildTierBadge(context, tier),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              Provider.of<LocaleViewModel>(context, listen: false).clearLocale();
            },
            tooltip: l10n.changeLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final loginVM = Provider.of<LoginViewModel>(context, listen: false);
              final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
              final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
              final fleetVM = Provider.of<FleetAdminViewModel>(context, listen: false);
              final superAdminVM = Provider.of<SuperAdminViewModel>(context, listen: false);

              await loginVM.logout();
              planningVM.clear();
              vehicleVM.clear();
              fleetVM.clear();
              superAdminVM.clear();

              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _buildToolCard(
            context,
            l10n.navigation,
            Icons.map,
            Colors.purple,
            isLocked: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationView()),
            ),
          ),
          _buildToolCard(
            context,
            l10n.planning,
            Icons.calendar_month,
            Colors.blue,
            isLocked: tier.index < SubscriptionTier.professional.index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanningView()),
            ),
          ),
          _buildToolCard(
            context,
            l10n.vehicle,
            Icons.directions_bus,
            Theme.of(context).primaryColor,
            isLocked: tier.index < SubscriptionTier.professional.index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VehicleView()),
            ),
          ),
          _buildToolCard(
            context,
            l10n.documents,
            Icons.description,
            Colors.orange,
            isLocked: tier.index < SubscriptionTier.professional.index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentView()),
            ),
          ),
          _buildToolCard(
            context,
            l10n.contact,
            Icons.contact_phone,
            Colors.red,
            isLocked: tier.index < SubscriptionTier.professional.index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactView()),
            ),
          ),
          _buildToolCard(
            context,
            l10n.changeLanguage,
            Icons.language,
            Colors.teal,
            isLocked: false,
            onTap: () {
              Provider.of<LocaleViewModel>(context, listen: false).clearLocale();
            },
          ),
          if (tier == SubscriptionTier.diamond)
            _buildToolCard(
              context,
              l10n.administration,
              Icons.admin_panel_settings,
              Colors.blueGrey,
              isLocked: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FleetAdminView()),
              ).then((_) => Provider.of<LoginViewModel>(context, listen: false).refreshProfile(context)),
            ),
          if (user?.isSuperAdmin ?? false)
            _buildToolCard(
              context,
              l10n.superAdmin,
              Icons.security,
              Colors.black87,
              isLocked: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SuperAdminView()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(BuildContext context, SubscriptionTier tier) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallView())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            tier.displayName.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color,
      {required bool isLocked, VoidCallback? onTap}) {
    return Card(
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: isLocked
            ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallView()))
            : onTap,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 45, color: isLocked ? Colors.grey : color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.lock, size: 20, color: Colors.amber),
              ),
          ],
        ),
      ),
    );
  }
}
