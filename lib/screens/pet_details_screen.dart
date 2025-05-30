import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../models/consulta.dart';
import '../models/vaccine.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailsScreen({super.key, required this.pet});

  String _formatIdade(int totalMeses) {
    final anos = totalMeses ~/ 12;
    final meses = totalMeses % 12;
    if (anos > 0 && meses > 0) {
      return '$anos ano(s) e $meses mes(es)';
    } else if (anos > 0) {
      return '$anos ano(s)';
    } else {
      return '$meses mes(es)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box<Consulta> consultaBox = Hive.box<Consulta>('consultas');
    final Box<Vaccine> vacinaBox = Hive.box<Vaccine>('vaccines');

    final consultasDoPet = consultaBox.values
        .where((c) => c.pet.toLowerCase() == pet.nome.toLowerCase())
        .toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(b.data)
          .compareTo(DateFormat('dd/MM/yyyy').parse(a.data)));

    final vacinasDoPet = vacinaBox.values
        .where((v) => v.pet.toLowerCase() == pet.nome.toLowerCase())
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes de ${pet.nome}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${pet.nome}', style: const TextStyle(fontSize: 18)),
              Text('Raça: ${pet.raca}', style: const TextStyle(fontSize: 18)),
              Text('Idade: ${_formatIdade(pet.idade)}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),

              const Text('Consultas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (consultasDoPet.isEmpty)
                const Text('Nenhuma consulta registrada.')
              else
                ...consultasDoPet.map((c) => Card(
                  child: ListTile(
                    title: Text(DateFormat('dd/MM/yyyy')
                        .format(DateFormat('dd/MM/yyyy').parse(c.data))),
                    subtitle: Text(
                        'Vet: ${c.veterinario}\n${c.observacoes.isNotEmpty ? c.observacoes : 'Sem observações.'}'),
                    isThreeLine: true,
                  ),
                )),

              const SizedBox(height: 24),
              const Text('Vacinas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (vacinasDoPet.isEmpty)
                const Text('Nenhuma vacina registrada.')
              else
                ...vacinasDoPet.map((v) => Card(
                  child: ListTile(
                    title: Text(v.vacina),
                    subtitle: Text(
                        'Data: ${DateFormat('dd/MM/yyyy').format(v.data)}'),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
