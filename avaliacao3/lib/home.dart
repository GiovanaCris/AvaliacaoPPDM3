import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avaliacao3/cart_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> produtos = [];
  bool loading = true;

  String frase = ""; // FRASE DA API

  @override
  void initState() {
    super.initState();
    carregarProdutosFirebase();
    criarFrase();
  }

  // ---------------- CARREGAR FRASE DA API ----------------
  Future<void> criarFrase() async {
    try {
      final url = Uri.parse("https://frases.docapi.dev/frase/criar");

      final body = {
        "frase":
            "Em cada peça produzida, um pedacinho do meu coração e da minha história!",
        "nomeAutor": "Giovana",
      };

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);

        setState(() {
          frase = json["resposta"]["frase"] ?? "Frase criada!";
        });

        Text("Frase criada com sucesso: ${json['resposta']}");
      } else {
        setState(() {
          frase = "Erro ao criar frase.";
        });
        Text("Status code: ${resp.statusCode}");
      }
    } catch (e) {
      setState(() {
        frase = "Erro inesperado ao criar frase.";
      });
      Text("Erro: $e");
    }
  }

  // ---------------- CARREGAR PRODUTOS FIREBASE ----------------
  Future<void> carregarProdutosFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Produtos")
          .get();

      final lista = snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();

      Text("Produtos carregados: $lista");

      setState(() {
        produtos = lista;
        loading = false;
      });
    } catch (e) {
      Text("Erro ao carregar produtos: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------- APP BAR -------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: const Color.fromARGB(255, 212, 210, 244),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              children: [
                Image.asset("assets/crochet.png", height: 80),
                const SizedBox(width: 8),
                const Text(
                  "Ma&Gi Crochet",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 111, 59, 180),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),

      // ------------------ BODY -------------------
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "ITENS DE ARTE E ARTESANATO",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 116, 59, 180),
            ),
          ),

          // ------ FRASE DA API ------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              frase.isEmpty ? "Carregando frase..." : "\"$frase\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 82, 45, 145),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : produtos.isEmpty
                ? const Center(child: Text("Nenhum produto encontrado"))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final p = produtos[index];

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      p["imagemProduto"],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        color: Colors.black54,
                                        child: Column(
                                          children: [
                                            Text(
                                              p["Nome"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "R\$ ${p["preco"].toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    116,
                                    59,
                                    180,
                                  ),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CartPage(produto: p),
                                    ),
                                  );
                                },
                                child: const Text("Comprar"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 50,
        color: const Color.fromARGB(255, 212, 210, 244),
        child: const Center(
          child: Text(
            "Art & Craft Store",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 71, 59, 180),
            ),
          ),
        ),
      ),
    );
  }
}
