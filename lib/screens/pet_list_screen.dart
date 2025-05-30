import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pet.dart';
import 'pet_form_screen.dart';
import 'pet_details_screen.dart';
import '../data/racas.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

  String? _getTipoFromRaca(String raca) {
    for (final tipo in racasPorTipo.keys) {
      if (racasPorTipo[tipo]!.contains(raca)) {
        return tipo;
      }
    }
    return 'Outro';
  }

  @override
  Widget build(BuildContext context) {
    final Box<Pet> petBox = Hive.box<Pet>('pets');

    return Scaffold(
      appBar: AppBar(title: const Text('Pets Cadastrados')),
      body: ValueListenableBuilder(
        valueListenable: petBox.listenable(),
        builder: (context, Box<Pet> box, _) {
          final Map<String, List<MapEntry<int, Pet>>> petsPorTipo = {};

          for (int i = 0; i < box.length; i++) {
            final pet = box.getAt(i);
            final key = box.keyAt(i);

            if (pet == null || key == null || key is! int) continue;

            final tipo = _getTipoFromRaca(pet.raca) ?? 'Outro';

            petsPorTipo.putIfAbsent(tipo, () => []);
            petsPorTipo[tipo]!.add(MapEntry(key, pet));
          }

          if (petsPorTipo.isEmpty) {
            return const Center(child: Text('Nenhum pet cadastrado.'));
          }

          return ListView(
            children: petsPorTipo.entries.expand((entry) {
              final tipo = entry.key;
              final pets = entry.value;

              return [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    tipo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...pets.map((e) {
                  final pet = e.value;
                  final key = e.key;

                  return ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text(pet.nome),
                    subtitle: Text('Raça: ${pet.raca} — Idade: ${_formatIdade(pet.idade)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetDetailsScreen(pet: pet),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetFormScreen(
                                  pet: pet,
                                  petKey: key,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: Text('Deseja excluir ${pet.nome}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      pet.delete();
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${pet.nome} foi removido.')),
                                      );
                                    },
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatIdade(int totalMeses) {
    final anos = totalMeses ~/ 12;
    final meses = totalMeses % 12;
    if (anos > 0 && meses > 0) {
      return '$anos anos e $meses meses';
    } else if (anos > 0) {
      return '$anos anos';
    } else {
      return '$meses meses';
    }
  }
}
