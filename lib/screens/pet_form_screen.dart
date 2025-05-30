import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/pet.dart';
import '../data/racas.dart';

class PetFormScreen extends StatefulWidget {
  final Pet? pet;
  final int? petKey;

  const PetFormScreen({super.key, this.pet, this.petKey});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();

  String? _selectedEspecie;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.nome;
      _breedController.text = widget.pet!.raca;
      _selectedEspecie = _encontrarTipoPorRaca(widget.pet!.raca);

      final idade = widget.pet!.idade;
      _yearsController.text = (idade ~/ 12).toString();
      _monthsController.text = (idade % 12).toString();
    }
  }

  String? _encontrarTipoPorRaca(String raca) {
    for (final tipo in racasPorTipo.keys) {
      if (racasPorTipo[tipo]!.contains(raca)) {
        return tipo;
      }
    }
    return null;
  }

  void _savePet() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();

      final idadeAnos = int.tryParse(_yearsController.text.trim()) ?? 0;
      final idadeMeses = int.tryParse(_monthsController.text.trim()) ?? 0;
      final idadeFinal = idadeAnos * 12 + idadeMeses;

      final pet = Pet(
        nome: _nameController.text.trim(),
        raca: _breedController.text.trim(),
        idade: idadeFinal,
      );

      final petBox = Hive.box<Pet>('pets');

      if (widget.pet == null) {
        await petBox.add(pet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet salvo com sucesso!')),
        );
      } else {
        await petBox.put(widget.petKey, pet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet atualizado com sucesso!')),
        );
      }

      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Pet' : 'Novo Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode:
          _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Espécie'),
                value: _selectedEspecie,
                items: racasPorTipo.keys
                    .map((tipo) => DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEspecie = value;
                    _breedController.clear();
                  });
                },
                validator: (value) =>
                value == null ? 'Selecione a espécie' : null,
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (_selectedEspecie == null) return const Iterable<String>.empty();
                  final allOptions = racasPorTipo[_selectedEspecie] ?? [];
                  return textEditingValue.text.isEmpty
                      ? allOptions
                      : allOptions.where((raca) =>
                      raca.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // força exibir opções quando o campo ganhar foco
                  focusNode.addListener(() {
                    if (focusNode.hasFocus && controller.text.isEmpty) {
                      controller.text = ' ';
                      controller.text = '';
                    }
                  });

                  if (controller.text.isEmpty) {
                    controller.text = _breedController.text;
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Raça'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a raça' : null,
                    onChanged: (value) => _breedController.text = value,
                  );
                },
                onSelected: (String selection) {
                  _breedController.text = selection;
                },
              ),
              const SizedBox(height: 12),
              const Text('Idade', style: TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearsController,
                      decoration: const InputDecoration(labelText: 'Anos'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe os anos'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _monthsController,
                      decoration: const InputDecoration(labelText: 'Meses'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe os meses'
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _savePet,
          child: Text(isEditing ? 'Atualizar' : 'Salvar'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
