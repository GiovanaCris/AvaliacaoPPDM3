import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avaliacao3/cart_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:avaliacao3/main.dart';
import 'package:avaliacao3/history_cart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> produtos = [];
  bool loading = true;

  String frase = "";

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
    final pinkColor = const Color.fromARGB(255, 49, 0, 114);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: pinkColor,
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "A loja de fios mais amada do Brasil  |  Ma&Gi Crochê",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

          // AppBar customizada com logo, pesquisa, login e carrinho
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                // Logo
                Image.asset("assets/crochet.png", height: 60),

                const SizedBox(width: 24),

                // Pesquisa expandida
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Faça uma pesquisa...",
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Login / Cadastro e Carrinho
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: pinkColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Login",
                            style: GoogleFonts.montserrat(
                              color: pinkColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: pinkColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Carrinho",
                            style: GoogleFonts.montserrat(
                              color: pinkColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoricoComprasPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.card_travel, color: pinkColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "Suas compras",
                            style: GoogleFonts.montserrat(
                              color: pinkColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '"$frase"',
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: pinkColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          // Grid Promoção
          Container(
            width: 900, // A largura ocupará 100% do espaço disponível
            height: 400, // Ajuste a altura conforme necessário
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/banner.png',
                ), // Caminho correto da imagem
                fit: BoxFit.cover, // Ajusta a imagem para cobrir todo o espaço
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E63)),
                  )
                : produtos.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum produto encontrado",
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.6,
                        ),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final p = produtos[index];

                      // Calculo desconto %
                      double precoOriginal = p["precoOriginal"] ?? p["preco"];
                      double precoPromocional = p["preco"];
                      int descontoPercent = 0;
                      if (precoOriginal > precoPromocional) {
                        descontoPercent =
                            ((1 - precoPromocional / precoOriginal) * 100)
                                .round();
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Desconto no canto
                              if (descontoPercent > 0)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "-$descontoPercent%",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                              Expanded(
                                child: Image.network(
                                  p["imagemProduto"],
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                p["Nome"],
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              // Avaliação em estrelas fixas para demo
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Preços
                              if (descontoPercent > 0)
                                Text(
                                  "R\$ ${precoOriginal.toStringAsFixed(2)}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "R\$ ${precoPromocional.toStringAsFixed(2)}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "no cartão ou 4x de R\$ ${(precoPromocional / 4).toStringAsFixed(2)}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),

                              const SizedBox(height: 8),

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

                                  //ADICIONA NO CARRINHO
                                  onPressed: () async {
                                    final userId = "gigi"; // ou usuário logado
                                    await FirebaseFirestore.instance
                                        .collection("Carrinho")
                                        .doc(userId)
                                        .collection("itens")
                                        .doc(p["id"]) // id do produto
                                        .set({
                                          "Nome": p["Nome"],
                                          "preco": p["preco"],
                                          "imagemProduto": p["imagemProduto"],
                                          "quantidade": 1,
                                        }, SetOptions(merge: true));

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartPage(),
                                      ),
                                    );
                                  },
                                  child: const Text("Comprar"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
