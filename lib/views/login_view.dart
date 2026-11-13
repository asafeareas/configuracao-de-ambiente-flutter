import 'package:flutter/material.dart';

import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

/// VIEW (rota "/"): apenas interface; estado e regras ficam no AuthViewModel.
class LoginView extends StatefulWidget {
  final AuthViewModel viewModel;

  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controllers e a chave do Form são objetos de UI (ciclo de vida do widget),
  // por isso continuam na View. Nenhum setState() é usado.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.viewModel.login(
      _emailController.text,
      _senhaController.text,
    );
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Docs'),
        actions: [
          ListenableBuilder(
            listenable: vm,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(vm.modoEscuro ? Icons.light_mode : Icons.dark_mode),
              onPressed: vm.alternarTema,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: ListenableBuilder(
                listenable: vm,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.description_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'Entrar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.email,
                      onChanged: (_) => vm.limparErro(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !vm.senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(vm.senhaVisivel
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: vm.alternarVisibilidadeSenha,
                        ),
                      ),
                      validator: Validadores.senha,
                      onChanged: (_) => vm.limparErro(),
                      onFieldSubmitted: (_) => _entrar(),
                    ),
                    if (vm.erro != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.erro!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: vm.carregando ? null : _entrar,
                      child: vm.carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.limparErro();
                        Navigator.pushNamed(context, '/cadastro');
                      },
                      child: const Text('Não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
