import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Verifica se o serviço de localização está ativado.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Serviço de localização está desativado.');
  }

  // Verifica e solicita permissões de localização.
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

  // Retorna a posição atual do dispositivo.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}
