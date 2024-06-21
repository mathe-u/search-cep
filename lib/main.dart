import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search CEP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textCep = TextEditingController();

  Future<void> searchCep() async {
    final String cep = textCep.text.replaceAll('-', '');

    if (!validCep(cep)) {
      showError(
        'Formato de CEP inválido. Use o formato 99999-999 ou 99999999.',
      );
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('https://cep.awesomeapi.com.br/json/$cep'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(cepData: data),
          ),
        );
      } else if (response.statusCode == 400) {
        showError('CEP invalido');
      } else if (response.statusCode == 404) {
        showError('O CEP $cep nao foi encontrado');
      } else {
        showError('Erro na pesquisa do CEP');
      }
    } catch (e) {
      showError('Erro na pesquisa do CEP');
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool validCep(String cep) {
    final RegExp cepRegex = RegExp(r'^\d{8}$');
    return cepRegex.hasMatch(cep);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Busque seu CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textCep,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchCep,
              child: const Text('Pesquisar'),
            ),
          ],
        ),
      ),
    );
  }
}
