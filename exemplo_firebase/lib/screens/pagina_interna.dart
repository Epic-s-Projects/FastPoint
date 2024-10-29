import 'package:flutter/material.dart';
import 'package:exemplo_firebase/screens/login_screen.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  HomeScreen({required this.name, required this.imageUrl});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  final AuthService _authService = AuthService();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

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

  Widget buildCard(Map<String, dynamic> data) {
    print("Dados recebidos: $data");
    DateTime timestamp = data['timestamp'].toDate();
    String formattedDay = DateFormat('dd').format(timestamp);
    String formattedMonth = DateFormat('MMMM').format(timestamp);
    String formattedTime = DateFormat('HH:mm').format(timestamp);
    String latitude = data['latitude']?.toString() ?? '-';
    String longitude = data['longitude']?.toString() ?? '-';

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
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.purple),
                  SizedBox(width: 8),
                  Text("Entrada: $formattedTime",
                      style: TextStyle(color: Colors.purple, fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.purple),
                  SizedBox(width: 8),
                  Text("Saída: $formattedTime",
                      style: TextStyle(color: Colors.purple, fontSize: 16)),
                ],
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(formattedDay,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(formattedMonth,
                  style: TextStyle(fontWeight: FontWeight.w400))
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void getUserId() {
      User? user = FirebaseAuth.instance.currentUser;

      // Verifique se o usuário está logado
      if (user != null) {
        // O userId é o UID do usuário autenticado
        String userId = user.uid;
        print("ID do usuário logado: $userId");
      } else {
        print("Nenhum usuário está logado.");
      }
    }

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
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        IconButton(
                          icon: Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () {},
                        ),
                      ]),
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

                // CircleAvatar com a imagem do usuário
                CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.white,
                  child: widget.imageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            // Ajusta a imagem ao tamanho do CircleAvatar
                            width: MediaQuery.of(context).size.width * 1,
                            // Dobro do valor do radius
                            height: MediaQuery.of(context).size.width * 1,
                          ),
                        )
                      : Icon(Icons.person, size: 120, color: Color(0xFF7B2CBF)),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              widget.name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            // Espaçamento em torno da linha
            height: 2,
            width: 330,
            color: Color.fromRGBO(25, 25, 25, 0.2),
          ),
          SizedBox(height: 8),
          // Colocar o Card

          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('marcacao_pontos')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erro ao carregar dados: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return buildCard(data);
                },
              );
            },
          ))
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (isExpanded) ...[
            Positioned(
              right: 16, // Ajusta para manter o botão à direita
              bottom: 90,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _authService.baterPonto();
                },
                child: Icon(Icons.password, color: Colors.white),
                backgroundColor: Colors.purple,
              ),
            ),
            Positioned(
              right: 16,
              bottom: 140,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {},
                backgroundColor: Colors.purple,
                child: Icon(Icons.face, color: Colors.white),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 190,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {},
                backgroundColor: Colors.purple,
                child: Icon(Icons.fingerprint, color: Colors.white),
              ),
            ),
          ],
          Positioned(
            right: 16, // Posiciona o botão principal no canto inferior direito
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              backgroundColor: Colors.purple,
              child: Icon(isExpanded ? Icons.close : Icons.menu,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
