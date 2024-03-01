// ignore_for_file: empty_catches

import 'package:campo_minado/components/tabuleiro_widget.dart';
import 'package:campo_minado/models/explosao_exception.dart';
import 'package:campo_minado/models/tabuleiro.dart';
import 'package:flutter/material.dart';
import '../components/resultado_widget.dart';

import '../models/campo.dart';

class CampoMinadoApp extends StatefulWidget {
  const CampoMinadoApp({super.key});

  @override
  State<CampoMinadoApp> createState() => _CampoMinadoAppState();
}

class _CampoMinadoAppState extends State<CampoMinadoApp> {
  bool? _venceu;
  Tabuleiro? _tabuleiro;
  int totalBomba = 1;
  final _bombaFocus = FocusNode();

  _reiniciar() {
    setState(() {
      _venceu = null;
      _tabuleiro!.reiniciar();
    });
  }

  _abrir(Campo campo) {
    if (_venceu != null) {
      return;
    }
    setState(() {
      try {
        campo.abrir();
        if (_tabuleiro!.resolvido) {
          _venceu = true;
        }
      } on ExplosaoException {
        _venceu = false;
        _tabuleiro!.revelarBombas();
      }
    });
  }

  _alternarMarcacao(Campo campo) {
    if (_venceu != null) {
      return;
    }
    setState(() {
      campo.alternarMarcacao();
      if (_tabuleiro!.resolvido) {
        _venceu = true;
      }
    });
  }

  Tabuleiro _getTabuleiro(double largura, double altura) {
    if (_tabuleiro == null) {
      int qtdeColunas = 15;
      double tamanhoCampo = largura / qtdeColunas;
      int qtdeLinhas = (altura / tamanhoCampo).floor();

      _tabuleiro = Tabuleiro(
        linhas: qtdeLinhas,
        colunas: qtdeColunas,
        qtdeBombas: totalBomba,
      );
    }
    return _tabuleiro!;
  }

  void _setTotalBomba(int text) {
    setState(() {
      totalBomba = text;
    });
  }

  void recomecar(BuildContext context) {
    FocusScope.of(context).requestFocus(_bombaFocus);
    try {
      _tabuleiro = null;
      _reiniciar();
    } catch (e) {}
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Ocorreu um erro',
        ),
        content: Text(msg, style: const TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: ResultadoWidget(
          venceu: _venceu,
          onReiniciar: _reiniciar,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white),
                      child: TextFormField(
                        maxLength: 3,
                        onChanged: (text) {
                          if (text != '') {
                            _setTotalBomba(int.parse(text));
                          } else {
                            _setTotalBomba(1);
                          }
                        },
                        onFieldSubmitted: (text) {
                          if (int.parse(text) > 359) {
                            _showErrorDialog('Valor muito alto!');
                            _setTotalBomba(1);
                          } else {
                            recomecar(context);
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda
                              width: 4,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors
                                  .white, // Cor da borda quando o campo está em foco
                              width: 2,
                            ),
                          ),
                          hintText: 'Quantidade de Bombas', // Texto de dica
                          hintStyle: TextStyle(
                            color: Colors.black, // Cor do hintText
                            fontSize: 20, // Tamanho da fonte do hintText
                            fontStyle:
                                FontStyle.normal, // Estilo da fonte (itálico)
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return TabuleiroWidget(
                      tabuleiro: _getTabuleiro(
                          constraints.maxWidth, constraints.maxHeight),
                      onAbrir: _abrir,
                      onAlternarMarcacao: _alternarMarcacao,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
