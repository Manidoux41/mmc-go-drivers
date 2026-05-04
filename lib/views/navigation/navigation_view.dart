import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/navigation_viewmodel.dart';
import '../../models/planning_activity.dart';
import '../../models/vehicle.dart';
import '../../models/subscription_tier.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../login/login_view.dart';
import '../dashboard/dashboard_view.dart';
import '../subscription/paywall_view.dart';
import '../about/about_view.dart';

class NavigationView extends StatefulWidget {
  final PlanningActivity? activity;

  const NavigationView({super.key, this.activity});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _showRoutePanel = false;
  final List<TextEditingController> _stopControllers = [
    TextEditingController(text: 'Ma position'),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.activity != null && widget.activity!.stops != null) {
      // Simulation: Centrer la carte sur le premier point de l'activité
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.activity!.stops!.isNotEmpty) {
          _mapController.move(widget.activity!.stops!.first.location, 13.0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);
    final user = loginVM.currentUser;
    final tier = user?.tier ?? SubscriptionTier.free;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Itinéraire : ${widget.activity!.title}' : 'Navigation & Enregistrement'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/icon/logoMMCGo.png'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user != null ? 'Bonjour, ${user.username}' : 'Compte MMC Go',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Abonnement : ${tier.displayName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            if (user == null)
              ListTile(
                leading: Icon(Icons.login, color: Theme.of(context).primaryColor),
                title: const Text('Se connecter / S\'inscrire'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView()));
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.blue),
                title: const Text('Tableau de bord (Outils)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardView()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: const Text('Gérer mon abonnement'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallView()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion'),
                onTap: () {
                  // Simulation de déconnexion simple
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationView()));
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('À propos de MMC Go'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutView()));
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info),
              applicationName: 'MMC Go Drivers',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 MMC Go',
            ),
          ],
        ),
      ),
      body: Consumer<NavigationViewModel>(
        builder: (context, viewModel, child) {
          final List<Marker> activityMarkers = widget.activity?.stops?.map((s) => Marker(
                point: s.location,
                width: 100,
                height: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 30),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          s.name,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              )).toList() ?? [];

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.activity?.stops?.first.location ?? viewModel.currentPosition ?? const LatLng(48.069, 1.325),
                  initialZoom: 13.0,
                  onLongPress: (tapPosition, point) {
                    if (widget.activity?.vehicle != null) {
                      _showRouteConfirmation(context, viewModel, point, widget.activity!.vehicle!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez sélectionner une activité avec véhicule pour calculer un itinéraire PL.')),
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.app',
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  PolylineLayer(
                    polylines: [
                      if (widget.activity?.stops != null && widget.activity!.stops!.isNotEmpty)
                        Polyline(
                          points: widget.activity!.stops!.map((s) => s.location).toList(),
                          strokeWidth: 5,
                          color: Colors.blue.withOpacity(0.7),
                        ),
                      if (viewModel.recordedRoute.isNotEmpty)
                        Polyline(
                          points: viewModel.recordedRoute,
                          strokeWidth: 4,
                          color: Colors.deepPurple,
                        ),
                      if (viewModel.plannedRoute.isNotEmpty)
                        Polyline(
                          points: viewModel.plannedRoute,
                          strokeWidth: 5,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (viewModel.currentPosition != null)
                        Marker(
                          point: viewModel.currentPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.directions_bus, color: Colors.deepPurple, size: 30),
                        ),
                      ...viewModel.currentWaypoints.map((w) => Marker(
                            point: w.point,
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: Colors.red),
                          )),
                      ...activityMarkers,
                    ],
                  ),
                ],
              ),
              if (viewModel.isCalculating)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Calcul de l\'itinéraire PL optimisé...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showRoutePanel)
                _buildRoutePanel(context, viewModel, widget.activity?.vehicle),
              // Affichage des contraintes véhicule
              if (widget.activity?.vehicle != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Véhicule: ${widget.activity!.vehicle!.registration}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Hauteur: ${widget.activity!.vehicle!.height}m | PTAC: ${widget.activity!.vehicle!.ptac}t', style: const TextStyle(fontSize: 12)),
                          const Text('⚠️ Itinéraire optimisé Poids-Lourds', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    if (viewModel.isRecording)
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showWaypointDialog(context, viewModel),
                                icon: const Icon(Icons.add_location),
                                label: const Text('Point'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showStopDialog(context, viewModel),
                                icon: const Icon(Icons.stop, color: Colors.red),
                                label: const Text('Arrêter'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.activity == null) // Ne montrer le bouton d'enregistrement que si on n'est pas sur une activité BC
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: 'btn_record',
                            onPressed: () => viewModel.startRecording(),
                            icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                            label: const Text('Démarrer l\'enregistrement'),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'btn_history',
                            onPressed: () => _showSavedTrips(context, viewModel),
                            child: const Icon(Icons.history),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn_route_panel',
            onPressed: () => setState(() => _showRoutePanel = !_showRoutePanel),
            backgroundColor: _showRoutePanel ? Colors.orange : Theme.of(context).primaryColor,
            child: Icon(_showRoutePanel ? Icons.close : Icons.directions, color: Colors.white),
          ),
          const SizedBox(height: 80), // Laisser de la place pour les boutons d'enregistrement
        ],
      ),
    );
  }

  Widget _buildRoutePanel(BuildContext context, NavigationViewModel viewModel, Vehicle? vehicle) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calcul d\'itinéraire multi-étapes PL', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _stopControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(index == 0 ? Icons.my_location : (index == _stopControllers.length - 1 ? Icons.flag : Icons.more_vert), 
                                 size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _stopControllers[index],
                                decoration: InputDecoration(
                                  hintText: index == 0 ? 'Point de départ' : (index == _stopControllers.length - 1 ? 'Destination' : 'Étape'),
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (_stopControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _stopControllers.removeAt(index)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _stopControllers.insert(_stopControllers.length - 1, TextEditingController())),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Ajouter une étape'),
                  ),
                  if (viewModel.plannedRoute.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      tooltip: 'Exporter KML',
                      onPressed: () => viewModel.exportToKML(),
                    ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: vehicle == null ? null : () {
                        List<String> addresses = _stopControllers.map((c) => c.text).toList();
                        // Remplacer 'Ma position' par les coordonnées réelles si besoin dans le VM
                        viewModel.calculateMultiStopRoute(addresses, vehicle);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      child: const Text('CALCULER L\'ITINÉRAIRE'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.layers_clear, color: Colors.grey),
                    onPressed: () {
                      viewModel.clearPlannedRoute();
                      setState(() => _showRoutePanel = false);
                    },
                  ),
                ],
              ),
              if (vehicle == null)
                const Text('⚠️ Sélectionnez une mission pour identifier le véhicule', style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWaypointDialog(BuildContext context, NavigationViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un point'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nom du point (ex: Arrêt Scolaire)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              viewModel.addWaypoint(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showStopDialog(BuildContext context, NavigationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enregistrer le trajet'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nom du trajet'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              final user = Provider.of<LoginViewModel>(context, listen: false).currentUser;
              viewModel.stopRecording(_nameController.text, user?.id);
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSavedTrips(BuildContext context, NavigationViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Trajets enregistrés', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.savedTrips.length,
                itemBuilder: (context, index) {
                  final trip = viewModel.savedTrips[index];
                  return ListTile(
                    title: Text(trip.name),
                    subtitle: Text('${trip.route.length} points - ${trip.waypoints.length} arrêts'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.share), onPressed: () => viewModel.shareTrip(trip)),
                        IconButton(icon: const Icon(Icons.play_arrow), onPressed: () {
                          viewModel.loadTrip(trip);
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteConfirmation(BuildContext context, NavigationViewModel viewModel, LatLng destination, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculer l\'itinéraire PL ?'),
        content: Text('Voulez-vous calculer un itinéraire optimisé pour votre véhicule (${vehicle.registration}) vers ce point ?\n\nDimensions: ${vehicle.dimensions}\nPoids: ${vehicle.ptac}t'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.calculateTruckRoute(destination, vehicle);
            },
            child: const Text('Calculer'),
          ),
        ],
      ),
    );
  }
}
