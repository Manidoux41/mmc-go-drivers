import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:intl/intl.dart';
import 'package:flutter01/viewmodels/navigation_viewmodel.dart';
import 'package:flutter01/viewmodels/vehicle_viewmodel.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/viewmodels/planning_viewmodel.dart';
import 'package:flutter01/viewmodels/fleet_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/super_admin_viewmodel.dart';
import 'package:flutter01/viewmodels/locale_viewmodel.dart';
import 'package:flutter01/models/planning_activity.dart' hide Waypoint;
import 'package:flutter01/models/recorded_trip.dart';
import 'package:flutter01/models/vehicle.dart';
import 'package:flutter01/models/subscription_tier.dart';
import 'package:flutter01/models/route_option.dart';
import 'package:flutter01/views/login/login_view.dart';
import 'package:flutter01/views/dashboard/dashboard_view.dart';
import 'package:flutter01/views/subscription/paywall_view.dart';
import 'package:flutter01/views/about/about_view.dart';
import 'package:flutter01/config/colors.dart';
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
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _lastRotation = 0;
  
  // Map Layers state
  String _currentTileLayerUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  List<String> _currentSubdomains = ['a', 'b', 'c', 'd'];
  bool _showLayerMenu = false;

  bool _showRoutePanel = false;
  bool _showStatsPanel = false;
  bool _showGraphs = false;
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

      // Écouter la boussole pour orienter la carte
      _compassSubscription = FlutterCompass.events!.listen((event) {
        if (!mounted) return;
        final navVM = Provider.of<NavigationViewModel>(context, listen: false);
        
        if ((navVM.isFollowing || navVM.isRecording) && event.heading != null) {
          // Rotation de la carte selon le téléphone
          // On évite les micro-mouvements (hystérésis)
          if ((event.heading! - _lastRotation).abs() > 1) {
            _lastRotation = event.heading!;
            _mapController.rotate(-_lastRotation);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);
    final user = loginVM.currentUser;
    final tier = user?.tier ?? SubscriptionTier.free;
    final l10n = AppLocalizations.of(context)!;

    // Écouter les changements de position pour le mode GPS
    final navVM = Provider.of<NavigationViewModel>(context);
    if (navVM.isFollowing && navVM.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Centrer la carte sur la position
        _mapController.move(navVM.currentPosition!, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Itinéraire : ${widget.activity!.title}' : l10n.navAndRecording),
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
                      user != null ? l10n.helloUser(user.username) : l10n.mmcAccount,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${l10n.tier} : ${tier.displayName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            if (user == null)
              ListTile(
                leading: Icon(Icons.login, color: Theme.of(context).primaryColor),
                title: Text('${l10n.login} / ${l10n.register}'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView()));
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.blue),
                title: Text('${l10n.dashboard} (${l10n.tools})'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardView()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: Text(l10n.manageSubscription),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallView()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.teal),
                title: Text(l10n.changeLanguage),
                onTap: () {
                  Provider.of<LocaleViewModel>(context, listen: false).clearLocale();
                  Navigator.pop(context); // Close drawer
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
              title: Text(l10n.aboutMMC),
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
                          color: Colors.white.withValues(alpha: 0.9),
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
                    urlTemplate: _currentTileLayerUrl,
                    subdomains: _currentSubdomains,
                    userAgentPackageName: 'com.manidev41.mmcgodrivers',
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  PolylineLayer(
                    polylines: [
                      // Itinéraires alternatifs en gris (très discret)
                      ...viewModel.routeOptions.asMap().entries.where((e) => e.key != viewModel.selectedRouteIndex).map((e) => Polyline(
                        points: e.value.points,
                        strokeWidth: 3,
                        color: Colors.grey.withValues(alpha: 0.3),
                      )),
                      // Trajet enregistré
                      if (viewModel.recordedRoute.isNotEmpty)
                        Polyline(
                          points: viewModel.recordedRoute,
                          strokeWidth: 4,
                          color: Colors.deepPurple,
                        ),
                      // Itinéraire planifié sélectionné (en premier plan)
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
                          width: 50,
                          height: 50,
                          child: Transform.rotate(
                            angle: (viewModel.currentHeading * (math.pi / 180)),
                            child: const Icon(Icons.navigation, color: Colors.deepPurple, size: 40),
                          ),
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
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(l10n.calculatingRoute),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showRoutePanel)
                _buildRoutePanel(context, viewModel, widget.activity?.vehicle),
              
              if (_showLayerMenu)
                _buildLayerMenu(context),

              // Dashboard Statistiques (Geo Tracker style)
              if (viewModel.isRecording || _showStatsPanel)
                _buildStatsDashboard(context, viewModel),

              // Affichage des contraintes véhicule
                  if (widget.activity?.vehicle != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Card(
                        color: Colors.white.withValues(alpha: 0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.vehicleInfo(widget.activity!.vehicle!.registration), style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Hauteur: ${widget.activity!.vehicle!.height}m | PTAC: ${widget.activity!.vehicle!.ptac}t', style: const TextStyle(fontSize: 12)),
                              Text(l10n.hgvOptimized, style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Boussole (En haut à droite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildCompass(),
                  ),

                  // Bouton Recentrer / Follow GPS / Zoom
                  Positioned(
                    bottom: 110,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom In
                        FloatingActionButton.small(
                          heroTag: 'btn_zoom_in',
                          onPressed: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 8),
                        // Zoom Out
                        FloatingActionButton.small(
                          heroTag: 'btn_zoom_out',
                          onPressed: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 12),
                        // Choix Calque
                        FloatingActionButton.small(
                          heroTag: 'btn_layers',
                          onPressed: () => setState(() => _showLayerMenu = !_showLayerMenu),
                          backgroundColor: _showLayerMenu ? AppColors.tertiaryYellow : Colors.white,
                          child: Icon(Icons.layers, color: _showLayerMenu ? Colors.black87 : Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // Cible GPS
                        FloatingActionButton.small(
                          heroTag: 'btn_follow',
                          onPressed: () => viewModel.toggleFollowing(),
                          backgroundColor: viewModel.isFollowing ? Theme.of(context).primaryColor : Colors.white,
                          child: Icon(
                            viewModel.isFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
                            color: viewModel.isFollowing ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barre d'outils latérale gauche (Action rapide)
                  Positioned(
                    left: 10,
                    bottom: 110,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'btn_lang',
                          onPressed: () => Provider.of<LocaleViewModel>(context, listen: false).clearLocale(),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.language, color: Colors.teal),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.small(
                          heroTag: 'btn_stats_toggle',
                          onPressed: () => setState(() => _showStatsPanel = !_showStatsPanel),
                          backgroundColor: _showStatsPanel ? Colors.blue : Colors.white,
                          child: Icon(Icons.bar_chart, color: _showStatsPanel ? Colors.white : Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.small(
                          heroTag: 'btn_history',
                          onPressed: () => _showSavedTrips(context, viewModel),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.history, color: Colors.blueGrey),
                        ),
                      ],
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
                        elevation: 8,
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showWaypointDialog(context, viewModel),
                                icon: const Icon(Icons.add_location, color: Colors.blue),
                                label: const Text('POINT D\'INTÉRÊT'),
                              ),
                              const VerticalDivider(),
                              TextButton.icon(
                                onPressed: () => _showStopDialog(context, viewModel),
                                icon: const Icon(Icons.stop, color: Colors.red),
                                label: const Text('ARRÊTER', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.activity == null) 
                      ElevatedButton.icon(
                        onPressed: () => viewModel.startRecording(),
                        icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                        label: const Text('LANCER L\'ENREGISTREMENT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(250, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _showRoutePanel ? null : FloatingActionButton(
        heroTag: 'btn_route_panel',
        onPressed: () => setState(() => _showRoutePanel = !_showRoutePanel),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.directions, color: Colors.white),
      ),
    );
  }

  Widget _buildRoutePanel(BuildContext context, NavigationViewModel viewModel, Vehicle? activityVehicle) {
    final l10n = AppLocalizations.of(context)!;
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
                      final l10n = AppLocalizations.of(context)!;
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
                                  hintText: index == 0 ? l10n.startPoint : (index == _stopControllers.length - 1 ? l10n.destination : l10n.waypoint),
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
                    label: Text(l10n.addStep),
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
              if (viewModel.routeOptions.isNotEmpty) ...[
                Text('${l10n.chooseRoute} :', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.routeOptions.length,
                    itemBuilder: (context, index) {
                      final option = viewModel.routeOptions[index];
                      final isSelected = viewModel.selectedRouteIndex == index;
                      return GestureDetector(
                        onTap: () {
                          viewModel.selectRoute(index);
                          // Ajuster la vue pour voir l'itinéraire sélectionné
                          if (viewModel.plannedRoute.isNotEmpty) {
                            final bounds = LatLngBounds.fromPoints(viewModel.plannedRoute);
                            _mapController.fitCamera(
                              CameraFit.bounds(
                                bounds: bounds,
                                padding: const EdgeInsets.all(50),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange.shade100 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(option.typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.orange.shade900 : Colors.black54)),
                              Text(option.distanceLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text(option.durationLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Divider(),
              Row(
                children: [
                  if (viewModel.routeOptions.isNotEmpty && !viewModel.isNavigatingCalculated)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            viewModel.startCalculatedNavigation();
                            setState(() => _showRoutePanel = false);
                          },
                          icon: const Icon(Icons.navigation),
                          label: Text(l10n.startNav),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.file_open, color: Colors.blue),
                    tooltip: 'Importer KML',
                    onPressed: () => viewModel.importKml(),
                  ),
                  const SizedBox(width: 8),
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
                        : Text(l10n.calculateRoute),
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

  Widget _buildLayerMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      bottom: 240,
      right: 20,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.mapLayers, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              const Divider(height: 10),
              _buildLayerOption(
                icon: Icons.map,
                label: l10n.standardView,
                url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: ['a', 'b', 'c', 'd'],
              ),
              _buildLayerOption(
                icon: Icons.satellite_alt,
                label: l10n.satelliteView,
                url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                subdomains: [],
              ),
              _buildLayerOption(
                icon: Icons.terrain,
                label: l10n.terrainView,
                url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerOption({
    required IconData icon,
    required String label,
    required String url,
    required List<String> subdomains,
  }) {
    final isSelected = _currentTileLayerUrl == url;
    return InkWell(
      onTap: () {
        setState(() {
          _currentTileLayerUrl = url;
          _currentSubdomains = subdomains;
          _showLayerMenu = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        width: 130,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryBlue : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _showWaypointDialog(BuildContext context, NavigationViewModel viewModel) {
    final labelController = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un repère'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Nom du point (ex: Arrêt Scolaire)'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Notes / Détails'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              viewModel.addWaypoint(labelController.text, note: noteController.text);
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showStopDialog(BuildContext context, NavigationViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveTrip),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: l10n.tripName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              final user = Provider.of<LoginViewModel>(context, listen: false).currentUser;
              await viewModel.stopRecording(_nameController.text, user?.id);
              _nameController.clear();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showSavedTrips(BuildContext context, NavigationViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l10n.tripHistory, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.savedTrips.length,
                itemBuilder: (context, index) {
                  final l10n = AppLocalizations.of(context)!;
                  final trip = viewModel.savedTrips[index];
                  return Card(
                    child: ListTile(
                      title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📅 ${DateFormat('dd/MM/yyyy HH:mm').format(trip.startTime)}'),
                          Text('📏 ${trip.totalDistance.toStringAsFixed(2)} km | ⚡ Moy: ${trip.avgSpeed.toStringAsFixed(1)} km/h'),
                          Text('🏔️ Alt Max: ${trip.maxAltitude.toInt()}m | 📈 Vit Max: ${trip.maxSpeed.toStringAsFixed(1)} km/h'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.auto_fix_high, color: Colors.purple),
                            tooltip: 'Optimiser le tracé (Suivre les routes)',
                            onPressed: () {
                              final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                              final v = widget.activity?.vehicle ?? (vehicleVM.vehicles.isNotEmpty ? vehicleVM.vehicles.first : null);
                              if (v != null) {
                                viewModel.optimizeRecordedTrip(trip, v);
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun profil véhicule disponible pour l\'optimisation.')));
                              }
                            },
                          ),
                          IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: () => viewModel.shareTrip(trip)),
                          IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.green, size: 30), onPressed: () {
                            viewModel.loadTrip(trip);
                            Navigator.pop(context);
                          }),
                        ],
                      ),
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
            // Recentrer la carte au Nord magnétique
            _mapController.rotate(0);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: (direction * (math.pi / 180) * -1),
                  child: Image.asset('assets/icon/logoMMCGo.png', width: 30, height: 30, opacity: const AlwaysStoppedAnimation(0.3)),
                ),
                Transform.rotate(
                  angle: (direction * (math.pi / 180) * -1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      Container(width: 2, height: 15, color: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsDashboard(BuildContext context, NavigationViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 80,
      left: 10,
      right: 10,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showGraphs = !_showGraphs),
                  child: Card(
                    color: Colors.black87.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(l10n.speed, '${vm.currentSpeed.toStringAsFixed(1)}', 'km/h', icon: Icons.speed, color: Colors.greenAccent),
                          _buildStatItem(l10n.distance, '${vm.totalDistance.toStringAsFixed(2)}', 'km', icon: Icons.straighten),
                          _buildStatItem(l10n.altitude, '${vm.altitude.toInt()}', 'm', icon: Icons.terrain, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton d'arrêt d'urgence/rapide permanent pendant un trajet
              GestureDetector(
                onTap: () {
                  if (vm.isRecording) {
                    _showStopDialog(context, vm);
                  } else if (vm.isNavigatingCalculated) {
                    _showStopNavigationConfirm(context, vm);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.stop, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          if (_showGraphs && vm.recordedTrackPoints.isNotEmpty)
            _buildGraphsPanel(vm),
        ],
      ),
    );
  }

  void _showStopNavigationConfirm(BuildContext context, NavigationViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arrêter la navigation ?'),
        content: const Text('Voulez-vous vraiment mettre fin au guidage en cours ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () {
              vm.stopCalculatedNavigation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ARRÊTER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, {IconData? icon, Color color = Colors.white}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.white38, size: 10),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildGraphsPanel(NavigationViewModel vm) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black87.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: vm.recordedTrackPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.speed)).toList(),
              isCurved: true,
              color: Colors.greenAccent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: vm.recordedTrackPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.altitude / 10)).toList(), // Scaled altitude
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
