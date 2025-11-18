import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Apiall extends StatefulWidget {
  const Apiall({super.key});

  @override
  State<Apiall> createState() => _ApiAllState();
}

class _ApiAllState extends State<Apiall> {
  List<dynamic>? value; //Variável que vai armazenar o valor

  @override //precisa do override para subscrever o valor anterior
  void initState() {
    //Função auxilia a resetar o estado da página toda vez que entrar nela
    super.initState(); //super == sempre rodar essa função
    getvalue(); //Funcao que busca o valor
  }

  void getvalue() async {
    //Função que busca o valor, async espera um retorno específico para fazer algo
    final response = await http.get(
      Uri.parse("https://dummyjson.com/products"),
    );

    if (response.statusCode == 200) {
      //Se o status da requisição for ok
      //json decode transforma as propriedades do json em tipos de dados
      final data = jsonDecode(response.body);

      setState(() {
        value = data["products"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: value == null
            ? CircularProgressIndicator()
            : Center(
                //ListView é a rolagem de tela .builder vai construir algo
                child: ListView.builder(
                  itemCount: value!.length, //ItemCount = Quantidade de items
                  itemBuilder: (context, index) {
                    final item = value![index];
                    return Container(
                      width: 150,
                      height: 150,
                      color: Colors.blue,
                      child: Center(child: Text("${item["Name"]}")),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
