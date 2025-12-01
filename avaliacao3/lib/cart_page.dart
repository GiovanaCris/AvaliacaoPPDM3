// import 'package:flutter/material.dart';

// class CartPage extends StatelessWidget {
//   final Map<String, dynamic> produto;

//   const CartPage({super.key, required this.produto});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 116, 59, 180),
//         title: const Text(
//           "Carrinho",
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 produto["imagemProduto"],
//                 height: 250,
//                 fit: BoxFit.cover,
//               ),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               produto["Nome"],
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color.fromARGB(255, 78, 15, 160),
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               "R\$ ${produto["preco"].toStringAsFixed(2)}",
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),

//             const Spacer(),

//             ElevatedButton(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text("Função de comprar ainda não implementada!")),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 78, 15, 160),
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "Finalizar Compra",
//                 style: TextStyle(fontSize: 18),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> produto;

  const CartPage({super.key, required this.produto});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String userId = "gigi"; // usuário logado
  int quantidade = 1;

  @override
  void initState() {
    super.initState();
    carregarQuantidade();
  }

  // ------------------ GET QUANTIDADE ------------------
  Future<void> carregarQuantidade() async {
    final doc = await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(widget.produto["id"])
        .get();

    if (doc.exists) {
      setState(() {
        quantidade = doc["quantidade"];
      });
    }
  }

  // ------------------ PUT: Aumentar quantidade ------------------
  Future<void> aumentarQuantidade() async {
    setState(() => quantidade++);

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(widget.produto["id"])
        .set({
      "Nome": widget.produto["Nome"],
      "preco": widget.produto["preco"],
      "imagemProduto": widget.produto["imagemProduto"],
      "quantidade": quantidade,
    }, SetOptions(merge: true));
  }

  // ------------------ PUT: Diminuir quantidade ------------------
  Future<void> diminuirQuantidade() async {
    if (quantidade == 1) return;

    setState(() => quantidade--);

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(widget.produto["id"])
        .update({"quantidade": quantidade});
  }

  // ------------------ DELETE PRODUTO ------------------
  Future<void> removerProduto() async {
    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(widget.produto["id"])
        .delete();

    Navigator.pop(context);
  }

  // ------------------ POST COMPRA ------------------
  Future<void> finalizarCompra() async {
    await FirebaseFirestore.instance.collection("Pedidos").add({
      "usuario": userId,
      "produto": widget.produto["Nome"],
      "quantidade": quantidade,
      "total": quantidade * widget.produto["preco"],
      "data": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compra realizada com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.produto;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 116, 59, 180),
        title: const Text("Carrinho", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(p["imagemProduto"], height: 250, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            Text(
              p["Nome"],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              "R\$ ${p["preco"].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, color: Colors.green),
            ),

            const SizedBox(height: 20),

            // ---------------- QUANTIDADE ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: diminuirQuantidade,
                  icon: const Icon(Icons.remove_circle, size: 32, color: Colors.red),
                ),
                Text(
                  quantidade.toString(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: aumentarQuantidade,
                  icon: const Icon(Icons.add_circle, size: 32, color: Colors.green),
                ),
              ],
            ),

            const Spacer(),

            // --------------- DELETE ----------------
            TextButton(
              onPressed: removerProduto,
              child: const Text(
                "Remover item",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            // --------------- POST COMPRAR ----------------
            ElevatedButton(
              onPressed: finalizarCompra,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 78, 15, 160),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              ),
              child: const Text("Finalizar Compra", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
