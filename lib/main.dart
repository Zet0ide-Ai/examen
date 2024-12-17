import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.green; // Color inicial del fondo

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Banco BCI - App Oficial'),
        ),
        body: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              color: backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://play-lh.googleusercontent.com/n9LjvPWCGCs4n1QfsM2VzSco8SB42T52EgwRBZ9wtR8eD1YWyu1vFShtrseiYiRp2Q',
                      height: 150,
                      width: 150,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 150,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen(),)
                        );
                      },
                      child: const Text('Inicio'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
