# Relatório de Migração Arquitetural (DartPad → MVVM)

Projeto: **edit_doc_flutter** — Editor de Documentos em Flutter (alvo Web, executado no GitHub Codespaces).

Este documento descreve como o código das 3 telas feitas no DartPad (Login, Cadastro e Home/Lista), originalmente em um único `main.dart`, foi reorganizado na arquitetura **MVVM (Model–View–ViewModel)**.

```
lib/
├── main.dart                      # Ponto de entrada, ThemeData reativo e rotas nomeadas
├── models/
│   ├── usuario.dart               # Model do Usuário
│   ├── documento.dart             # Model do Documento
│   └── services/                  # (Fase 2) persistência
│       ├── preferences_service.dart
│       ├── banco_local_service.dart
│       └── documento_storage_service.dart
├── viewmodels/
│   ├── auth_viewmodel.dart        # Login, cadastro, sessão e tema
│   └── documentos_viewmodel.dart  # Lista e operações CRUD dos documentos
├── views/
│   ├── login_view.dart            # Rota: /
│   ├── cadastro_view.dart         # Rota: /cadastro
│   ├── home_view.dart             # Rota: /home
│   └── editor_view.dart           # Rota: /editor (Fase 2)
└── utils/
    └── validadores.dart           # Validação de Nome, E-mail e Senha
```

---

## 1. Mapeamento de Classes e Widgets

| Elemento no DartPad (arquivo único) | Tipo | Nova localização | Observação |
|---|---|---|---|
| `main()` + `MyApp` (MaterialApp) | Ponto de entrada | `lib/main.dart` → `main()` e `EditDocApp` | Cria os ViewModels uma única vez e os injeta nas telas. |
| Rotas do `MaterialApp` / `Navigator.push(MaterialPageRoute(...))` | Navegação | `lib/main.dart` (`routes:`) | Passou a usar rotas nomeadas `/`, `/cadastro`, `/home`. |
| Tema claro/escuro (`ThemeData`, booleano de tema) | Estado global | Variável `modoEscuro` no `AuthViewModel`; `ThemeData` em `main.dart` | `MaterialApp` envolvido em `ListenableBuilder` (tema reativo). |
| Classe `Usuario` | Model | `lib/models/usuario.dart` | Ganhou `toMap()` / `fromMap()` (preparação p/ Fase 2). |
| Classe `Documento` | Model | `lib/models/documento.dart` | Ganhou `id`, `autorEmail`, `atualizadoEm`, `copyWith`, `toMap/fromMap`. |
| Lista global de usuários cadastrados | Dados | `_usuarios` (privado) no `AuthViewModel` | Acesso apenas via `login()` e `cadastrar()`. |
| Lista de documentos da Home | Dados | `_documentos` (privado) no `DocumentosViewModel` | Exposta apenas pelo getter `documentos`. |
| Funções de validação (`validator:` inline: nome, e-mail, senha, confirmar senha) | Função auxiliar | `lib/utils/validadores.dart` → classe `Validadores` (métodos `static`) | Reutilizadas pelas telas de Login, Cadastro e diálogo de novo documento. |
| Lógica de "fazer login" (comparar e-mail/senha) | Regra de negócio | `AuthViewModel.login()` | Retorna `Future<bool>`; a View só navega se `true`. |
| Lógica de "cadastrar" (checar e-mail duplicado, adicionar à lista) | Regra de negócio | `AuthViewModel.cadastrar()` | |
| Logout | Regra de negócio | `AuthViewModel.logout()` | |
| Adicionar / remover / filtrar documento | Regra de negócio | `DocumentosViewModel.adicionar()`, `remover()`, `filtrar()` | |
| `LoginPage` / `_LoginPageState` | View | `lib/views/login_view.dart` → `LoginView` | |
| `CadastroPage` / `_CadastroPageState` | View | `lib/views/cadastro_view.dart` → `CadastroView` | |
| `HomePage` / `_HomePageState` | View | `lib/views/home_view.dart` → `HomeView` | Virou `StatelessWidget` (não guarda mais estado). |
| Diálogo "Novo documento" | View auxiliar | `_NovoDocumentoDialog` (privado) em `home_view.dart` | |
| Formatação de data da lista | Função auxiliar | `formatarData()` em `home_view.dart` | Apenas apresentação. |

---

## 2. Alterações de Estrutura e Imports

1. **Um arquivo por responsabilidade.** Cada classe saiu do `main.dart` único para o seu arquivo, com nomes em `snake_case` (`login_view.dart`, `auth_viewmodel.dart`...) e classes em `PascalCase`, seguindo o guia de estilo do Dart.

2. **Imports relativos entre camadas.** Cada arquivo importa apenas o que usa:
   - Views importam `package:flutter/material.dart`, `../viewmodels/...` e `../utils/validadores.dart`.
   - ViewModels importam `package:flutter/foundation.dart` (para `ChangeNotifier`) e `../models/...` — **nunca** `material.dart`, pois não conhecem widgets.
   - Models não importam nada do Flutter (Dart puro).
   - `main.dart` importa as views e os viewmodels para montar as rotas.

   A dependência segue a direção **View → ViewModel → Model**.

3. **Construtores com injeção de dependência.** Como as telas não enxergam mais variáveis globais do mesmo arquivo, cada View recebe o seu ViewModel pelo construtor (`LoginView({required this.viewModel})`, `HomeView({required this.authViewModel, required this.documentosViewModel})`). Os ViewModels são instanciados uma única vez em `main()` e repassados ao `EditDocApp`, garantindo que todas as telas compartilhem o mesmo estado.

4. **Construtores `const` e parâmetros nomeados `required`** nos Models (`Usuario`, `Documento`), com campos `final` (imutáveis).

5. **Visibilidade de atributos.** Em Dart, o prefixo `_` torna o membro privado **ao arquivo (biblioteca)**. No DartPad tudo estava no mesmo arquivo, então qualquer classe acessava qualquer variável. Após a separação:
   - O estado interno dos ViewModels virou privado (`_usuarios`, `_usuarioLogado`, `_carregando`, `_erro`, `_senhaVisivel`, `_modoEscuro`, `_documentos`, `_filtro`).
   - A leitura é feita por **getters públicos** (`usuarioLogado`, `carregando`, `erro`, `documentos`...), e a alteração só por **métodos** (`login()`, `alternarTema()`, `remover()`...). Assim a View não consegue modificar o estado diretamente.
   - Classes de `State` (`_LoginViewState`) e o diálogo `_NovoDocumentoDialog` continuam privados, pois só são usados dentro do próprio arquivo.

6. **Validadores como métodos estáticos.** As funções de validação passaram para `Validadores` com construtor privado (`Validadores._()`), evitando instanciação. Os métodos têm a assinatura `String? Function(String?)`, então são passados diretamente: `validator: Validadores.email`.

7. **Rotas nomeadas.** A navegação com `Navigator.push(context, MaterialPageRoute(builder: ...))` foi substituída por:
   ```dart
   initialRoute: '/',
   routes: {
     '/':         (_) => LoginView(viewModel: authViewModel),
     '/cadastro': (_) => CadastroView(viewModel: authViewModel),
     '/home':     (_) => HomeView(authViewModel: ..., documentosViewModel: ...),
   },
   ```
   e as telas usam `Navigator.pushNamed(context, '/cadastro')`, `Navigator.pushReplacementNamed(context, '/home')` (login → home sem voltar ao login) e `Navigator.pop(context)` (cadastro → login).

8. **`mounted` após `await`.** Como `login()` e `cadastrar()` agora são assíncronos no ViewModel, as Views verificam `if (ok && mounted)` antes de usar o `context` para navegar.

---

## 3. Mudanças no Gerenciamento de Estado

### `setState()` removidos das Views

| Tela | Uso de `setState()` no DartPad | Para onde foi |
|---|---|---|
| Login | `setState(() => _senhaVisivel = !_senhaVisivel)` (mostrar/ocultar senha) | `AuthViewModel.alternarVisibilidadeSenha()` |
| Login | `setState(() => _carregando = true/false)` ao entrar | `AuthViewModel._carregando` (controlado dentro de `login()`) |
| Login | `setState(() => _mensagemErro = '...')` quando e-mail/senha inválidos | `AuthViewModel._erro` |
| Login / Home | `setState(() => _modoEscuro = !_modoEscuro)` (botão de tema) | `AuthViewModel.alternarTema()` |
| Cadastro | `setState` para visibilidade da senha, carregamento e erro de e-mail duplicado | `AuthViewModel` (`alternarVisibilidadeSenha()`, `cadastrar()`) |
| Home | `setState(() => documentos.add(...))` | `DocumentosViewModel.adicionar()` |
| Home | `setState(() => documentos.removeAt(i))` | `DocumentosViewModel.remover(id)` |
| Home | `setState(() => _busca = texto)` (filtro) | `DocumentosViewModel.filtrar()` |

**Resultado:** nenhuma View chama `setState()`. `LoginView` e `CadastroView` continuam `StatefulWidget` **apenas** para criar e descartar (`dispose`) os `TextEditingController` e a `GlobalKey<FormState>` — objetos ligados ao ciclo de vida do widget, que pertencem à camada de interface. `HomeView` virou `StatelessWidget`.

### Variáveis de estado nos ViewModels (`ChangeNotifier`)

- **`AuthViewModel`**: `_usuarios`, `_usuarioLogado`, `_carregando`, `_erro`, `_senhaVisivel`, `_modoEscuro`.
- **`DocumentosViewModel`**: `_documentos`, `_filtro` (o getter `documentos` já devolve a lista filtrada e ordenada pela data de atualização).

Toda alteração termina com **`notifyListeners()`**, que avisa quem estiver escutando que o estado mudou. Exemplo:

```dart
void alternarTema() {
  _modoEscuro = !_modoEscuro;
  notifyListeners();
}
```

### Como as Views escutam e reagem

As telas envolvem apenas a parte que depende do estado com **`ListenableBuilder`**:

```dart
ListenableBuilder(
  listenable: vm,               // o ViewModel (ChangeNotifier)
  builder: (context, _) => FilledButton(
    onPressed: vm.carregando ? null : _entrar,
    child: vm.carregando ? CircularProgressIndicator() : Text('Entrar'),
  ),
)
```

Fluxo: **evento na View** (clique) → **método do ViewModel** (altera estado privado) → **`notifyListeners()`** → **`ListenableBuilder` reconstrói** somente aquele trecho da árvore.

Pontos onde isso é usado:
- `main.dart`: `ListenableBuilder(listenable: authViewModel)` em volta do `MaterialApp` → troca de `themeMode` em tempo real.
- `login_view.dart` / `cadastro_view.dart`: formulário reage a `senhaVisivel`, `carregando` e `erro`.
- `home_view.dart`: a lista reage a `DocumentosViewModel` (adicionar, remover, filtrar); o ícone de tema reage ao `AuthViewModel`.

---

## Fase 2 — CRUD e Persistência Local

Como o app roda no alvo **Web** (`web-server`), não usamos `sqflite`. A persistência segue o padrão **Repository/Service** com `shared_preferences` (no navegador, os dados ficam no `localStorage`).

| Arquivo | Responsabilidade |
|---|---|
| `models/services/preferences_service.dart` | Chave-valor simples: `bool` do tema (`pref_modo_escuro`) e `String` com o e-mail da sessão (`pref_sessao_email`). |
| `models/services/banco_local_service.dart` | "Banco local" de **usuários**: lista de `Usuario` serializada em JSON (`db_usuarios`), com inserir/buscar/atualizar/remover. |
| `models/services/documento_storage_service.dart` | **CRUD de documentos**: `listar` (Read), `criar` (Create), `atualizar` (Update), `excluir` (Delete). A lista de `Documento` é convertida com `jsonEncode`/`jsonDecode` (`dart:convert`) e salva como String (`db_documentos`). |
| `views/editor_view.dart` | 4ª tela (rota `/editor`): cria um documento novo (sem argumento) ou edita um existente (`Navigator.pushNamed(context, '/editor', arguments: documento)`). |

O que mudou nas outras camadas:

- **`AuthViewModel`** recebe `BancoLocalService` e `PreferencesService` pelo construtor. Ganhou `carregarPreferencias()` (chamado no `main()` antes do `runApp`), que restaura **tema** e **sessão**. `alternarTema()`, `login()` e `logout()` agora gravam nas preferências.
- **`DocumentosViewModel`** recebe `DocumentoStorageService`. Métodos: `carregar(email)`, `criar()`, `atualizar()`, `excluir()`, `filtrar()`, `limpar()`. Expõe `carregando`, `salvando` e `erro` para a View. Cada usuário só vê os próprios documentos (`autorEmail`).
- **`main.dart`** passou a usar `onGenerateRoute` (para passar o `Documento` como argumento ao `/editor` e redirecionar para o login se não houver sessão). A rota inicial é `/home` se já existir sessão salva.
- As Views continuam sem `setState()`; a tela do editor escuta `salvando` via `ListenableBuilder`.

**Validação:** criar/editar/excluir documentos e trocar o tema, depois recarregar o preview (F5) — os documentos, o tema e a sessão permanecem. Testes automatizados em `test/documentos_viewmodel_test.dart` simulam esse "recarregar" criando novas instâncias dos ViewModels.

> Observação: por ser um projeto didático, a senha é salva em texto puro no `localStorage`. Em produção deve-se usar um backend de autenticação ou, no mínimo, hash da senha.

---

## Como executar

1. Abra o repositório em um **Codespace** (`.devcontainer/devcontainer.json` usa a imagem `ghcr.io/cirruslabs/flutter:stable`).
2. Rode `flutter pub get`.
3. Pressione **F5** (configuração *Rodar App Flutter (Web Preview)* em `.vscode/launch.json`). O preview abre na porta **8080**.
