import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/vaccine.dart';
import '../models/pet.dart';
import '../data/racas.dart';
import '../data/vacinas.dart';

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineController = TextEditingController();
  final _dateDisplayController = TextEditingController();
  final _especieController = TextEditingController();
  final _racaController = TextEditingController();

  String? _selectedPet;
  String? _tipoPet;
  int? _editingKey;

  late Box<Vaccine> _vaccineBox;
  late Box<Pet> _petBox;

  @override
  void initState() {
    super.initState();
    _vaccineBox = Hive.box<Vaccine>('vaccines');
    _petBox = Hive.box<Pet>('pets');
  }

  @override
  void dispose() {
    _vaccineController.dispose();
    _dateDisplayController.dispose();
    _especieController.dispose();
    _racaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _dateDisplayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveVaccine() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(_dateDisplayController.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato de data inválido. Use dd/mm/aaaa')),
      );
      return;
    }

    // Valida se a data é anterior ao nascimento do pet
    final pet = _petBox.values.firstWhere((p) => p.nome == _selectedPet);
    final nascimentoEstimado = DateTime.now().subtract(Duration(days: pet.idade * 30));
    if (parsedDate.isBefore(nascimentoEstimado)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data da vacina não pode ser anterior ao nascimento do pet.')),
      );
      return;
    }

    final vacina = Vaccine(
      pet: _selectedPet!,
      vacina: _vaccineController.text.trim(),
      data: parsedDate,
    );

    if (_editingKey == null) {
      _vaccineBox.add(vacina);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vacina registrada com sucesso!')),
      );
    } else {
      _vaccineBox.put(_editingKey, vacina);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vacina atualizada com sucesso!')),
      );
    }

    _clearForm();
    setState(() {});
  }

  void _clearForm() {
    _selectedPet = null;
    _tipoPet = null;
    _vaccineController.clear();
    _dateDisplayController.clear();
    _especieController.clear();
    _racaController.clear();
    _editingKey = null;
  }

  void _startEditing(int key, Vaccine vacina) {
    final pet = _petBox.values.firstWhere(
          (p) => p.nome.toLowerCase() == vacina.pet.toLowerCase(),
      orElse: () => Pet(nome: '', raca: '', idade: 0),
    );
    final tipo = racasPorTipo.entries
        .firstWhere((entry) => entry.value.contains(pet.raca), orElse: () => const MapEntry('Outros', []))
        .key;

    setState(() {
      _editingKey = key;
      _selectedPet = vacina.pet;
      _tipoPet = tipo;
      _especieController.text = tipo;
      _racaController.text = pet.raca;
      _vaccineController.text = vacina.vacina;
      _dateDisplayController.text = DateFormat('dd/MM/yyyy').format(vacina.data);
    });
  }

  void _deleteVaccine(int key) {
    _vaccineBox.delete(key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vacina excluída com sucesso!')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vacinas = _vaccineBox.toMap().entries.toList().reversed.toList();
    final pets = _petBox.values.toList();
    final nomesPets = pets.map((p) => p.nome).toList();
    final vacinasDisponiveis = _tipoPet != null ? (vacinasPorTipo[_tipoPet!] ?? []) : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Vacinas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPet,
                    decoration: const InputDecoration(labelText: 'Nome do Pet *'),
                    items: nomesPets.map((nome) => DropdownMenuItem(value: nome, child: Text(nome))).toList(),
                    onChanged: (value) {
                      final pet = pets.firstWhere((p) => p.nome == value);
                      final tipo = racasPorTipo.entries
                          .firstWhere((e) => e.value.contains(pet.raca), orElse: () => const MapEntry('Outros', []))
                          .key;
                      setState(() {
                        _selectedPet = value;
                        _tipoPet = tipo;
                        _vaccineController.clear();
                        _especieController.text = tipo;
                        _racaController.text = pet.raca;
                      });
                    },
                    validator: (value) => value == null ? 'Selecione um pet' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _especieController,
                    decoration: const InputDecoration(labelText: 'Espécie'),
                    enabled: false,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _racaController,
                    decoration: const InputDecoration(labelText: 'Raça'),
                    enabled: false,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (_tipoPet == null) return const Iterable<String>.empty();
                      final allVacinas = vacinasPorTipo[_tipoPet!] ?? [];
                      return textEditingValue.text.isEmpty
                          ? allVacinas
                          : allVacinas.where((v) =>
                          v.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      focusNode.addListener(() {
                        if (focusNode.hasFocus && controller.text.isEmpty) {
                          controller.text = ' ';
                          controller.text = '';
                        }
                      });

                      controller.text = _vaccineController.text;
                      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Vacina *'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Informe a vacina' : null,
                        onChanged: (value) => _vaccineController.text = value,
                      );
                    },
                    onSelected: (selection) => _vaccineController.text = selection,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateDisplayController,
                    decoration: InputDecoration(
                      labelText: 'Data da Vacina *',
                      hintText: 'dd/mm/aaaa',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                      _DateInputFormatter(),
                    ],
                    readOnly: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Informe a data';
                      try {
                        DateFormat('dd/MM/yyyy').parseStrict(value.trim());
                        return null;
                      } catch (_) {
                        return 'Data inválida';
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveVaccine,
                    child: Text(_editingKey == null ? 'Registrar Vacina' : 'Atualizar Vacina'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Histórico de Vacinas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: vacinas.isEmpty
                  ? const Center(child: Text('Nenhuma vacina registrada.'))
                  : ListView.builder(
                itemCount: vacinas.length,
                itemBuilder: (context, index) {
                  final entry = vacinas[index];
                  final key = entry.key;
                  final vacina = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.medical_services, color: Colors.teal),
                      title: Text('${vacina.pet} – ${vacina.vacina}'),
                      subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(vacina.data)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _startEditing(key, vacina),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVaccine(key),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
