import 'package:flutter/material.dart';
import 'location_map.dart'; // Importa o arquivo que contém o mapa

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Registro de Ponto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationMap(), // Define a página inicial como o mapa
    );
  }
}
