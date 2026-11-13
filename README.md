# edit_doc_flutter — Editor de Documentos (Flutter + MVVM)

Aplicativo Flutter (alvo Web) com Login, Cadastro, lista de documentos e tema claro/escuro, organizado em **MVVM** (Model–View–ViewModel).

- Relatório de migração arquitetural: **[ARQUITETURA.md](ARQUITETURA.md)**
- Fase 1 (migração MVVM, sem persistência): tag [`fase-1`](../../tree/fase-1)
- Fase 2 (CRUD + persistência com `shared_preferences`): branch `main`

## Ambiente

- `.devcontainer/devcontainer.json` — container com o Flutter SDK (`ghcr.io/cirruslabs/flutter:stable`), porta 8080 com preview automático.
- `.vscode/launch.json` — **F5** roda `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0`.

## Executar

```bash
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

## Estrutura

```
lib/
├── main.dart
├── models/        # Entidades e acesso a dados
├── viewmodels/    # Estado e regras de negócio (ChangeNotifier)
├── views/         # Telas (apenas interface)
└── utils/         # Validadores
```

> Ao encerrar: `git add . && git commit && git push` e pare o Codespace em github.com/codespaces.
