import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avaliacao3/main.dart';

const Color _primaryColor = Color.fromARGB(255, 49, 0, 114);
const Color _accentColor = Color(0xFF743BBC);
const Color _backgroundColor = Colors.white;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String userId = "gigi";
  List<Map<String, dynamic>> carrinho = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarCarrinho();
  }

  Future<void> carregarCarrinho() async {
    setState(() => loading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .get();

    final itens = snapshot.docs.map((doc) {
      final data = doc.data();
      data["id"] = doc.id;
      return data;
    }).toList();

    setState(() {
      carrinho = itens;
      loading = false;
    });
  }

  Future<void> aumentarQuantidade(Map<String, dynamic> produto) async {
    produto["quantidade"] = (produto["quantidade"] ?? 1) + 1;

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .set(produto, SetOptions(merge: true));

    setState(() {});
  }

  Future<void> diminuirQuantidade(Map<String, dynamic> produto) async {
    if ((produto["quantidade"] ?? 1) <= 1) return;

    produto["quantidade"] = produto["quantidade"] - 1;

    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .update({"quantidade": produto["quantidade"]});

    setState(() {});
  }

  Future<void> removerProduto(Map<String, dynamic> produto) async {
    await FirebaseFirestore.instance
        .collection("Carrinho")
        .doc(userId)
        .collection("itens")
        .doc(produto["id"])
        .delete();

    carregarCarrinho();
  }

  Future<void> finalizarCompra() async {
    for (var produto in carrinho) {
      await FirebaseFirestore.instance.collection("Pedidos").add({
        "usuario": userId,
        "produto": produto["Nome"],
        "quantidade": produto["quantidade"],
        "total": (produto["quantidade"] ?? 1) * produto["preco"],
        "data": Timestamp.now(),
      });

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

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Compra finalizada com sucesso!",
            style: TextStyle(color: _backgroundColor),
          ),
          backgroundColor: _primaryColor,
        ),
      );
    }
  }

  double get totalCarrinho {
    double total = 0.0;
    for (var p in carrinho) {
      total += (p["quantidade"] ?? 1) * (p["preco"] ?? 0.0);
    }
    return total;
  }

  Widget _buildCartItem(Map<String, dynamic> p) {
    final double subtotal = (p["quantidade"] ?? 1) * (p["preco"] ?? 0.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p["imagemProduto"] ?? "https://via.placeholder.com/80",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p["Nome"] ?? "Produto Desconhecido",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "R\$ ${p["preco"].toStringAsFixed(2)} / un",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão de Deletar
                IconButton(
                  onPressed: () => removerProduto(p),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24,
                  ),
                  tooltip: "Remover Item",
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => diminuirQuantidade(p),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (p["quantidade"] ?? 1).toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => aumentarQuantidade(p),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Subtotal:",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "R\$ ${subtotal.toStringAsFixed(2)}",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Resumo da Compra",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const Divider(height: 16, thickness: 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "R\$ ${totalCarrinho.toStringAsFixed(2)}",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "*Frete e descontos calculados na finalização.",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _backgroundColor,

    appBar: AppBar(
      toolbarHeight: 50,
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: Text(
        "Seu Carrinho", 
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    body: Column(
      children: [
        Container(
          color: _primaryColor,
          padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "A loja de fios mais amada do Brasil | Ma&Gi Crochê",
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator(color: _accentColor))
              : carrinho.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Seu carrinho está vazio",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Adicione alguns itens incríveis!",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: carrinho.length + 2, 
                      itemBuilder: (context, index) {
                        if (index < carrinho.length) {
                          return _buildCartItem(carrinho[index]); 
                        }
                        else if (index == carrinho.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTotalSummary(), 
                                ElevatedButton(
                                  onPressed: finalizarCompra, 
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accentColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: Text(
                                    "Finalizar Compra (R\$ ${totalCarrinho.toStringAsFixed(2)})",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
        ),
      ],
    ),
  );
}
}