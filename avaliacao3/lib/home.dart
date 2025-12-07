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
      } else {
        setState(() {
          frase = "Erro ao criar frase.";
        });
      }
    } catch (e) {
      setState(() {
        frase = "Erro inesperado ao criar frase.";
      });
    }
  }

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
      setState(() {
        produtos = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildProdutoItem(Map<String, dynamic> p) {
    double precoOriginal = p["precoOriginal"] ?? p["preco"];
    double precoPromocional = p["preco"];
    int descontoPercent = 0;
    if (precoOriginal > precoPromocional) {
      descontoPercent = ((1 - precoPromocional / precoOriginal) * 100).round();
    }
    final pinkColor = const Color.fromARGB(255, 49, 0, 114);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.error, color: Colors.red),
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

            Row(
              children: List.generate(
                5,
                (i) => const Icon(Icons.star, color: Colors.amber, size: 14),
              ),
            ),

            const SizedBox(height: 4),

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
                  backgroundColor: const Color.fromARGB(255, 116, 59, 180),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () async {
                  final userId = "gigi";
                  await FirebaseFirestore.instance
                      .collection("Carrinho")
                      .doc(userId)
                      .collection("itens")
                      .doc(p["id"])
                      .set({
                        "Nome": p["Nome"],
                        "preco": p["preco"],
                        "imagemProduto": p["imagemProduto"],
                        "quantidade": 1,
                      }, SetOptions(merge: true));

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  }
                },
                child: const Text("Comprar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final pinkColor = const Color.fromARGB(255, 49, 0, 114);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final isMobile = screenWidth < 600;

    Widget actionIcon(IconData icon, String text, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: pinkColor, size: isMobile ? 18 : 20),
              if (!isMobile) const SizedBox(height: 4),
              if (!isMobile)
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                    color: pinkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: pinkColor,
          height: isMobile ? 24 : 28,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isMobile || screenWidth > 350)
                Expanded(
                  child: Text(
                    "A loja de fios mais amada do Brasil | Ma&Gi Crochê",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (isLargeScreen) const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.facebookF,
                    color: Colors.white,
                    size: isMobile ? 12 : 14,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Icon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white,
                    size: isMobile ? 12 : 14,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 8 : 12,
          ),
          child: Row(
            children: [
              Image.asset("assets/logo.png", height: isMobile ? 60.0 : 150.0),

              if (isLargeScreen) const SizedBox(width: 24),
              if (isLargeScreen)
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

              if (isLargeScreen) const SizedBox(width: 24),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  actionIcon(Icons.person_outline, "Login", () {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  }),
                  if (!isMobile) const SizedBox(width: 12),
                  actionIcon(Icons.shopping_cart_outlined, "Carrinho", () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    }
                  }),
                  if (!isMobile) const SizedBox(width: 12),
                  actionIcon(Icons.card_travel, "Suas compras", () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoricoComprasPage(),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ],
          ),
        ),

        if (!isLargeScreen)
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              bottom: 8.0,
            ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color.fromARGB(255, 49, 0, 114);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildCustomAppBar(context),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '"$frase"',
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: pinkColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30),

          AspectRatio(
            aspectRatio: 3.5 / 1,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 45),
          Center(
            child: Text(
              "Conheça nossos produtos",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  )
                : produtos.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum produto encontrado",
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      double itemMaxWidth = 250;
                      if (constraints.maxWidth < 600) {
                        itemMaxWidth = 180;
                      }

                      return GridView.builder(
                        primary: false,
                        shrinkWrap: true,

                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: itemMaxWidth,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: produtos.length,
                        itemBuilder: (context, index) {
                          return _buildProdutoItem(produtos[index]);
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          const ResponsiveFooter(),
        ],
      ),
    );
  }
}

class ResponsiveFooter extends StatelessWidget {
  const ResponsiveFooter({super.key});

  final Color footerColor = const Color.fromARGB(255, 34, 34, 34);
  final Color textColor = Colors.white70;
  final Color buttonColor = const Color.fromARGB(255, 49, 0, 114);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 700;

        return Container(
          width: double.infinity,
          color: footerColor,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 80,
            vertical: isMobile ? 20 : 30,
          ),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ma&Gi Crochê | A sua Loja Online de crochê",
              style: GoogleFonts.montserrat(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Created By: Giovana Cristina | 2025",
              style: GoogleFonts.montserrat(color: textColor, fontSize: 12),
            ),
          ],
        ),

        // Botão de Assinatura
        TextButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Assinar News",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Ma&Gi Crochê | A sua Loja Online de crochê",
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "Created By: Giovana Cristina | 2025",
          style: GoogleFonts.montserrat(color: textColor, fontSize: 11),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Assinar News",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
