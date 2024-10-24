import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'pagina_interna.dart'; // Importe a página interna

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instância do AuthService

  // Função para realizar o login
  void _login() async {
    User? user = await _authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      // Se o login for bem-sucedido, redireciona para a página interna
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PaginaInterna()),
      );
    } else {
      // Exibe uma mensagem de erro caso o login falhe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha no login. Verifique suas credenciais.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B2CBF), Color(0xFFD8B4FE)], // Degradê roxo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/logo.png', // Adicione o caminho do seu logo
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 24),

              // Título
              Text(
                'FastPoint',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'BalooBhaijaan', // Defina a família da fonte aqui
                ),
              ),
              SizedBox(height: 32),

              // Campo de Email
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Campo de Senha
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Botão de Login
              ElevatedButton(
                onPressed: _login, // Chama o método de login
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Link de recuperação de senha
              Text(
                'Esqueceu sua senha?',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 32),

              // Autenticação com impressão digital (Somente visual, sem funcionalidade real)
              Column(
                children: [
                  Icon(Icons.fingerprint, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Entre utilizando sua impressão digital',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
