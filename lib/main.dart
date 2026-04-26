import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/planning_viewmodel.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/document_viewmodel.dart';
import 'viewmodels/subscription_viewmodel.dart';
import 'views/login/login_view.dart';
import 'views/navigation/navigation_view.dart';

void main() async {
  // Nécessaire pour initialiser le formatage des dates en français
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          secondary: Colors.lightGreen,
        ),
        useMaterial3: true,
      ),
      home: NavigationView(),
    );
  }
}
