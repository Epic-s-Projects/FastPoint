import 'package:flutter/material.dart';
import 'package:exemplo_firebase/service/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Pacote para armazenamento seguro
import 'package:local_auth/local_auth.dart'; // Pacote para biometria
import 'pagina_interna.dart'; // Importe a página interna

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instância do AuthService
  final LocalAuthentication auth = LocalAuthentication(); // Instância do LocalAuth para biometria
  final FlutterSecureStorage storage = FlutterSecureStorage(); // Instância do Secure Storage
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkForSavedCredentials();
  }

  // Função para verificar se a biometria está disponível no dispositivo
  Future<void> _checkBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        _isBiometricAvailable = canCheckBiometrics;
        _availableBiometrics = availableBiometrics;
      });
      print('Biometria disponível: $_isBiometricAvailable');
      print('Tipos de biometria disponíveis: $_availableBiometrics');
    } catch (e) {
      print('Erro ao verificar biometria: $e');
    }
  }

  // Função para verificar se há credenciais salvas
  Future<void> _checkForSavedCredentials() async {
    print('Verificando credenciais salvas...');
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    print('Credenciais salvas: Email - $email, Senha - $password');

    if (email != null && password != null) {
      _authenticateWithBiometrics();
    }
  }

  // Função para autenticação biométrica (impressão digital ou reconhecimento facial)
  Future<void> _authenticateWithBiometrics() async {
    try {
      print('Iniciando autenticação biométrica...');
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentique-se para fazer login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        print('Autenticação biométrica bem-sucedida.');
        // Se a autenticação biométrica for bem-sucedida, fazer login no Firebase
        final credentials = await _readCredentials();
        if (credentials['email'] != null && credentials['password'] != null) {
          _signInWithEmailAndPassword(credentials['email']!, credentials['password']!);
        } else {
          print('Credenciais não encontradas após autenticação biométrica.');
        }
      } else {
        print('Autenticação biométrica falhou.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Autenticação falhou. Tente novamente.")),
        );
      }
    } on PlatformException catch (e) {
      print('Erro na autenticação biométrica: $e');
      if (e.code == 'NotAvailable') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nenhuma biometria disponível no dispositivo.")),
        );
      } else if (e.code == 'NotEnrolled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nenhuma credencial biométrica configurada.")),
        );
      } else if (e.code == 'LockedOut') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Muitas tentativas falhas. Tente mais tarde.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro durante a autenticação biométrica.")),
        );
      }
    }
  }

  // Função para realizar o login com email e senha e salvar as credenciais
  void _login() async {
    print('Iniciando login com email e senha...');
    Map<String, dynamic>? userData = await _authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (userData != null) {
      String name = userData['name'] ?? 'Funcionário'; // Obtém o nome do Firestore
      String urlImage = userData['image_url'] ?? 'https://teste.com';
      print('Login bem-sucedido. Nome do usuário: $name');

      // Salvando as credenciais no armazenamento seguro
      await _saveCredentials(_emailController.text.trim(), _passwordController.text.trim());
      print('Credenciais salvas com sucesso.');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(name: name, imageUrl: urlImage,)),
      );
    } else {
      print('Erro ao realizar login.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha no login. Verifique suas credenciais.")),
      );
    }
  }


  // Função para salvar credenciais localmente
  Future<void> _saveCredentials(String email, String password) async {
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: password);
    print('Credenciais salvas: Email - $email, Senha - $password');
  }

  // Função para ler credenciais salvas
  Future<Map<String, String?>> _readCredentials() async {
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    print('Lendo credenciais armazenadas: Email - $email, Senha - $password');
    return {'email': email, 'password': password};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [Color(0xFF7B2CBF).withOpacity(0.6), Color(0xFFD8B4FE).withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'FastPoint',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'BalooBhaijaan',
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 32),
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
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ),
              SizedBox(height: 70),
              if (_isBiometricAvailable)
                GestureDetector(
                  onTap: _authenticateWithBiometrics,
                  child: Image.asset(
                    'assets/fingerprint.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              Text(
                'Acesse com a sua Digital',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Função para realizar o login com email e senha usando as credenciais salvas
  Future<void> _signInWithEmailAndPassword(String email, String password) async {
    print('Tentando login com email: $email');
    Map<String, dynamic>? userData = await _authService.signInWithEmail(email, password);

    if (userData != null) {
      String name = userData['name'] ?? 'Funcionário'; // Obtém o nome do Firestore
      String urlImage = userData['image_url'] ?? 'https://teste.com';
      print('Login bem-sucedido. Nome do usuário: $name');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(name: name, imageUrl: urlImage)),
      );
    } else {
      print('Erro ao realizar login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao realizar login. Verifique suas credenciais.")),
      );
    }
  }
}
