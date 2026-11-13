/// Funções auxiliares de validação usadas pelos formulários.
/// Retornam `null` quando o valor é válido ou a mensagem de erro.
class Validadores {
  Validadores._();

  static final RegExp _emailRegex = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');

  static String? nome(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe o nome';
    if (v.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
    return null;
  }

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe o e-mail';
    if (!_emailRegex.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Informe a senha';
    if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  static String? confirmarSenha(String? valor, String senhaOriginal) {
    final erro = senha(valor);
    if (erro != null) return erro;
    if (valor != senhaOriginal) return 'As senhas não conferem';
    return null;
  }

  static String? obrigatorio(String? valor, {String campo = 'campo'}) {
    if ((valor?.trim() ?? '').isEmpty) return 'Informe o $campo';
    return null;
  }
}
