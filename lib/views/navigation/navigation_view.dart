import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../viewmodels/navigation_viewmodel.dart';
import '../../viewmodels/vehicle_viewmodel.dart';
import '../../models/planning_activity.dart' hide Waypoint;
import '../../models/recorded_trip.dart' show Waypoint;
import '../../models/vehicle.dart';
import '../../models/subscription_tier.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/planning_viewmodel.dart';
import '../../viewmodels/fleet_admin_viewmodel.dart';
import '../../viewmodels/super_admin_viewmodel.dart';
import '../login/login_view.dart';
import '../dashboard/dashboard_view.dart';
import '../subscription/paywall_view.dart';
import '../about/about_view.dart';
import 'dart:math' as math;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<NavigationViewModel>(context, listen: false);
      
      if (widget.activity != null) {
        if (widget.activity!.stops != null && widget.activity!.stops!.isNotEmpty) {
          _mapController.move(widget.activity!.stops!.first.location, 13.0);
          
          // Calcul automatique de l'itinéraire de l'activité
          if (widget.activity!.vehicle != null) {
            viewModel.calculateRouteFromActivity(widget.activity!);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);
    final user = loginVM.currentUser;
    final tier = user?.tier ?? SubscriptionTier.free;

    // Écouter les changements de position pour le mode GPS
    final navVM = Provider.of<NavigationViewModel>(context);
    if (navVM.isFollowing && navVM.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(navVM.currentPosition!, _mapController.camera.zoom);
      });
    }

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
                onTap: () async {
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
                    Navigator.pop(context); // Fermer le drawer
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
                  }
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
                  onPositionChanged: (MapCamera position, bool hasGesture) {
                    if (hasGesture && viewModel.isFollowing) {
                      viewModel.setFollowing(false);
                    }
                  },
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
                      // La ligne bleue (directe) est supprimée car elle est remplacée par le tracé orange réel
                      if (viewModel.recordedRoute.isNotEmpty)
                        Polyline(
                          points: viewModel.recordedRoute,
                          strokeWidth: 4,
                          color: Colors.deepPurple,
                        ),
                      if (viewModel.plannedRoute.isNotEmpty)
                        Polyline(
                          points: viewModel.plannedRoute,
                          strokeWidth: 6,
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
                      ...viewModel.currentWaypoints.map((Waypoint w) => Marker(
                            point: w.point,
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: Colors.red),
                          )),
                      // Marqueurs d'étapes de l'itinéraire planifié
                      ...viewModel.plannedWaypoints.asMap().entries.map((entry) {
                        int idx = entry.key;
                        LatLng p = entry.value;
                        return Marker(
                          point: p,
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                idx == 0 ? 'A' : (idx == viewModel.plannedWaypoints.length - 1 ? 'B' : (idx).toString()),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      }),
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
                  
                  // Boussole
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildCompass(),
                  ),

                  // Bouton Recentrer / Follow GPS
                  Positioned(
                    bottom: viewModel.isRecording ? 120 : 100,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'btn_follow',
                      onPressed: () => viewModel.toggleFollowing(),
                      backgroundColor: viewModel.isFollowing ? Theme.of(context).primaryColor : Colors.white,
                      child: Icon(
                        viewModel.isFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
                        color: viewModel.isFollowing ? Colors.white : Colors.grey,
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

  Widget _buildRoutePanel(BuildContext context, NavigationViewModel viewModel, Vehicle? activityVehicle) {
    // Utiliser le véhicule de l'activité, ou le premier de la flotte, ou un défaut
    final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
    final vehicle = activityVehicle ?? (vehicleVM.vehicles.isNotEmpty ? vehicleVM.vehicles.first : Vehicle(
      id: 'default',
      registration: 'DEMO-PL',
      brand: 'Mercedes-Benz',
      model: 'Intouro',
      height: 3.8,
      length: 12.0,
      width: 2.5,
      unladenWeight: 12.0,
      ptac: 19.0,
      fuelType: FuelType.diesel,
      mileage: 0,
    ));

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
                      onPressed: viewModel.isCalculating ? null : () {
                        List<String> addresses = _stopControllers.map((c) => c.text).toList();
                        viewModel.calculateMultiStopRoute(addresses, vehicle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, 
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50)
                      ),
                      child: viewModel.isCalculating 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('CALCULER L\'ITINÉRAIRE'),
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
              if (activityVehicle == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('ℹ️ Utilisation d\'un profil véhicule standard (Demo)', style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontStyle: FontStyle.italic)),
                ),
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

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        
        double? direction = snapshot.data?.heading;
        if (direction == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            // Optionnel : Recentrer la carte au Nord ?
            _mapController.rotate(0);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: const Icon(Icons.navigation, color: Colors.red, size: 30),
            ),
          ),
        );
      },
    );
  }
}
