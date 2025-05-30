import 'package:hive/hive.dart';

part 'vaccine.g.dart';

@HiveType(typeId: 2)
class Vaccine extends HiveObject {
  @HiveField(0)
  String pet;

  @HiveField(1)
  String vacina;

  @HiveField(2)
  DateTime data;

  Vaccine({
    required this.pet,
    required this.vacina,
    required this.data,
  });
}
