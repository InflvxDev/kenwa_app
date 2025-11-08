import 'package:flutter/material.dart';
import 'package:kenwa_app/app/app.dart';
import 'package:kenwa_app/app/router.dart';
import 'package:kenwa_app/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Solicitar permisos (solo Android 13+ / iOS)
  await notificationService.requestNotificationPermission();

  // Inicializar el router con la ubicación dinámica
  await initializeRouter();

  runApp(const KenwaApp());
}
