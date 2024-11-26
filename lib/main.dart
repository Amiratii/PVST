import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Previsao {
  final String data;
  final double temperatura;
  final double umidade;
  final double luminosidade;
  final double vento;
  final double chuva;
  final String unidade;

  Previsao({
    required this.data,
    required this.temperatura,
    required this.umidade,
    required this.luminosidade,
    required this.vento,
    required this.chuva,
    required this.unidade,
  });

  factory Previsao.fromJson(Map<String, dynamic> json) {
    return Previsao(
      data: json['data'],
      temperatura: json['temperatura'],
      umidade: json['umidade'],
      luminosidade: json['luminosidade'],
      vento: json['vento'],
      chuva: json['chuva'],
      unidade: json['unidade'],
    );
  }
}

void main() {
  runApp(PrevisaoApp());
}

class PrevisaoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo hoje',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: PrevisaoPage(),
    );
  }
}

class PrevisaoPage extends StatefulWidget {
  @override
  _PrevisaoPageState createState() => _PrevisaoPageState();
}

class _PrevisaoPageState extends State<PrevisaoPage> {
  late Future<List<Previsao>> previsoes;

  @override
  void initState() {
    super.initState();
    previsoes = fetchPrevisao();
  }

  Future<List<Previsao>> fetchPrevisao() async {
    final response =
        await http.get(Uri.parse('https://demo3520525.mockable.io/previsao'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Previsao.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar a previsão do tempo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('☀️ Previsão do Tempo hoje ☁️ '),
      ),
      body: FutureBuilder<List<Previsao>>(
        future: previsoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(2),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final previsao = snapshot.data![index];
                return Card(
                  color: Color(0xffa9c7f8),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      'Data: ${previsao.data}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        Text(
                            'Temperatura ☀️: ${previsao.temperatura}°${previsao.unidade}',
                            style: TextStyle(fontSize: 18)),
                        Text('Umidade 💦: ${previsao.umidade}%',
                            style: TextStyle(fontSize: 18)),
                        Text('Luminosidade  ⛅: ${previsao.luminosidade} lux',
                            style: TextStyle(fontSize: 18)),
                        Text('Vento 💨: ${previsao.vento} m/s',
                            style: TextStyle(fontSize: 18)),
                        Text('Chuva  ☔: ${previsao.chuva} mm',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhuma previsão disponível.'));
          }
        },
      ),
    );
  }
}
