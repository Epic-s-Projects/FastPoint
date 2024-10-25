import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore

  // Login do usuário com email e senha e retorna os dados do Firestore
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Busca os dados adicionais no Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Converte os dados do documento para Map e inclui o image_url
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          return {
            'name': userData['name'],
            'image_url': userData['image_url'], // Adiciona o campo image_url aqui
          };
        } else {
          print('Usuário não encontrado no Firestore');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao realizar login: $e');
      return null;
    }
  }

  // Logout do usuário
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Erro ao realizar logout: $e');
      return null;
    }
  }

  Future<void> baterPonto() async {
    try {
      // Obtém o UID do usuário autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Usuário não autenticado");
        return;
      }

      // Obtém a localização do usuário
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Cria um documento com timestamp e geolocalização na subcoleção 'marcacao_pontos'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('marcacao_pontos')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      print("Ponto registrado com sucesso!");

    } catch (e) {
      print("Erro ao bater ponto: $e");
    }
  }
}