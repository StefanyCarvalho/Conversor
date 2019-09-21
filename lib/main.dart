import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?key=5e6eb30e";

void main() async {
  // a função main agora é assincrona
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        primaryColor: Colors.white,
        cursorColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)))),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _realControler =
      TextEditingController(); // Variavel que faz o controle e recebe o valor que for digitado no campo real
  final _dolarControler = TextEditingController();
  final _euroControler = TextEditingController();

  final _dolarFocus = FocusNode();
  final _euroFocus = FocusNode();

  double dolar;
  double euro;
  @override
  void dispose() {
    _euroFocus.dispose();
    _dolarFocus.dispose();
    super.dispose();
  }

  void _requestFocus(FocusScopeNode node, FocusNode focusNode) {
    node.requestFocus(focusNode); //pegando a caixa de texto que deve ir o foco
  }

  void _clearTextFields(String text) {
    if (text.isEmpty) {
      _dolarControler.clear();
      _realControler.clear();
      _euroControler.clear();
    }
  }

  void _realChanged(String text) {
    // essas funções é para ver quando o valor dos campos forem alterados

    _clearTextFields(text);
    if (text.isNotEmpty) {
      double real = double.parse(text);
      _dolarControler.text = (real / dolar).toStringAsFixed(2);
      _euroControler.text = (real / euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text) {
    _clearTextFields(text);

    if (text.isNotEmpty) {
      double dolar = double.parse(text); // faz a conversão do text para double
      _realControler.text = (dolar * this.dolar).toStringAsFixed(2);
      _euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    _clearTextFields(text);

    if (text.isNotEmpty) {
      double euro = double.parse(text);
      _realControler.text = (dolar * this.dolar).toStringAsFixed(2);
      _dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = FocusScope.of(context);
    return GestureDetector(
      onTap: focus.unfocus,
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title: Text(
            "Conversor",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            // ele vai construir a tela dependendo do que estiver no getData()
            future: getData(),
            builder: (context, snapshot) {
              print(snapshot.connectionState);

              ///aqui estava o switch case, substituimos pelo if para verificar o estado da conexão
              if (snapshot.hasError) {
                /// verificando se tem algum
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                if (!snapshot.hasData)

                  /// verificando se tem algum dado, ele verifica porque ele esta buscando os dados do Json
                  return Center(
                    child: Text(
                      "Carregando Dados...",
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.black,
                          size: 120.0,
                        ),
                        _buildTextField(
                            "Reais", "R\$", _realControler, _realChanged,
                            onSubmitted: (s) =>
                                focus.requestFocus(_dolarFocus)),
                        Divider(),
                        _buildTextField(
                            "Dolares", "US\$", _dolarControler, _dolarChanged,
                            focusNode: _dolarFocus,
                            onSubmitted: (s) => focus.requestFocus(_euroFocus)),
                        Divider(),
                        _buildTextField(
                            "Euros", "€", _euroControler, _euroChanged,
                            focusNode: _euroFocus),
                      ],
                    ),
                  );
                }
              }
            }),
      ),
    ); //Scaffold
  }
}

Widget _buildTextField(
    String label, String prefix, TextEditingController c, Function function,
    {FocusNode focusNode,
    Function(String) onSubmitted,
    TextInputAction textInputAction = TextInputAction.done}) {
  //esta função chama o nome da label e o prefixo, otimizando o código

  return TextField(
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    focusNode: focusNode,
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.black, fontSize: 25.0),
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
