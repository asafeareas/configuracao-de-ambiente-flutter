import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../utils/validadores.dart';
import '../viewmodels/documentos_viewmodel.dart';

/// VIEW (rota "/editor"): criação (documento == null) ou edição de documento.
/// Todas as operações passam pelo DocumentosViewModel.
class EditorView extends StatefulWidget {
  final DocumentosViewModel viewModel;
  final Documento? documento;

  const EditorView({super.key, required this.viewModel, this.documento});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _conteudoController;

  bool get _editando => widget.documento != null;

  @override
  void initState() {
    super.initState();
    _tituloController =
        TextEditingController(text: widget.documento?.titulo ?? '');
    _conteudoController =
        TextEditingController(text: widget.documento?.conteudo ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = widget.viewModel;
    final ok = _editando
        ? await vm.atualizar(
            widget.documento!,
            titulo: _tituloController.text,
            conteudo: _conteudoController.text,
          )
        : await vm.criar(
            titulo: _tituloController.text,
            conteudo: _conteudoController.text,
          );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? (_editando ? 'Documento atualizado' : 'Documento criado')
          : vm.erro ?? 'Erro ao salvar'),
    ));
    if (ok) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final confirmar = await confirmarExclusao(context, widget.documento!);
    if (!confirmar) return;
    await widget.viewModel.excluir(widget.documento!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar documento' : 'Novo documento'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _excluir,
            ),
          ListenableBuilder(
            listenable: vm,
            builder: (context, _) => IconButton(
              tooltip: 'Salvar',
              icon: vm.salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              onPressed: vm.salvando ? null : _salvar,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                autofocus: !_editando,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validadores.obrigatorio(v, campo: 'título'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _conteudoController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo de confirmação reutilizado pela Home e pelo Editor.
Future<bool> confirmarExclusao(BuildContext context, Documento doc) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir documento'),
      content: Text('Deseja excluir "${doc.titulo}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
