class Categoria {
  final int? id;
  final String nome;
  final String cor;

  Categoria({this.id, required this.nome, required this.cor});

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'cor': cor,
  };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    id: map['id'],
    nome: map['nome'],
    cor: map['cor'],
  );
}