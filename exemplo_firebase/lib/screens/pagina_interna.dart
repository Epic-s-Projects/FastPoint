import 'package:flutter/material.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'login_screen.dart'; // Para redirecionar de volta ao login após o logout

class PaginaInterna extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.signOut();
    // Após o logout, redirecionar de volta à tela de login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Interna"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Logout ao pressionar o botão
          )
        ],
      ),
      body: Center(
        child: Text("Bem-vindo! Você está logado."),
      ),
    );
  }
}
