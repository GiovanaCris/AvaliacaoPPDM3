import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String userId = "gigi"; // substitua pelo usuário logado

  // Lista de itens do carrinho
  List<Map<String, dynamic>> carrinho = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarCarrinho();
  }

  // ------------------ CARREGAR CARRINHO ------------------
  Future<void> carregarCarrinho() async {
    setState(() => loading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .get();

    final itens = snapshot.docs.map((doc) {
      final data = doc.data();
      data["id"] = doc.id; // salvar id do documento
      return data;
    }).toList();

    setState(() {
      carrinho = itens;
      loading = false;
    });
  }

  // ------------------ AUMENTAR QUANTIDADE ------------------
  Future<void> aumentarQuantidade(Map<String, dynamic> produto) async {
    produto["quantidade"] = (produto["quantidade"] ?? 1) + 1;

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .set(produto, SetOptions(merge: true));

    setState(() {}); // Atualiza UI
  }

  // ------------------ DIMINUIR QUANTIDADE ------------------
  Future<void> diminuirQuantidade(Map<String, dynamic> produto) async {
    if ((produto["quantidade"] ?? 1) <= 1) return;

    produto["quantidade"] = produto["quantidade"] - 1;

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .update({"quantidade": produto["quantidade"]});

    setState(() {}); // Atualiza UI
  }

  // ------------------ REMOVER PRODUTO ------------------
  Future<void> removerProduto(Map<String, dynamic> produto) async {
    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .delete();

    carregarCarrinho(); // Recarrega lista
  }

  // ------------------ FINALIZAR COMPRA ------------------
  Future<void> finalizarCompra() async {
    for (var produto in carrinho) {
      await FirebaseFirestore.instance.collection("Pedidos").add({
        "usuario": userId,
        "produto": produto["Nome"],
        "quantidade": produto["quantidade"],
        "total": (produto["quantidade"] ?? 1) * produto["preco"],
        "data": Timestamp.now(),
      });

      // Remove do carrinho
      await FirebaseFirestore.instance
          .collection("Carrinho")
          .doc(userId)
          .collection("itens")
          .doc(produto["id"])
          .delete();
    }

    setState(() {
      carrinho = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compra finalizada com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color.fromARGB(255, 49, 0, 114),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Texto à esquerda
                Text(
                  "A loja de fios mais amada do Brasil  |  Ma&Gi Crochê",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Ícones das redes sociais à direita
                Row(
                  children: const [
                    Icon(
                      FontAwesomeIcons.facebookF,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 12),
                    Icon(
                      FontAwesomeIcons.instagram,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : carrinho.isEmpty
          ? const Center(child: Text("Seu carrinho está vazio"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: carrinho.length,
              itemBuilder: (context, index) {
                final p = carrinho[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p["imagemProduto"],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p["Nome"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "R\$ ${p["preco"].toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // A parte que você quer centralizar verticalmente
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Centraliza horizontalmente
                              children: [
                                Text(
                                  "Deletar item:",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ), // Espaço entre o texto e o ícone
                                IconButton(
                                  onPressed: () => removerProduto(p),
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Alinha o conteúdo à esquerda
                          children: [
                            // Coluna para empilhar o texto "Quantidade" em cima dos ícones
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // Alinha à esquerda
                              children: [
                                Text(
                                  "Quantidade:",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ), // Espaço entre o texto e os ícones
                                // Linha para os ícones de diminuir e aumentar a quantidade
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => diminuirQuantidade(p),
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      (p["quantidade"] ?? 1).toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => aumentarQuantidade(p),
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: carrinho.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: finalizarCompra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF743BBC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Finalizar Compra",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
