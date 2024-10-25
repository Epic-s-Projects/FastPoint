import 'package:flutter/material.dart';
import 'package:exemplo_firebase/screens/login_screen.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final String name;

  HomeScreen({required this.name});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  final AuthService _authService = AuthService();

  // Variáveis para data e hora
  String _timeString = '';
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm').format(now);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(now);

    print(formattedTime); // Verificar a saída no console
    print(formattedDate); // Verificar a saída no console

    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  void _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2CBF), Color(0xFFD8B4FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(60),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.more_vert, color: Colors.white),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.exit_to_app, color: Colors.white),
                            onPressed: () => _logout(context),
                          ),
                          Icon(Icons.map_outlined, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Hora e data atualizadas
                Text(
                  _timeString,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _dateString,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),

                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Color(0xFF7B2CBF)),
                ),
                SizedBox(height: 8),

                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                buildCard('Entrada: 08:00', 'Saída: -', '22', 'Outubro'),
                SizedBox(height: 16),
                buildCard('Entrada: 07:55', 'Saída: 17:02', '21', 'Outubro'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (isExpanded) ...[
            Positioned(
              bottom: 90,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {},
                backgroundColor: Colors.purple,
                child: Icon(Icons.fingerprint),
              ),
            ),
            Positioned(
              bottom: 140,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {},
                backgroundColor: Colors.purple,
                child: Icon(Icons.person),
              ),
            ),
            Positioned(
              bottom: 190,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {},
                backgroundColor: Colors.purple,
                child: Icon(Icons.code),
              ),
            ),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            backgroundColor: Colors.purple,
            child: Icon(isExpanded ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String entrada, String saida, String dia, String mes) {
    return Container(
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
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(entrada, style: TextStyle(color: Colors.purple)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(saida, style: TextStyle(color: Colors.purple)),
                ],
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(dia, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(mes, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
