import 'package:flutter/material.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

void main() {
  runApp(EditDocApp(
    authViewModel: AuthViewModel(),
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
        initialRoute: '/',
        routes: {
          '/': (_) => LoginView(viewModel: authViewModel),
          '/cadastro': (_) => CadastroView(viewModel: authViewModel),
          '/home': (_) => HomeView(
                authViewModel: authViewModel,
                documentosViewModel: documentosViewModel,
              ),
        },
      ),
    );
  }
}
