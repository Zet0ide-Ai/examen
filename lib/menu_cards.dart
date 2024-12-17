import 'package:flutter/material.dart';
import 'transfer_screen.dart'; // Importa la pantalla de transferencias
import 'proximamente.dart';

class MenuCardsScreen extends StatefulWidget {
  final String currentUserId; // ID del usuario logueado

  const MenuCardsScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MenuCardsScreenState createState() => _MenuCardsScreenState();
}

class _MenuCardsScreenState extends State<MenuCardsScreen> {
  Color _backgroundColor = Colors.purple; // Color inicial del fondo

  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor = _backgroundColor == Colors.purple ? const Color.fromARGB(255, 23, 186, 197) : Colors.purple;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Menú',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildMenuButton(
                  'Transferencias',
                  Icons.transfer_within_a_station,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransferScreen(currentUserId: widget.currentUserId),
                      ),
                    );
                  },
                ),
                _buildMenuButton('Créditos', Icons.credit_card,
                 onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProximamenteScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuButton('Beneficios', Icons.card_giftcard,
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProximamenteScreen(),
                      ),
                    );
                  },),
                _buildMenuButton('Pagos', Icons.payment,
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProximamenteScreen(),
                      ),
                    );
                  },),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changeBackgroundColor,
              child: const Text('Cambiar Fondo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
