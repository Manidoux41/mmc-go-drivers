import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/navigation_viewmodel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/navigation_viewmodel.dart';
import '../../models/planning_activity.dart';
import '../../models/vehicle.dart';

class NavigationView extends StatefulWidget {
  final PlanningActivity? activity;

  const NavigationView({super.key, this.activity});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Itinéraire : ${widget.activity!.title}' : 'Navigation & Enregistrement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<NavigationViewModel>(
        builder: (context, viewModel, child) {
          final List<Marker> activityMarkers = widget.activity?.stops?.map((s) => Marker(
                point: s.location,
                width: 100,
                height: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 30),
                    Container(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      if (widget.activity?.stops != null)
                        Polyline(
                          points: widget.activity!.stops!.map((s) => s.location).toList(),
                          strokeWidth: 5,
                          color: Colors.blue.withOpacity(0.7),
                        ),
                      Polyline(
                        points: viewModel.currentRoute,
                        strokeWidth: 4,
                        color: Colors.deepPurple,
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
              viewModel.stopRecording(_nameController.text);
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
}
