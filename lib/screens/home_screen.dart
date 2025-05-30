import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetSaúde'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildMenuButton(
                    context,
                    key: const Key('cadastrarPetButton'),
                    label: 'Cadastrar Pet',
                    routeName: '/pet_form',
                    icon: Icons.pets,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    key: const Key('verPetsButton'),
                    label: 'Ver Pets Cadastrados', // ✅ NOVO
                    routeName: '/pet_list',
                    icon: Icons.list_alt,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    key: const Key('registroVacinasButton'),
                    label: 'Registro de Vacinas',
                    routeName: '/vaccine',
                    icon: Icons.vaccines,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    key: const Key('consultasButton'),
                    label: 'Histórico de Consultas',
                    routeName: '/consult',
                    icon: Icons.medical_services,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    key: const Key('dicasCuidadosButton'),
                    label: 'Dicas de Cuidados',
                    routeName: '/tips',
                    icon: Icons.lightbulb,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PetSaúde v1.0',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String label,
        required String routeName,
        required IconData icon,
        Key? key,
      }) {
    return ElevatedButton.icon(
      key: key,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: () => Navigator.pushNamed(context, routeName),
    );
  }
}
