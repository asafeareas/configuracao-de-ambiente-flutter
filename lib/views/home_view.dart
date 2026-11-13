import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'editor_view.dart';

/// VIEW (rota "/home"): lista de documentos do usuário logado.
class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const HomeView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // StatefulWidget apenas para disparar o carregamento inicial (initState).
  // Nenhum setState() é usado: a lista vem do DocumentosViewModel.
  @override
  void initState() {
    super.initState();
    final email = widget.authViewModel.usuarioLogado?.email;
    if (email != null) widget.documentosViewModel.carregar(email);
  }

  void _abrirEditor([Documento? doc]) {
    Navigator.pushNamed(context, '/editor', arguments: doc);
  }

  Future<void> _excluir(Documento doc) async {
    if (await confirmarExclusao(context, doc)) {
      await widget.documentosViewModel.excluir(doc.id);
    }
  }

  Future<void> _sair() async {
    widget.documentosViewModel.limpar();
    await widget.authViewModel.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authViewModel;
    final docsVm = widget.documentosViewModel;
    final nome = auth.usuarioLogado?.nome ?? 'Visitante';
    return Scaffold(
      appBar: AppBar(
        // Home é a raiz após o login: sem botão "voltar" para a tela de login.
        automaticallyImplyLeading: false,
        title: Text('Olá, $nome'),
        actions: [
          ListenableBuilder(
            listenable: auth,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(auth.modoEscuro ? Icons.light_mode : Icons.dark_mode),
              onPressed: auth.alternarTema,
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Novo documento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar documentos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: docsVm.filtrar,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: docsVm,
              builder: (context, _) {
                if (docsVm.carregando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (docsVm.erro != null) {
                  return Center(child: Text(docsVm.erro!));
                }
                final docs = docsVm.documentos;
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum documento ainda.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(doc.titulo),
                      subtitle: Text(
                        doc.conteudo.isEmpty
                            ? formatarData(doc.atualizadoEm)
                            : '${formatarData(doc.atualizadoEm)} · '
                                '${doc.conteudo.replaceAll('\n', ' ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _abrirEditor(doc),
                      trailing: IconButton(
                        tooltip: 'Excluir',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _excluir(doc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String formatarData(DateTime d) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(d.day)}/${dois(d.month)}/${d.year} '
      '${dois(d.hour)}:${dois(d.minute)}';
}
