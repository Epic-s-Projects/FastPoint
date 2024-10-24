import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Parte superior (hora, data, imagem do funcionário)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2CBF), Color(0xFFD8B4FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                // Ícones no topo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.more_vert, color: Colors.white),
                      Icon(Icons.map_outlined, color: Colors.white),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Hora e data
                Text(
                  '14:32',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '22/10/2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),

                // Avatar e nome do funcionário
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Color(0xFF7B2CBF)),
                ),
                SizedBox(height: 8),
                Text(
                  'Funcionário',
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

          // Cards scrolláveis
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

      // Botão flutuante com botões menores que aparecem
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