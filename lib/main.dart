import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/planning_viewmodel.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/document_viewmodel.dart';
import 'viewmodels/subscription_viewmodel.dart';
import 'viewmodels/fleet_admin_viewmodel.dart';
import 'viewmodels/super_admin_viewmodel.dart';
import 'services/stripe_service.dart';
import 'services/supabase_service.dart';
import 'views/login/login_view.dart';
import 'views/navigation/navigation_view.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // On initialise d'abord les formats de date
    await initializeDateFormatting('fr_FR', null);
    
    // Initialisation des services avec gestion d'erreur isolée
    await _initServices();

    final vehicleVM = VehicleViewModel();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => vehicleVM),
          ChangeNotifierProvider(create: (_) => PlanningViewModel(vehicleViewModel: vehicleVM)),
          ChangeNotifierProvider(create: (_) => NavigationViewModel()),
          ChangeNotifierProvider(create: (_) => DocumentViewModel()),
          ChangeNotifierProvider(create: (_) => SubscriptionViewModel()),
          ChangeNotifierProvider(create: (_) => FleetAdminViewModel()),
          ChangeNotifierProvider(create: (_) => SuperAdminViewModel()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('ERREUR FATALE AU DÉMARRAGE : $e');
    // On lance quand même l'app en mode dégradé si possible
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Erreur de chargement. Veuillez rafraîchir.')))));
  }
}

Future<void> _initServices() async {
  // Supabase
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Supabase Error: $e');
  }

  // Stripe
  try {
    await StripeService.init();
  } catch (e) {
    debugPrint('Stripe Error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMC Go Drivers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A859),
          primary: const Color(0xFF00A859),
          secondary: const Color(0xFF1B5E20),
          tertiary: const Color(0xFFFFD600),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00A859),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const NavigationView(),
    );
  }
}
