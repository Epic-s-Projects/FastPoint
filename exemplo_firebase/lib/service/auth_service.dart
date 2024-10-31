import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Autenticação biométrica
  Future<bool> _authenticateWithBiometrics() async {
    try {
      if (!await _localAuth.canCheckBiometrics) {
        print("Biometria não disponível no dispositivo.");
        return false;
      }
      return await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para bater o ponto',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Erro na autenticação biométrica: $e");
      return false;
    }
  }

  // Login com email e senha, retornando os dados do Firestore
  Future<Map<String, dynamic>?> signInWithEmail(String email,
      String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user == null) return null;

      // Busca dados adicionais do Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          user.uid).get();
      return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Erro ao realizar login: $e');
      return null;
    }
  }

  // Logout do usuário
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao realizar logout: $e');
    }
  }

  Future<bool> baterPonto(String authType, {String? password}) async {
    const double latitudeLocal = -22.570691238055606;
    const double longitudeLocal = -47.40385410357194;
    const double raioPermitido = 100.0;

    try {
      // Autenticação condicional
      User? user = _auth.currentUser;
      if (user == null) {
        print("Usuário não autenticado");
        return false;
      }

      // Realiza autenticação com base no tipo
      bool isAuthenticated = false;
      if (authType == 'fingerprint') {
        isAuthenticated = await _authenticateWithBiometrics();
      } else if (authType == 'password' && password != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        isAuthenticated = true;
      }

      if (!isAuthenticated) {
        print("Falha na autenticação.");
        return false;
      }

      // Verifica e solicita permissão de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('Permissão de localização negada');
          return false;
        }
      }

      // Obtém a localização do usuário
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, latitudeLocal, longitudeLocal);

      // Verifica se a distância está dentro do raio permitido
      if (distance > raioPermitido) {
        print("Você não está no local permitido para bater o ponto.");
        return false;
      }

      DateTime now = DateTime.now();
      String today = DateFormat('yyyy-MM-dd').format(now);

      // Referência da coleção de pontos do usuário
      var marcacaoRef = _firestore.collection('users').doc(user.uid).collection(
          'marcacao_pontos');

      // Consulta para pontos do dia
      var marcacoesHoje = await marcacaoRef.where('date', isEqualTo: today)
          .get();
      if (marcacoesHoje.docs.length >= 2) {
        print("O usuário já registrou dois pontos hoje.");
        return false;
      }

      // Determina se é ponto de entrada ou saída
      String tipoPonto = marcacoesHoje.docs.isEmpty ? 'entrada' : 'saida';

      // Cria um documento com timestamp, localização e tipo de ponto no Firestore
      await marcacaoRef.add({
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'tipo': tipoPonto,
        'date': today,
      });

      print("Ponto de $tipoPonto registrado com sucesso!");
      return true; // Registro bem-sucedido
    } catch (e) {
      print("Erro ao bater ponto: $e");
      return false;
    }
  }
}