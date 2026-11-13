import 'package:flutter/material.dart';

import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

/// VIEW (rota "/home"): lista de documentos do usuário logado.
class HomeView extends StatelessWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const HomeView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  Future<void> _novoDocumento(BuildContext context) async {
    final titulo = await showDialog<String>(
      context: context,
      builder: (_) => const _NovoDocumentoDialog(),
    );
    if (titulo != null) {
      documentosViewModel.adicionar(
        titulo,
        authViewModel.usuarioLogado?.email ?? '',
      );
    }
  }

  void _sair(BuildContext context) {
    authViewModel.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final nome = authViewModel.usuarioLogado?.nome ?? 'Visitante';
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $nome'),
        actions: [
          ListenableBuilder(
            listenable: authViewModel,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(authViewModel.modoEscuro
                  ? Icons.light_mode
                  : Icons.dark_mode),
              onPressed: authViewModel.alternarTema,
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _sair(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novoDocumento(context),
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
              onChanged: documentosViewModel.filtrar,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: documentosViewModel,
              builder: (context, _) {
                final docs = documentosViewModel.documentos;
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
                      subtitle: Text(formatarData(doc.atualizadoEm)),
                      trailing: IconButton(
                        tooltip: 'Excluir',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => documentosViewModel.remover(doc.id),
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

class _NovoDocumentoDialog extends StatefulWidget {
  const _NovoDocumentoDialog();

  @override
  State<_NovoDocumentoDialog> createState() => _NovoDocumentoDialogState();
}

class _NovoDocumentoDialogState extends State<_NovoDocumentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo documento'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
          validator: (v) => Validadores.obrigatorio(v, campo: 'título'),
          onFieldSubmitted: (_) => _salvar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Criar')),
      ],
    );
  }
}
