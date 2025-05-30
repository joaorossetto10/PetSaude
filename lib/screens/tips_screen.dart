import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const List<Map<String, String>> _tips = [
    {
      'title': 'Alimentação',
      'text': 'Ofereça uma ração de qualidade e mantenha sempre água fresca disponível.'
    },
    {
      'title': 'Exercício',
      'text': 'Realize passeios diários e proporcione momentos de brincadeira.'
    },
    {
      'title': 'Vacinação',
      'text': 'Mantenha o calendário de vacinas em dia conforme orientação do veterinário.'
    },
    {
      'title': 'Higiene',
      'text': 'Banhos regulares, limpeza de ouvidos e escovação dos dentes são importantes.'
    },
    {
      'title': 'Atenção',
      'text': 'Dê carinho, atenção e acompanhamento regular ao bem-estar do seu pet.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Cuidados')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tip = _tips[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip['text']!,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
