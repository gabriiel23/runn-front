import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class RoutePickerPage extends StatefulWidget {
  final List<LatLng> initialPoints;

  const RoutePickerPage({super.key, this.initialPoints = const []});

  @override
  State<RoutePickerPage> createState() => _RoutePickerPageState();
}

class _RoutePickerPageState extends State<RoutePickerPage> {
  late List<LatLng> _points;
  final LatLng _lojaEcuador = const LatLng(-3.99313, -79.20422); // Loja Center

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.initialPoints);
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _points.add(position);
    });
  }

  void _undoLastPoint() {
    if (_points.isNotEmpty) {
      setState(() {
        _points.removeLast();
      });
    }
  }

  void _confirmRoute() {
    Navigator.pop(context, _points);
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    for (int i = 0; i < _points.length; i++) {
        final point = _points[i];
        if (i == 0) {
            // Start
            markers.add(Marker(
                markerId: const MarkerId('start'),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: 'Inicio'),
            ));
        } else if (i == _points.length - 1) {
            // End
            markers.add(Marker(
                markerId: const MarkerId('end'),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: const InfoWindow(title: 'Meta'),
            ));
        } else {
            // Waypoint
            markers.add(Marker(
                markerId: MarkerId('wp_$i'),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ));
        }
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(BuildContext context) {
    if (_points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route_line'),
        points: _points,
        color: context.colors.primaryDeep,
        width: 4,
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initialCameraPos = _points.isNotEmpty ? _points.first : _lojaEcuador;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Trazar Ruta', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
            if (_points.isNotEmpty)
                IconButton(
                    icon: Icon(Icons.undo_rounded, color: c.primaryDeep),
                    onPressed: _undoLastPoint,
                    tooltip: 'Deshacer último punto',
                )
        ],
      ),
      body: Column(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: c.card,
                child: Row(
                    children: [
                        Icon(Icons.info_outline_rounded, color: c.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'Toca el mapa para agregar puntos. El primer punto es el inicio🏁 y el último es la meta🚩.',
                                style: TextStyle(color: c.textSecondary, fontSize: 13),
                            ),
                        ),
                    ],
                )
            ),
            Expanded(
                child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: initialCameraPos, zoom: 14),
                    onTap: _onMapTapped,
                    markers: _buildMarkers(),
                    polylines: _buildPolylines(context),
                    mapType: MapType.normal,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                ),
            ),
            Container(
                padding: const EdgeInsets.all(24),
                color: c.card,
                child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                        onPressed: _confirmRoute,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: c.primaryDeep,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                        icon: const Icon(Icons.check_rounded),
                        label: Text('Guardar Ruta (${_points.length} puntos)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                )
            )
          ]
      )
    );
  }
}
