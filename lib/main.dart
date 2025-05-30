import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models
import 'models/consulta.dart';
import 'models/pet.dart';
import 'models/vaccine.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/pet_list_screen.dart';
import 'screens/vaccine_screen.dart';
import 'screens/consult_screen.dart';
import 'screens/tips_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ConsultaAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PetAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(VaccineAdapter());

  try {
    await Hive.openBox<Consulta>('consultas');
    await Hive.openBox<Pet>('pets');
    await Hive.openBox<Vaccine>('vaccines');
  } catch (e) {
    await Hive.deleteBoxFromDisk('consultas');
    await Hive.deleteBoxFromDisk('pets');
    await Hive.deleteBoxFromDisk('vaccines');
    await Hive.openBox<Consulta>('consultas');
    await Hive.openBox<Pet>('pets');
    await Hive.openBox<Vaccine>('vaccines');
  }

  runApp(const PetSaudeApp());
}

class PetSaudeApp extends StatelessWidget {
  const PetSaudeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetSaúde',
      themeMode: ThemeMode.light, // 👈 força tema claro
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color.fromARGB(255, 20, 138, 10),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 20, 138, 10),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 20, 138, 10)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 20, 138, 10),
            foregroundColor: Colors.white,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/pet_form': (context) => const PetFormScreen(),
        '/pet_list': (context) => const PetListScreen(),
        '/vaccine': (context) => const VaccineScreen(),
        '/consult': (context) => const ConsultScreen(),
        '/tips': (context) => const TipsScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
    );
  }
}
