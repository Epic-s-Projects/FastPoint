import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_service.dart'; // Importa a lógica de localização

class LocationMap extends StatefulWidget {
  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(-23.5505, -46.6333); // São Paulo por padrão

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position? position = await getCurrentLocation();
      if (position != null) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _mapController.animateCamera(
            CameraUpdate.newLatLng(_initialPosition),
          );
        });
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização Atual'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 16.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: _initialPosition,
            infoWindow: InfoWindow(title: 'Você está aqui'),
          ),
        },
      ),
    );
  }
}
