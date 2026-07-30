import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/navigation_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/viewmodels/document_viewmodel.dart';
import 'package:flutter01/viewmodels/subscription_viewmodel.dart';
import 'package:flutter01/viewmodels/fleet_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/super_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/locale_viewmodel.dart';
import 'package:flutter01/services/stripe_service.dart';
import 'package:flutter01/services/mongo_service.dart';
import 'package:flutter01/views/navigation/navigation_view.dart';
import 'package:flutter01/views/language/language_selection_view.dart';
import 'package:flutter01/config/colors.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // On initialise d'abord les formats de date
    await initializeDateFormatting('fr_FR', null);
    
    // Initialisation des services avec gestion d'erreur isolée
    await _initServices();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleViewModel()),
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => VehicleViewModel()),
          ChangeNotifierProxyProvider<VehicleViewModel, PlanningViewModel>(
            create: (context) => PlanningViewModel(
              vehicleViewModel: Provider.of<VehicleViewModel>(context, listen: false),
            ),
            update: (_, __, planningVM) => planningVM!,
          ),
          ChangeNotifierProxyProvider<LoginViewModel, SubscriptionViewModel>(
            create: (_) => SubscriptionViewModel(),
            update: (_, loginVM, subVM) {
              if (loginVM.currentUser != null) {
                subVM!.setUser(loginVM.currentUser!);
              }
              return subVM!;
            },
          ),
          ChangeNotifierProvider(create: (_) => NavigationViewModel()),
          ChangeNotifierProvider(create: (_) => DocumentViewModel()),
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
  // MongoDB
  try {
    await MongoService.init();
  } catch (e) {
    debugPrint('MongoDB Error: $e');
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
    final localeVM = Provider.of<LocaleViewModel>(context);

    return MaterialApp(
      title: 'MMC Go Drivers',
      debugShowCheckedModeBanner: false,
      locale: localeVM.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: localeVM.locale == null ? const LanguageSelectionView() : const NavigationView(),
    );
  }
}
