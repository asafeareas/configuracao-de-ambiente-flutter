import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';

/// MODEL / SERVICE (Repository): CRUD completo de documentos.
/// A lista de Documento é convertida para JSON (jsonEncode/jsonDecode)
/// e salva como String no shared_preferences.
class DocumentoStorageService {
  static const _chaveDocumentos = 'db_documentos';

  /// READ: todos os documentos (opcionalmente apenas de um autor).
  Future<List<Documento>> listar({String? autorEmail}) async {
    final todos = await _lerTodos();
    if (autorEmail == null) return todos;
    return todos.where((d) => d.autorEmail == autorEmail).toList();
  }

  /// CREATE
  Future<void> criar(Documento documento) async {
    final todos = await _lerTodos();
    todos.add(documento);
    await _salvarTodos(todos);
  }

  /// UPDATE
  Future<void> atualizar(Documento documento) async {
    final todos = await _lerTodos();
    final i = todos.indexWhere((d) => d.id == documento.id);
    if (i == -1) {
      throw StateError('Documento ${documento.id} não encontrado');
    }
    todos[i] = documento;
    await _salvarTodos(todos);
  }

  /// DELETE
  Future<void> excluir(String id) async {
    final todos = await _lerTodos();
    todos.removeWhere((d) => d.id == id);
    await _salvarTodos(todos);
  }

  Future<List<Documento>> _lerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveDocumentos);
    if (json == null || json.isEmpty) return [];
    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map((e) => Documento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _salvarTodos(List<Documento> documentos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveDocumentos,
      jsonEncode(documentos.map((d) => d.toMap()).toList()),
    );
  }
}
