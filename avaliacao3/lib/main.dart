import 'package:avaliacao3/home.dart';
import 'package:flutter/material.dart';
import 'package:avaliacao3/api.dart';

void main() {
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApiPage()),
      );
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
                // 👇 AQUI ESTÁ A MUDANÇA
                onPressed: () async {
                  // 1. Tenta fazer o login primeiro (chama sua função existente)
                  await login();

                  // 2. Se der certo, navega para a próxima tela (Tela2)
                  if (context.mounted) {
                    // Verifica se a tela ainda existe antes de navegar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  }
                },

                // 👆 FIM DA MUDANÇA
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
