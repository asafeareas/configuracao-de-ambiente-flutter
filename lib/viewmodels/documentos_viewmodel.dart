import 'package:flutter/foundation.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

/// VIEWMODEL: listagem e operações CRUD dos documentos do usuário logado.
class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage;

  DocumentosViewModel({DocumentoStorageService? storage})
      : _storage = storage ?? DocumentoStorageService();

  List<Documento> _documentos = [];
  String _filtro = '';
  String? _autorEmail;
  bool _carregando = false;
  bool _salvando = false;
  String? _erro;

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;

  /// Lista filtrada pelo título e ordenada do mais recente para o mais antigo.
  List<Documento> get documentos {
    final termo = _filtro.toLowerCase();
    final lista = termo.isEmpty
        ? List<Documento>.of(_documentos)
        : _documentos
            .where((d) =>
                d.titulo.toLowerCase().contains(termo) ||
                d.conteudo.toLowerCase().contains(termo))
            .toList();
    lista.sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
    return lista;
  }

  /// READ
  Future<void> carregar(String autorEmail) async {
    _autorEmail = autorEmail;
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _documentos = await _storage.listar(autorEmail: autorEmail);
    } catch (e) {
      _erro = 'Erro ao carregar documentos';
    }
    _carregando = false;
    notifyListeners();
  }

  void filtrar(String texto) {
    _filtro = texto;
    notifyListeners();
  }

  /// CREATE
  Future<bool> criar({required String titulo, required String conteudo}) {
    return _salvar(() async {
      final autor = _autorEmail;
      if (autor == null) throw StateError('Nenhum usuário logado');
      final doc = Documento(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo.trim(),
        conteudo: conteudo,
        autorEmail: autor,
        atualizadoEm: DateTime.now(),
      );
      await _storage.criar(doc);
      _documentos.add(doc);
    });
  }

  /// UPDATE
  Future<bool> atualizar(
    Documento original, {
    required String titulo,
    required String conteudo,
  }) {
    return _salvar(() async {
      final atualizado = original.copyWith(
        titulo: titulo.trim(),
        conteudo: conteudo,
        atualizadoEm: DateTime.now(),
      );
      await _storage.atualizar(atualizado);
      final i = _documentos.indexWhere((d) => d.id == original.id);
      if (i != -1) _documentos[i] = atualizado;
    });
  }

  Future<bool> _salvar(Future<void> Function() operacao) async {
    _salvando = true;
    _erro = null;
    notifyListeners();
    try {
      await operacao();
      return true;
    } catch (e) {
      _erro = 'Erro ao salvar documento';
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// DELETE
  Future<void> excluir(String id) async {
    await _storage.excluir(id);
    _documentos.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Limpa o estado em memória ao sair (os dados continuam salvos).
  void limpar() {
    _documentos = [];
    _filtro = '';
    _autorEmail = null;
    notifyListeners();
  }
}
