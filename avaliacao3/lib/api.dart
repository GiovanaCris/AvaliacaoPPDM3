import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiPage extends StatefulWidget {
  const ApiPage({super.key});

  @override
  State<ApiPage> createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  String? value; //Variável que vai armazenar o valor

  @override //precisa do override para subscrever o valor anterior
  void initState() {
    //Função auxilia a resetar o estado da página toda vez que entrar nela
    super.initState(); //super == sempre rodar essa função
    getvalue(); //Funcao que busca o valor
  }

  void getvalue() async {
    //Função que busca o valor, async espera um retorno específico para fazer algo
    final response = await http.get(Uri.parse("https://dummyjson.com/products"));

    if (response.statusCode == 200) {
      //Se o status da requisição for ok
      //json decode transforma as propriedades do json em tipos de dados
      final data = jsonDecode(response.body);

      setState(() {
        value = data["products"][0]["title"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: value == null ? CircularProgressIndicator() : Text("$value"),
      ),
    );
  }
}
