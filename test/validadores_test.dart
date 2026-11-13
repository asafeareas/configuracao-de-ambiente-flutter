import 'package:edit_doc_flutter/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Validadores de nome, e-mail e senha', () {
    expect(Validadores.nome(''), isNotNull);
    expect(Validadores.nome('Ana'), isNull);
    expect(Validadores.email('x@'), isNotNull);
    expect(Validadores.email('ana@exemplo.com'), isNull);
    expect(Validadores.senha('123'), isNotNull);
    expect(Validadores.senha('123456'), isNull);
    expect(Validadores.confirmarSenha('123456', '654321'), isNotNull);
    expect(Validadores.confirmarSenha('123456', '123456'), isNull);
  });
}
