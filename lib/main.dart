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
import 'services/stripe_service.dart';
import 'services/supabase_service.dart';
import 'views/login/login_view.dart';
import 'views/navigation/navigation_view.dart';

void main() async {
  // Nécessaire pour initialiser le formatage des dates en français
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  // Initialisation de Supabase
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Erreur Supabase : ${e.toString()}');
  }

  // Initialisation de Stripe (pourrait échouer si pas de clés, donc on catch)
  try {
    await StripeService.init();
  } catch (e) {
    debugPrint('Stripe non initialisé : ${e.toString()}');
  }

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
      ],
      child: const MyApp(),
    ),
  );
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
          seedColor: const Color(0xFF00A859), // Vert MMC Go
          primary: const Color(0xFF00A859),
          secondary: const Color(0xFF1B5E20),
          tertiary: const Color(0xFFFFD600), // Accentuation possible (Jaune "Go")
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00A859),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A859),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: NavigationView(),
    );
  }
}
