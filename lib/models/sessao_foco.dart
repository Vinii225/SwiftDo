class SessaoFoco {
  final int? id;
  final int? tarefaId;
  final int duracaoMin;
  final String data;

  SessaoFoco({
    this.id,
    this.tarefaId,
    required this.duracaoMin,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'tarefa_id': tarefaId,
    'duracao_min': duracaoMin,
    'data': data,
  };

  factory SessaoFoco.fromMap(Map<String, dynamic> map) => SessaoFoco(
    id: map['id'],
    tarefaId: map['tarefa_id'],
    duracaoMin: map['duracao_min'],
    data: map['data'],
  );
}