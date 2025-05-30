import 'package:hive/hive.dart';

part 'consulta.g.dart';

@HiveType(typeId: 0)
class Consulta extends HiveObject {
  @HiveField(0)
  String pet;

  @HiveField(1)
  String data;

  @HiveField(2)
  String veterinario;

  @HiveField(3)
  String observacoes;

  @HiveField(4)
  String assunto; // Novo campo adicionado

  Consulta({
    required this.pet,
    required this.data,
    required this.veterinario,
    required this.observacoes,
    required this.assunto,
  });
}
