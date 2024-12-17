import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movements.dart';

class TransferScreen extends StatefulWidget {
  final String currentUserId; // ID del usuario logueado

  const TransferScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Map<String, dynamic>? _currentUserData;
  bool _isLoading = false; // Estado del círculo de carga

  Future<void> _fetchUserData() async {
    // Obtiene los datos del usuario actual desde Firestore
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _currentUserData = userDoc.data() as Map<String, dynamic>?;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Usuario no encontrado")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener los datos del usuario: $e")),
      );
    }
  }

  Future<void> _transferMoney(String destinationAccount, int amount) async {
    if (_currentUserData == null) return;

    int currentBalance = _currentUserData!['Saldo'];
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saldo insuficiente para realizar la transferencia")),
      );
      return;
    }

    // Verifica que la cuenta destino exista
    DocumentSnapshot destinationDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(destinationAccount)
        .get();
    if (!destinationDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La cuenta destino no existe")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mostrar círculo de carga
    });

    try {
      // Realiza la transferencia
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Actualiza el saldo del usuario actual
        DocumentReference currentUserRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserId);
        transaction.update(currentUserRef, {"Saldo": currentBalance - amount});

        // Actualiza el saldo del destinatario
        DocumentReference destinationRef = FirebaseFirestore.instance
            .collection('users')
            .doc(destinationAccount);
        int destinationBalance = destinationDoc['Saldo'];
        transaction.update(destinationRef, {"Saldo": destinationBalance + amount});

        // Crea la colección 'transfers' si no existe y registra la transferencia
        CollectionReference transfersRef =
            FirebaseFirestore.instance.collection('transfers');
        QuerySnapshot snapshot = await transfersRef.get();
        int transferCount = snapshot.docs.length;
        String transferId = 'Transfer_${transferCount.toString().padLeft(2, '0')}';

        transfersRef.doc(transferId).set({
          "monto": amount,
          "fecha": DateTime.now(),
          "destinatario": destinationAccount,
          "remitente": widget.currentUserId,
        });
      });

      // Actualiza la interfaz
      await _fetchUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transferencia realizada con éxito")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en la transferencia: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar círculo de carga
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transferencias"),
      ),
      body: _currentUserData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Usuario: ${_currentUserData!['Nombre']}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Saldo disponible: \$${_currentUserData!['Saldo']}",
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _accountController,
                        decoration: const InputDecoration(
                          labelText: "Cuenta destino",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: "Monto a transferir",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              String destinationAccount =
                                  _accountController.text.trim();
                              int? amount =
                                  int.tryParse(_amountController.text);
                              if (destinationAccount.isEmpty ||
                                  amount == null ||
                                  amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Por favor, completa los campos correctamente")),
                                );
                                return;
                              }
                              _transferMoney(destinationAccount, amount);
                            },
                            child: const Text("Transferir"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovementsScreen(
                                    currentUserId: widget.currentUserId,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Movimientos realizados"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }
}
