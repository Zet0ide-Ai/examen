import 'package:flutter/material.dart';
import 'menu_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String userId = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingrese usuario y contraseña")),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData['contraseña'] == password) {
          // Inicio de sesión exitoso
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MenuCardsScreen(currentUserId: userId),
            ),
          );
        } else {
          // Contraseña incorrecta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contraseña incorrecta")),
          );
        }
      } else {
        // Usuario no encontrado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario no encontrado")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciar Sesión"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Usuario",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Ocultar contraseña
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Iniciar Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
