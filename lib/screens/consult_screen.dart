import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/consulta.dart';
import '../models/pet.dart';
import '../data/racas.dart';
import '../data/assuntos.dart';

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  final _dateController = TextEditingController();
  final _vetController = TextEditingController();
  final _notesController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _racaController = TextEditingController();
  final _especieController = TextEditingController();

  late Box<Consulta> _consultaBox;
  late Box<Pet> _petBox;

  String? _selectedPet;
  String? _selectedEspecie;
  String? _selectedRaca;
  int? _editingKey;

  DateTime? _minDate;

  @override
  void initState() {
    super.initState();
    _consultaBox = Hive.box<Consulta>('consultas');
    _petBox = Hive.box<Pet>('pets');
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_minDate == null) return;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _minDate!,
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _saveConsult() async {
    if (_selectedPet == null ||
        _dateController.text.isEmpty ||
        _vetController.text.isEmpty ||
        _assuntoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    try {
      DateFormat('dd/MM/yyyy').parseStrict(_dateController.text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato de data inválido. Use dd/mm/aaaa')),
      );
      return;
    }

    final consulta = Consulta(
      pet: _selectedPet!,
      data: _dateController.text.trim(),
      veterinario: _vetController.text.trim(),
      observacoes: _notesController.text.trim(),
      assunto: _assuntoController.text.trim(),
    );

    if (_editingKey == null) {
      await _consultaBox.add(consulta);
    } else {
      await _consultaBox.put(_editingKey, consulta);
      _editingKey = null;
    }

    _clearFields();
    setState(() {});
  }

  void _clearFields() {
    _selectedPet = null;
    _selectedEspecie = null;
    _selectedRaca = null;
    _especieController.clear();
    _racaController.clear();
    _minDate = null;
    _dateController.clear();
    _vetController.clear();
    _notesController.clear();
    _assuntoController.clear();
  }

  void _editConsult(int key, Consulta consulta) {
    final pet = _petBox.values.firstWhere(
          (p) => p.nome.toLowerCase() == consulta.pet.toLowerCase(),
      orElse: () => Pet(nome: '', raca: '', idade: 0),
    );
    final especie = racasPorTipo.entries
        .firstWhere((entry) => entry.value.contains(pet.raca), orElse: () => const MapEntry('Outros', []))
        .key;
    setState(() {
      _editingKey = key;
      _selectedPet = consulta.pet;
      _selectedEspecie = especie;
      _selectedRaca = pet.raca;
      _especieController.text = especie;
      _racaController.text = pet.raca;
      _minDate = DateTime.now().subtract(Duration(days: pet.idade * 30));
      _dateController.text = consulta.data;
      _vetController.text = consulta.veterinario;
      _notesController.text = consulta.observacoes;
      _assuntoController.text = consulta.assunto;
    });
  }

  void _deleteConsult(int key) async {
    await _consultaBox.delete(key);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consulta excluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consultas = _consultaBox.toMap().entries.toList().reversed.toList();
    final petNames = _petBox.values.map((p) => p.nome).where((nome) => nome.trim().isNotEmpty).toSet().toList();

    final assuntosDisponiveis = _selectedEspecie != null &&
        assuntosPorTipo.containsKey(_selectedEspecie!)
        ? List<String>.from(assuntosPorTipo[_selectedEspecie!]!)
        : <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Consultas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPet,
              decoration: const InputDecoration(labelText: 'Nome do Pet *'),
              items: petNames.map((nome) => DropdownMenuItem(value: nome, child: Text(nome))).toList(),
              onChanged: (value) {
                final pet = _petBox.values.firstWhere((p) => p.nome == value);
                final tipo = racasPorTipo.entries.firstWhere(
                        (e) => e.value.contains(pet.raca),
                    orElse: () => const MapEntry('Outros', [])).key;
                setState(() {
                  _selectedPet = value;
                  _selectedEspecie = tipo;
                  _selectedRaca = pet.raca;
                  _especieController.text = tipo;
                  _racaController.text = pet.raca;
                  _minDate = DateTime.now().subtract(Duration(days: pet.idade * 30));
                  _assuntoController.clear();
                });
              },
              validator: (value) => value == null ? 'Selecione um pet cadastrado' : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _especieController,
              decoration: const InputDecoration(labelText: 'Espécie'),
              enabled: false,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _racaController,
              decoration: const InputDecoration(labelText: 'Raça'),
              enabled: false,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') {
                  return assuntosDisponiveis;
                }
                return assuntosDisponiveis
                    .where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.text = _assuntoController.text;

                focusNode.addListener(() {
                  if (focusNode.hasFocus && controller.text.isEmpty) {
                    controller.text = ' ';
                    controller.selection = TextSelection.collapsed(offset: 1);
                    Future.delayed(const Duration(milliseconds: 10), () {
                      controller.clear();
                    });
                  }
                });

                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Assunto *'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o assunto' : null,
                  onChanged: (value) => _assuntoController.text = value,
                );
              },
              onSelected: (selection) => _assuntoController.text = selection,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Data da Consulta *',
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
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vetController,
              decoration: const InputDecoration(labelText: 'Veterinário *'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveConsult,
              child: Text(_editingKey == null ? 'Adicionar Consulta' : 'Atualizar Consulta'),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Histórico:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: consultas.isEmpty
                  ? const Center(child: Text('Nenhuma consulta registrada ainda.'))
                  : ListView(
                children: consultas.map((entry) => _buildConsultCard(entry.key, entry.value)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultCard(int key, Consulta consulta) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('${consulta.pet} – ${consulta.data}'),
        subtitle: Text('Assunto: ${consulta.assunto}\nVet: ${consulta.veterinario}\n${consulta.observacoes}'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              _editConsult(key, consulta);
            } else if (value == 'excluir') {
              _deleteConsult(key);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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
