import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          return userDoc.data() as Map<String, dynamic>; // Retorna o documento do Firestore
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
}