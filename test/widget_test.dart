import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petsaude/screens/home_screen.dart';
import 'package:petsaude/screens/pet_form_screen.dart';
import 'package:petsaude/screens/vaccine_screen.dart';
import 'package:petsaude/screens/consult_screen.dart';
import 'package:petsaude/screens/tips_screen.dart';

void main() {
  Widget createTestApp() {
    return MaterialApp(
      home: const HomeScreen(),
      routes: {
        '/pet_form': (context) => const PetFormScreen(),
        '/vaccine': (context) => const VaccineScreen(),
        '/consult': (context) => const ConsultScreen(),
        '/tips': (context) => const TipsScreen(),
      },
    );
  }

  testWidgets('HomeScreen aparece com título PetSaúde', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('PetSaúde'), findsOneWidget);
  });

  testWidgets('HomeScreen tem os botões principais e navega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final cadastrarPetBtn = find.text('Cadastrar Pet');
    final registroVacinasBtn = find.text('Registro de Vacinas');
    final historicoConsultasBtn = find.text('Histórico de Consultas');
    final dicasCuidadosBtn = find.text('Dicas de Cuidados');

    expect(cadastrarPetBtn, findsOneWidget);
    expect(registroVacinasBtn, findsOneWidget);
    expect(historicoConsultasBtn, findsOneWidget);
    expect(dicasCuidadosBtn, findsOneWidget);

    await tester.tap(cadastrarPetBtn);
    await tester.pumpAndSettle();
    expect(find.text('Novo Pet'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(registroVacinasBtn);
    await tester.pumpAndSettle();
    expect(find.text('Vacinas'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(historicoConsultasBtn);
    await tester.pumpAndSettle();
    expect(find.text('Consultas'), findsOneWidget);  // Corrigido
    expect(find.text('Histórico:'), findsOneWidget); // Confirma que entrou na tela certa
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(dicasCuidadosBtn);
    await tester.pumpAndSettle();
    expect(find.text('Dicas de Cuidados'), findsOneWidget);
  });
}
