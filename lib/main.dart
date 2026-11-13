import 'package:flutter/material.dart';

import 'models/documento.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authViewModel = AuthViewModel();
  // Restaura tema e sessão salvos antes de desenhar a primeira tela.
  await authViewModel.carregarPreferencias();

  runApp(EditDocApp(
    authViewModel: authViewModel,
    documentosViewModel: DocumentosViewModel(),
  ));
}

class EditDocApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const EditDocApp({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  Widget build(BuildContext context) {
    // ThemeData reativo: o MaterialApp é reconstruído quando o AuthViewModel
    // chama notifyListeners() após alternar o tema.
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) => MaterialApp(
        title: 'Editor de Docs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        themeMode: authViewModel.modoEscuro ? ThemeMode.dark : ThemeMode.light,
        initialRoute: authViewModel.estaLogado ? '/home' : '/',
        onGenerateRoute: _gerarRota,
      ),
    );
  }

  /// Rotas nomeadas. Usa onGenerateRoute para poder passar argumentos
  /// ao /editor e proteger as rotas que exigem login.
  Route<dynamic> _gerarRota(RouteSettings settings) {
    Widget tela;
    final logado = authViewModel.estaLogado;
    switch (settings.name) {
      case '/cadastro':
        tela = CadastroView(viewModel: authViewModel);
      case '/home':
        tela = logado
            ? HomeView(
                authViewModel: authViewModel,
                documentosViewModel: documentosViewModel,
              )
            : LoginView(viewModel: authViewModel);
      case '/editor':
        tela = logado
            ? EditorView(
                viewModel: documentosViewModel,
                documento: settings.arguments as Documento?,
              )
            : LoginView(viewModel: authViewModel);
      case '/':
      default:
        tela = LoginView(viewModel: authViewModel);
    }
    return MaterialPageRoute(builder: (_) => tela, settings: settings);
  }
}
