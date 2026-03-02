import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'src/features/scanner/scanner_controller.dart';
import 'src/features/scanner/scanner_page.dart';
import 'src/repositories/bill_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ScannerController(repository: BillRepository()),
      child: const VerificadorApp(),
    ),
  );
}

class VerificadorApp extends StatelessWidget {
  const VerificadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verificador de Billetes Bolivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13EC5B),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const ScannerPage(),
    );
  }
}
