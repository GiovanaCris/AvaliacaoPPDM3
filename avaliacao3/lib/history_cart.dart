import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoricoComprasPage extends StatefulWidget {
  const HistoricoComprasPage({super.key});

  @override
  State<HistoricoComprasPage> createState() => _HistoricoComprasPageState();
}

class _HistoricoComprasPageState extends State<HistoricoComprasPage> {
  final String userId = "gigi"; // Usuário logado
  List<Map<String, dynamic>> pedidos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  // ------------------ CARREGAR PEDIDOS ------------------
  Future<void> carregarPedidos() async {
    setState(() {
      loading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Pedidos")
          .where("usuario", isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> pedidosList = snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();

      setState(() {
        pedidos = pedidosList;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar os pedidos: $e")),
      );
    }
  }

  // ------------------ REMOVER UM PEDIDO ------------------
  Future<void> removerPedido(String pedidoId) async {
    try {
      // Exclui o pedido específico usando o ID
      await FirebaseFirestore.instance
          .collection("Pedidos")
          .doc(pedidoId) // Acessa o pedido específico pelo ID
          .delete();

      // Atualiza a lista após a exclusão
      setState(() {
        pedidos.removeWhere((pedido) => pedido["id"] == pedidoId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido removido com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao remover pedido: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color.fromARGB(255, 49, 0, 114),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
      // Corpo do Scaffold - Histórico de Compras
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? const Center(child: Text("Você ainda não fez nenhuma compra."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final produto = pedido["produto"];
                final quantidade = pedido["quantidade"];
                final total = pedido["total"];
                final data = (pedido["data"] as Timestamp).toDate();
                final pedidoId = pedido["id"]; // ID do pedido

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Quantidade: $quantidade",
                          style: GoogleFonts.montserrat(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total: R\$ ${total.toStringAsFixed(2)}",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Data: ${data.day}/${data.month}/${data.year} - ${data.hour}:${data.minute}",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 25),

                        Text(
                          "Deletar item:",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () =>
                              removerPedido(pedidoId), // Passa o ID do pedido
                          tooltip: 'Remover Pedido',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
