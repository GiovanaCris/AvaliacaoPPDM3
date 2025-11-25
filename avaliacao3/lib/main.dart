import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:avaliacao3/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController user = TextEditingController();
  final TextEditingController password = TextEditingController();

  final String correctUser = "gigi";
  final String correctPassword = "gigi123";

  String erro = "";

  void login() {
    if (user.text == correctUser && password.text == correctPassword) {
      setState(() {
        erro = "";
      });
    } else {
      setState(() {
        erro = "Erro: Existem credenciais erradas";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Faça seu login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 78, 15, 160),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 600,
                child: TextFormField(
                  controller: user,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Usuário',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: 600,
                child: TextFormField(
                  controller: password,
                  maxLength: 20,
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Senha',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  login();

                  if (erro.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 78, 15, 160),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Text(
                erro,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   List<Map<String, dynamic>> produtos = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     carregarProdutosFirebase();
//   }

//   // ---------------- CARREGAR PRODUTOS DO FIRESTORE ----------------
//   Future<void> carregarProdutosFirebase() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection("Produtos").get();

//       final lista = snapshot.docs.map((doc) {
//         return doc.data();
//       }).toList();

//       setState(() {
//         produtos = lista;
//         loading = false;
//       });
//     } catch (e) {
//       print("Erro ao carregar produtos: $e");
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       // ------------------- APP BAR -------------------
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           color: const Color.fromARGB(255, 212, 210, 244),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SafeArea(
//             child: Row(
//               children: [
//                 Image.asset("assets/crochet.png", height: 80),
//                 const SizedBox(width: 8),
//                 const Text(
//                   "Art & Craft Store",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 111, 59, 180),
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () {},
//                   child: Image.asset("assets/user.png", height: 35),
//                 ),
//                 const SizedBox(width: 20),
//               ],
//             ),
//           ),
//         ),
//       ),

//       // ------------------ BODY -------------------
//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           const Text(
//             "ITENS DE ARTE E ARTESANATO",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color.fromARGB(255, 116, 59, 180),
//             ),
//           ),

//           const SizedBox(height: 10),

//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : GridView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.75,
//                     ),
//                     itemCount: produtos.length,
//                     itemBuilder: (context, index) {
//                       final p = produtos[index];

//                       return Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               Image.network(
//                                 p["imagemProduto"],
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) =>
//                                     const Icon(Icons.error, color: Colors.red),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   color: Colors.black54,
//                                   child: Column(
//                                     children: [
//                                       Text(
//                                         p["Nome"],
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         "R\$ ${p["preco"].toStringAsFixed(2)}",
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),

//       // ---------------- FOOTER -----------------
//       bottomNavigationBar: Container(
//         height: 50,
//         color: const Color.fromARGB(255, 212, 210, 244),
//         child: const Center(
//           child: Text(
//             "Art & Craft Store",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color.fromARGB(255, 71, 59, 180),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
