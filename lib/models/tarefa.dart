class Tarefa {
  final int? id;
  final String titulo;
  final int categoriaId;
  final String data;
  final int concluida;
  final int tempoEstudoMin;

  Tarefa({
    this.id,
    required this.titulo,
    required this.categoriaId,
    required this.data,
    this.concluida = 0,
    this.tempoEstudoMin = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'categoria_id': categoriaId,
    'data': data,
    'concluida': concluida,
    'tempo_estudo_min': tempoEstudoMin,
  };

  factory Tarefa.fromMap(Map<String, dynamic> map) => Tarefa(
    id: map['id'],
    titulo: map['titulo'],
    categoriaId: map['categoria_id'],
    data: map['data'],
    concluida: map['concluida'],
    tempoEstudoMin: map['tempo_estudo_min'],
  );
}