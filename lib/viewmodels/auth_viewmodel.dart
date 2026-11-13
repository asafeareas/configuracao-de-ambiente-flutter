import 'package:flutter/foundation.dart';

import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';

/// VIEWMODEL: autenticação, cadastro e carregamento de preferências
/// (tema e sessão). Persiste via BancoLocalService e PreferencesService.
class AuthViewModel extends ChangeNotifier {
  final BancoLocalService _banco;
  final PreferencesService _preferencias;

  AuthViewModel({BancoLocalService? banco, PreferencesService? preferencias})
      : _banco = banco ?? BancoLocalService(),
        _preferencias = preferencias ?? PreferencesService();

  Usuario? _usuarioLogado;
  bool _carregando = false;
  String? _erro;
  bool _senhaVisivel = false;
  bool _modoEscuro = false;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get estaLogado => _usuarioLogado != null;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get senhaVisivel => _senhaVisivel;
  bool get modoEscuro => _modoEscuro;

  /// Chamado no main() antes do runApp: restaura tema e sessão salvos.
  Future<void> carregarPreferencias() async {
    _modoEscuro = await _preferencias.lerModoEscuro();
    final email = await _preferencias.lerSessaoEmail();
    if (email != null) {
      _usuarioLogado = await _banco.buscarUsuarioPorEmail(email);
      if (_usuarioLogado == null) await _preferencias.limparSessao();
    }
    notifyListeners();
  }

  void alternarVisibilidadeSenha() {
    _senhaVisivel = !_senhaVisivel;
    notifyListeners();
  }

  Future<void> alternarTema() async {
    _modoEscuro = !_modoEscuro;
    notifyListeners();
    await _preferencias.salvarModoEscuro(_modoEscuro);
  }

  void limparErro() {
    if (_erro == null) return;
    _erro = null;
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    _iniciar();
    final emailNorm = email.trim().toLowerCase();
    final usuario = await _banco.buscarUsuarioPorEmail(emailNorm);
    if (usuario == null || usuario.senha != senha) {
      return _finalizar(erro: 'E-mail ou senha inválidos');
    }
    _usuarioLogado = usuario;
    await _preferencias.salvarSessaoEmail(usuario.email);
    return _finalizar();
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _iniciar();
    final emailNorm = email.trim().toLowerCase();
    if (await _banco.buscarUsuarioPorEmail(emailNorm) != null) {
      return _finalizar(erro: 'Já existe um usuário com este e-mail');
    }
    await _banco.inserirUsuario(
      Usuario(nome: nome.trim(), email: emailNorm, senha: senha),
    );
    return _finalizar();
  }

  Future<void> logout() async {
    _usuarioLogado = null;
    _senhaVisivel = false;
    notifyListeners();
    await _preferencias.limparSessao();
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
