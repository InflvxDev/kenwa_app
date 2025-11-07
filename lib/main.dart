import 'package:flutter/material.dart';
import 'package:kenwa_app/app/app.dart';
import 'package:kenwa_app/app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar el router con la ubicación dinámica
  await initializeRouter();
  runApp(const KenwaApp());
}
