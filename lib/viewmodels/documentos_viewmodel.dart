import 'package:flutter/foundation.dart';

import '../models/documento.dart';

/// VIEWMODEL: lista de documentos do usuário.
/// Fase 1: lista em memória (como no DartPad).
class DocumentosViewModel extends ChangeNotifier {
  final List<Documento> _documentos = [];
  String _filtro = '';

  List<Documento> get documentos {
    final lista = _filtro.isEmpty
        ? List<Documento>.of(_documentos)
        : _documentos
            .where((d) => d.titulo.toLowerCase().contains(_filtro.toLowerCase()))
            .toList();
    lista.sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
    return lista;
  }

  void filtrar(String texto) {
    _filtro = texto;
    notifyListeners();
  }

  void adicionar(String titulo, String autorEmail) {
    _documentos.add(Documento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      conteudo: '',
      autorEmail: autorEmail,
      atualizadoEm: DateTime.now(),
    ));
    notifyListeners();
  }

  void remover(String id) {
    _documentos.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}
