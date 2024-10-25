import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LocationMap extends StatefulWidget {
  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(-22.570701145130165, -47.40414378376208); // Localização padrão
  final double workLatitude = -22.570701145130165; // Latitude do local de trabalho
  final double workLongitude = -47.40414378376208; // Longitude do local de trabalho

  bool _canRegister = false; // Controla se o funcionário pode bater ponto

  @override
  void initState() {
    super.initState();
    _setCurrentLocation(); // Inicializa a localização.
    _listenToLocationChanges(); // Monitora a movimentação em tempo real.
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      _updateLocationAndStatus(position); // Atualiza localização e estado.

      if (_canRegister) {
        _showNotification('Você está dentro do limite. Pode registrar seu ponto.');
      } else {
        _showNotification('Você precisa estar dentro da zona limite para registrar o ponto.');
      }
    } catch (e) {
      print(e);
      _showNotification('Erro ao obter a localização.');
    }
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      _updateLocationAndStatus(position); // Atualiza estado em tempo real.
    });
  }

  void _updateLocationAndStatus(Position position) {
    bool withinRange = isWithinRange(
      position.latitude,
      position.longitude,
      workLatitude,
      workLongitude,
    );

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _canRegister = withinRange;
    });
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão permanentemente negada.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool isWithinRange(double lat1, double lon1, double lat2, double lon2) {
    double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distance <= 100; // Verifica se está dentro de 100 metros.
  }

  void _registerPoint() {
    if (_canRegister) {
      _showNotification('Ponto registrado com sucesso!');
    } else {
      _showNotification('Você não está na área permitida para bater ponto.');
    }
  }

  void _showNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização Atual'),
      ),
      body: Stack(
        children: [
          GoogleMap(
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
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _registerPoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canRegister ? Colors.green : Colors.red,
              ),
              child: Text(
                _canRegister ? 'Registrar Ponto' : 'Fora da Área',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
