import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio centralizado para gestionar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  /// Solicitar permisos de notificaciones (Android 13+)
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iOSImplementation != null) {
        final bool? granted = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    return false;
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iOSImplementation != null) {
        return true; // iOS notifications are enabled if permissions were granted
      }
    }

    return false;
  }

  /// Mostrar una notificación simple
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'kenwa_notifications',
          'Notificaciones Kenwa',
          channelDescription: 'Recordatorios de descanso y bienestar',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Programar una notificación periódica
  /// [interval] debe ser un minuto válido
  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required Duration interval,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'kenwa_notifications',
          'Notificaciones Kenwa',
          channelDescription: 'Recordatorios de descanso y bienestar',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Mostrar notificación persistente del timer (aparece en barra de notificaciones y pantalla de bloqueo)
  Future<void> showTimerNotification({
    required String timeRemaining,
    required String status,
    bool isWorking = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const int timerNotificationId =
        100; // ID fijo para la notificación del timer

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'kenwa_timer',
          'Timer Kenwa',
          channelDescription: 'Muestra el timer en curso',
          importance: Importance.low, // Low para que no haga sonido/vibración
          priority: Priority.low,
          ongoing: true, // Hace que la notificación sea persistente
          autoCancel: false, // No se cierra al tocarla
          showWhen: false, // No mostrar timestamp
          playSound: false,
          enableVibration: false,
          visibility:
              NotificationVisibility.public, // Visible en pantalla de bloqueo
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            timeRemaining,
            contentTitle: status,
          ),
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      timerNotificationId,
      status,
      timeRemaining,
      notificationDetails,
    );
  }

  /// Cancelar la notificación persistente del timer
  Future<void> cancelTimerNotification() async {
    const int timerNotificationId = 100;
    await _flutterLocalNotificationsPlugin.cancel(timerNotificationId);
  }

  /// Cancelar una notificación
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
