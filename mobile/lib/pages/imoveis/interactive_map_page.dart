import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InteractiveMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  const InteractiveMapPage({super.key, required this.latitude, required this.longitude});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final initial = CameraPosition(target: LatLng(widget.latitude, widget.longitude), zoom: 15);
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: GoogleMap(
        initialCameraPosition: initial,
        markers: {
          Marker(markerId: const MarkerId('m1'), position: LatLng(widget.latitude, widget.longitude)),
        },
        onMapCreated: (c) => _controller = c,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
