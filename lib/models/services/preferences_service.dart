import 'package:shared_preferences/shared_preferences.dart';

/// MODEL / SERVICE: preferências simples de chave-valor (bool e String).
/// Guarda o tema escolhido e o e-mail do usuário com sessão ativa.
class PreferencesService {
  static const _chaveModoEscuro = 'pref_modo_escuro';
  static const _chaveSessaoEmail = 'pref_sessao_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> lerModoEscuro() async =>
      (await _prefs).getBool(_chaveModoEscuro) ?? false;

  Future<void> salvarModoEscuro(bool valor) async =>
      (await _prefs).setBool(_chaveModoEscuro, valor);

  Future<String?> lerSessaoEmail() async =>
      (await _prefs).getString(_chaveSessaoEmail);

  Future<void> salvarSessaoEmail(String email) async =>
      (await _prefs).setString(_chaveSessaoEmail, email);

  Future<void> limparSessao() async =>
      (await _prefs).remove(_chaveSessaoEmail);
}
