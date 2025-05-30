import 'package:hive/hive.dart';

part 'pet.g.dart';

@HiveType(typeId: 1)
class Pet extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String raca;

  @HiveField(2)
  int idade;

  Pet({
    required this.nome,
    required this.raca,
    required this.idade,
  });
}
