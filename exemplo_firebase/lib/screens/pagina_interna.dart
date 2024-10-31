import 'package:flutter/material.dart';
import 'package:exemplo_firebase/screens/login_screen.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exemplo_firebase/screens/map_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  HomeScreen({required this.name, required this.imageUrl});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String _timeString = '';
  String _dateString = '';
  bool isExpanded = false;
  final latitudePlace = -22.570691238055606;
  final longitudePlace = -47.40385410357194;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat('HH:mm').format(now);
      _dateString = DateFormat('dd/MM/yyyy').format(now);
    });
  }

  void _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _onAuthenticatePressed(String authType) async {final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('marcacao_pontos')
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
      .where('timestamp', isLessThanOrEqualTo: endOfDay)
      .get();

  if (snapshot.docs.length >= 2) {
    _showErrorSnackbar("Você já registrou dois pontos hoje.");
    return; // Interrompe o processo se já houverem dois pontos no dia
  }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(position.latitude, position.longitude, latitudePlace, longitudePlace);

      if (distance <= 100) {
        if (authType == 'password') {
          _showPasswordDialog();
        } else if (authType == 'fingerprint') {
          bool pontoRegistrado = await _authService.baterPonto('fingerprint');
          pontoRegistrado
              ? _showSuccessSnackbar("Ponto registrado com sucesso!")
              : _showErrorSnackbar("Erro ao bater ponto.");
        }
      } else {
        _showErrorSnackbar("Você está fora do local permitido para bater o ponto.");
      }
    } catch (e) {
      _showErrorSnackbar("Erro ao obter a localização. Tente novamente.");
    }
  }

  Future<void> _showPasswordDialog() async {
    String password = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Digite sua senha'),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            obscureText: true,
            decoration: InputDecoration(hintText: "Senha"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool pontoRegistrado = await _authService.baterPonto('password', password: password);
                pontoRegistrado
                    ? _showSuccessSnackbar("Ponto registrado com sucesso!")
                    : _showErrorSnackbar("Erro ao bater ponto. Verifique sua senha.");
              },
              child: Text("Confirmar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget buildCard(Map<String, dynamic> data) {
    DateTime? timestamp = data['timestamp']?.toDate();
    String formattedDay = timestamp != null ? DateFormat('dd').format(timestamp) : '-';
    String formattedMonth = timestamp != null ? DateFormat('MMMM').format(timestamp) : '-';
    String formattedTime = timestamp != null ? DateFormat('HH:mm').format(timestamp) : '-';
    String tipo = data['tipo'] ?? '-';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.access_time, color: Colors.purple), SizedBox(width: 8), Text("Hora: $formattedTime", style: TextStyle(color: Colors.purple, fontSize: 16))]),
              SizedBox(height: 8),
              Row(children: [Icon(tipo == 'entrada' ? Icons.login : Icons.logout, color: Colors.purple), SizedBox(width: 8), Text("Tipo: $tipo", style: TextStyle(color: Colors.purple, fontSize: 16))]),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(formattedDay, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(formattedMonth, style: TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          Center(child: Text(widget.name, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold))),
          SizedBox(height: 16),
          Divider(color: Colors.grey.withOpacity(0.2), indent: 20, endIndent: 20),
          SizedBox(height: 8),
          Expanded(child: _buildAttendanceList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF7B2CBF), Color(0xFFD8B4FE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(60)),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.exit_to_app, color: Colors.white), onPressed: () => _logout(context)),
                    IconButton(
                      icon: Icon(Icons.map_outlined, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              latitude: latitudePlace,
                              longitude: longitudePlace,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(_timeString, style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          Text(_dateString, style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(height: 16),
          CircleAvatar(
            radius: 90,
            backgroundColor: Colors.white,
            child: widget.imageUrl.isNotEmpty
                ? ClipOval(child: Image.network(widget.imageUrl, fit: BoxFit.cover, width: 180, height: 180))
                : Icon(Icons.person, size: 120, color: Color(0xFF7B2CBF)),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('marcacao_pontos').orderBy('timestamp').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Center(child: Text("Erro ao carregar dados: ${snapshot.error}"));
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Nenhum registro de ponto para exibir."));
        }

        Map<String, Map<String, String>> registrosDiarios = {};
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime? timestamp = data['timestamp']?.toDate();
          if (timestamp == null) continue;
          String tipo = data['tipo'] ?? '-';
          String time = DateFormat('HH:mm').format(timestamp);
          String dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

          if (!registrosDiarios.containsKey(dateKey)) {
            registrosDiarios[dateKey] = {'entrada': '-', 'saida': '-'};
          }
          registrosDiarios[dateKey]![tipo] = time;
        }

        return ListView(
          children: registrosDiarios.entries.map((entry) {
            String date = entry.key;
            String entrada = entry.value['entrada'] ?? '-';
            String saida = entry.value['saida'] ?? '-';
            DateTime parsedDate = DateTime.parse(date);
            String formattedDay = DateFormat('dd').format(parsedDate);
            String formattedMonth = DateFormat('MMMM').format(parsedDate);

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.login, color: Colors.purple), SizedBox(width: 8), Text("Entrada: $entrada", style: TextStyle(color: Colors.purple, fontSize: 16))]),
                      SizedBox(height: 8),
                      Row(children: [Icon(Icons.logout, color: Colors.purple), SizedBox(width: 8), Text("Saída: $saida", style: TextStyle(color: Colors.purple, fontSize: 16))]),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(formattedDay, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Text(formattedMonth, style: TextStyle(fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (isExpanded) ...[
          Positioned(
            right: 16,
            bottom: 90,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => _onAuthenticatePressed('password'),
              child: Icon(Icons.password, color: Colors.white),
              backgroundColor: Colors.purple,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => _onAuthenticatePressed('fingerprint'),
              backgroundColor: Colors.purple,
              child: Icon(Icons.fingerprint, color: Colors.white),
            ),
          ),
        ],
        Positioned(
          right: 16,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            backgroundColor: Colors.purple,
            child: Icon(isExpanded ? Icons.close : Icons.menu, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
