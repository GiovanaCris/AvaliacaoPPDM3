import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

const Color _primaryColor = Color.fromARGB(255, 49, 0, 114); // Roxo Escuro
const Color _accentColor = Color(0xFF743BBC); // Púrpura
const Color _backgroundColor = Colors.white;

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
        SnackBar(
          content: Text("Erro ao carregar os pedidos: $e", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removerPedido(String pedidoId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Pedidos")
          .doc(pedidoId)
          .delete();

      setState(() {
        pedidos.removeWhere((pedido) => pedido["id"] == pedidoId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pedido removido com sucesso!", style: TextStyle(color: _backgroundColor)),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao remover pedido: $e", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red),
      );
    }
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
          "Histórico de Compras",
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
                : pedidos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 20),
                            Text(
                              "Nenhum histórico de compra encontrado.",
                              style: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Que tal começar a tecer novas memórias?",
                              style: GoogleFonts.montserrat(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];
                          return OrderHistoryCard(
                            pedido: pedido,
                            onRemove: removerPedido,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final Function(String pedidoId) onRemove;

  const OrderHistoryCard({
    super.key,
    required this.pedido,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final String produto = pedido["produto"] ?? "Item Desconhecido";
    final int quantidade = pedido["quantidade"] ?? 0;
    final double total = (pedido["total"] as num?)?.toDouble() ?? 0.0;
    final Timestamp? timestamp = pedido["data"] as Timestamp?;
    final DateTime? data = timestamp?.toDate();
    final String pedidoId = pedido["id"] ?? "";

    final String dataFormatada = data != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(data)
        : "Data Indisponível";
    final String totalFormatado = NumberFormat.currency(
            locale: 'pt_BR', symbol: 'R\$')
        .format(total);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Pedido #$pedidoId",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                    ),
                  ),
                ),
                Text(
                  dataFormatada,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: _primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Quantidade: $quantidade",
                        style:
                            GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Pago:",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      totalFormatado,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => onRemove(pedidoId),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  label: Text(
                    "Remover",
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}