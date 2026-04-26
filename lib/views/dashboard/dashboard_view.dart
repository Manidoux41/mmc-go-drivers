import 'package:flutter/material.dart';
import '../login/login_view.dart';
import '../planning/planning_view.dart';
import '../navigation/navigation_view.dart';
import '../vehicle/vehicle_view.dart';
import '../contact/contact_view.dart';
import '../documents/document_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Chauffeur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildToolCard(
            context,
            'Planning',
            Icons.calendar_month,
            Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanningView()),
            ),
          ),
          _buildToolCard(
            context, 
            'Navigation', 
            Icons.map, 
            Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationView()),
            ),
          ),
          _buildToolCard(
            context, 
            'Véhicule', 
            Icons.directions_bus, 
            Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VehicleView()),
            ),
          ),
          _buildToolCard(
            context, 
            'Documents', 
            Icons.description, 
            Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentView()),
            ),
          ),
          _buildToolCard(
            context, 
            'Contact', 
            Icons.contact_phone, 
            Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactView()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ouverture de $title...')),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
