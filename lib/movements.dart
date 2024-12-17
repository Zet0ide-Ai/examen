import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementsScreen extends StatelessWidget {
  final String currentUserId; // ID del usuario logueado

  const MovementsScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos realizados"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transfers')
            .where('remitente', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay movimientos registrados."));
          }

          final transfers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];
              final destination = transfer['destinatario'];
              final amount = transfer['monto'];
              final date = (transfer['fecha'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("Destinatario: $destination"),
                  subtitle: Text("Fecha: ${date.toLocal()}"),
                  trailing: Text(
                    "\$${amount}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
