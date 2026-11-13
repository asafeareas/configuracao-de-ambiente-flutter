import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';

/// MODEL / SERVICE: "banco local" de usuários.
/// A lista de usuários é serializada em JSON e salva no shared_preferences
/// (no alvo Web, isso vira o localStorage do navegador).
/// Os documentos ficam no DocumentoStorageService.
class BancoLocalService {
  static const _chaveUsuarios = 'db_usuarios';

  Future<List<Usuario>> listarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveUsuarios);
    if (json == null || json.isEmpty) return [];
    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map((e) => Usuario.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final usuarios = await listarUsuarios();
    return usuarios.where((u) => u.email == email).firstOrNull;
  }

  Future<void> inserirUsuario(Usuario usuario) async {
    final usuarios = await listarUsuarios();
    usuarios.add(usuario);
    await _salvar(usuarios);
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    final usuarios = await listarUsuarios();
    final i = usuarios.indexWhere((u) => u.email == usuario.email);
    if (i == -1) return;
    usuarios[i] = usuario;
    await _salvar(usuarios);
  }

  Future<void> removerUsuario(String email) async {
    final usuarios = await listarUsuarios();
    usuarios.removeWhere((u) => u.email == email);
    await _salvar(usuarios);
  }

  Future<void> _salvar(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveUsuarios,
      jsonEncode(usuarios.map((u) => u.toMap()).toList()),
    );
  }
}
