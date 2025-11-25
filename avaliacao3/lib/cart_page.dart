// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({super.key});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {

//   Future<void> updateQuantity(String id, int newQty) async {
//     if (newQty <= 0) return;
//     await FirebaseFirestore.instance.collection("cart").doc(id).update({
//       "quantity": newQty,
//     });
//   }

//   Future<void> deleteItem(String id) async {
//     await FirebaseFirestore.instance.collection("cart").doc(id).delete();
//   }

//   Future<void> finalizarCompra(List cartItems) async {
//     double total = 0;
//     for (var item in cartItems) {
//       total += item["price"] * item["quantity"];
//     }

//     await FirebaseFirestore.instance.collection("purchases").add({
//       "items": cartItems,
//       "total": total,
//       "created_at": DateTime.now(),
//     });

//     // limpar carrinho
//     final cart = FirebaseFirestore.instance.collection("cart").get();
//     (await cart).docs.forEach((doc) => doc.reference.delete());

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Compra realizada com sucesso!")),
//     );

//     Navigator.pop(context);
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Carrinho"),
//         backgroundColor: const Color.fromARGB(255, 78, 15, 160),
//       ),

//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection("cart").snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(
//               child: Text("Seu carrinho está vazio"),
//             );
//           }

//           double total = docs.fold(0, (sum, item) =>
//               sum + (item["price"] * item["quantity"]));

//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, i) {
//                     final item = docs[i];
//                     final data = item.data();

//                     return Card(
//                       margin: const EdgeInsets.all(12),
//                       child: ListTile(
//                         leading: Image.network(data["img_url"], width: 50),
//                         title: Text(data["name"]),
//                         subtitle: Text("R\$ ${data["price"]}"),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.remove),
//                               onPressed: () => updateQuantity(
//                                   item.id, data["quantity"] - 1),
//                             ),
//                             Text("${data["quantity"]}"),
//                             IconButton(
//                               icon: const Icon(Icons.add),
//                               onPressed: () => updateQuantity(
//                                   item.id, data["quantity"] + 1),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => deleteItem(item.id),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Total: R\$ ${total.toStringAsFixed(2)}",
//                       style:
//                           const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(255, 78, 15, 160),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 80),
//                       ),
//                       onPressed: () => finalizarCompra(
//                         docs.map((e) => e.data()).toList(),
//                       ),
//                       child: const Text(
//                         "Finalizar compra",
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
