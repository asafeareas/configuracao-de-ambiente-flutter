import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CRUD de documentos persiste entre instâncias', () async {
    final vm = DocumentosViewModel();
    await vm.carregar('ana@teste.com');
    expect(await vm.criar(titulo: 'Doc 1', conteudo: 'abc'), isTrue);
    expect(vm.documentos.single.titulo, 'Doc 1');

    // "Recarregar a página": nova instância lendo do shared_preferences.
    final vm2 = DocumentosViewModel();
    await vm2.carregar('ana@teste.com');
    final doc = vm2.documentos.single;
    expect(doc.conteudo, 'abc');

    await vm2.atualizar(doc, titulo: 'Doc editado', conteudo: 'xyz');
    final salvos = await DocumentoStorageService().listar();
    expect(salvos.single.titulo, 'Doc editado');

    await vm2.excluir(doc.id);
    expect(await DocumentoStorageService().listar(), isEmpty);
  });

  test('documentos de outro usuário não aparecem', () async {
    final vm = DocumentosViewModel();
    await vm.carregar('ana@teste.com');
    await vm.criar(titulo: 'Da Ana', conteudo: '');
    await vm.carregar('bia@teste.com');
    expect(vm.documentos, isEmpty);
  });

  test('cadastro, login, sessão e tema persistem', () async {
    final auth = AuthViewModel();
    expect(await auth.cadastrar('Ana', 'Ana@Teste.com', '123456'), isTrue);
    expect(await auth.cadastrar('Ana', 'ana@teste.com', '123456'), isFalse);
    expect(await auth.login('ana@teste.com', 'errada'), isFalse);
    expect(await auth.login('ana@teste.com', '123456'), isTrue);
    await auth.alternarTema();

    final auth2 = AuthViewModel();
    await auth2.carregarPreferencias();
    expect(auth2.estaLogado, isTrue);
    expect(auth2.modoEscuro, isTrue);

    await auth2.logout();
    final auth3 = AuthViewModel();
    await auth3.carregarPreferencias();
    expect(auth3.estaLogado, isFalse);
  });
}
