/// MODEL: entidade que representa um documento de texto.
class Documento {
  final String id;
  final String titulo;
  final String conteudo;
  final String autorEmail;
  final DateTime atualizadoEm;

  const Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.autorEmail,
    required this.atualizadoEm,
  });

  Documento copyWith({String? titulo, String? conteudo, DateTime? atualizadoEm}) {
    return Documento(
      id: id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      autorEmail: autorEmail,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'autorEmail': autorEmail,
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  factory Documento.fromMap(Map<String, dynamic> map) => Documento(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        conteudo: map['conteudo'] as String? ?? '',
        autorEmail: map['autorEmail'] as String,
        atualizadoEm: DateTime.parse(map['atualizadoEm'] as String),
      );
}
