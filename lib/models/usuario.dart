/// MODEL: entidade que representa um usuário cadastrado.
class Usuario {
  final String nome;
  final String email;
  final String senha;

  const Usuario({
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'email': email,
        'senha': senha,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        nome: map['nome'] as String,
        email: map['email'] as String,
        senha: map['senha'] as String,
      );
}
