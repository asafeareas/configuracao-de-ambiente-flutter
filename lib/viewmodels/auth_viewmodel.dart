import 'package:flutter/foundation.dart';

import '../models/usuario.dart';

/// VIEWMODEL: autenticação e cadastro.
/// Fase 1: usuários mantidos em memória (como no DartPad).
class AuthViewModel extends ChangeNotifier {
  final List<Usuario> _usuarios = [];

  Usuario? _usuarioLogado;
  bool _carregando = false;
  String? _erro;
  bool _senhaVisivel = false;
  bool _modoEscuro = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get senhaVisivel => _senhaVisivel;
  bool get modoEscuro => _modoEscuro;

  void alternarVisibilidadeSenha() {
    _senhaVisivel = !_senhaVisivel;
    notifyListeners();
  }

  void alternarTema() {
    _modoEscuro = !_modoEscuro;
    notifyListeners();
  }

  void limparErro() {
    if (_erro == null) return;
    _erro = null;
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    _iniciar();
    await Future.delayed(const Duration(milliseconds: 300));
    final emailNorm = email.trim().toLowerCase();
    final usuario = _usuarios.where((u) => u.email == emailNorm).firstOrNull;
    if (usuario == null || usuario.senha != senha) {
      return _finalizar(erro: 'E-mail ou senha inválidos');
    }
    _usuarioLogado = usuario;
    return _finalizar();
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _iniciar();
    await Future.delayed(const Duration(milliseconds: 300));
    final emailNorm = email.trim().toLowerCase();
    if (_usuarios.any((u) => u.email == emailNorm)) {
      return _finalizar(erro: 'Já existe um usuário com este e-mail');
    }
    _usuarios.add(Usuario(nome: nome.trim(), email: emailNorm, senha: senha));
    return _finalizar();
  }

  void logout() {
    _usuarioLogado = null;
    _senhaVisivel = false;
    notifyListeners();
  }

  void _iniciar() {
    _carregando = true;
    _erro = null;
    notifyListeners();
  }

  bool _finalizar({String? erro}) {
    _carregando = false;
    _erro = erro;
    notifyListeners();
    return erro == null;
  }
}
