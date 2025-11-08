import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';
import 'package:kenwa_app/features/config/domain/usecases/guardar_configuracion.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';
import 'package:kenwa_app/features/config/presentation/controllers/configuracion_controller.dart';
import 'package:kenwa_app/features/config/presentation/widgets/boton_guardar.dart';
import 'package:kenwa_app/features/config/presentation/widgets/frecuencia_slider.dart';
import 'package:kenwa_app/features/config/presentation/widgets/horario_input.dart';
import 'package:kenwa_app/features/config/presentation/widgets/nivel_estres_selector.dart';
import 'package:kenwa_app/services/notification_service.dart';
import 'package:kenwa_app/services/stress_service.dart';
import 'package:kenwa_app/services/timer_service.dart';

/// Página de configuración editable desde el home
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ConfiguracionController _controller;
  bool _isLoading = true;
  late HoraDelDia _horaInicio;
  late HoraDelDia _horaFin;
  late int _intervaloDescansos;
  late int _tiempoDescanso;
  late bool _notificacionesActivas;
  late int _nivelEstres; // Valor externo: 1, 4, 7 o 10

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadConfiguration();
  }

  void _initializeController() {
    final localSource = ConfiguracionLocalSource();
    final repository = ConfiguracionRepositoryImpl(localSource: localSource);
    final guardarUseCase = GuardarConfiguracionUseCase(repository: repository);
    final obtenerUseCase = ObtenerConfiguracionUseCase(repository: repository);

    _controller = ConfiguracionController(
      guardarUseCase: guardarUseCase,
      obtenerUseCase: obtenerUseCase,
    );
  }

  Future<void> _loadConfiguration() async {
    try {
      // Inicializar StressService para cargar valores persistidos
      final stressService = StressService();
      await stressService.initialize();

      final config = await _controller.obtenerConfiguracion();

      if (config != null) {
        // Usar el valor del StressService como fuente de verdad para el nivel de estrés
        final stressLevel = stressService.stressLevel;

        setState(() {
          _horaInicio = config.horaInicio;
          _horaFin = config.horaFin;
          _intervaloDescansos = config.intervaloDescansos;
          _tiempoDescanso = config.tiempoDescanso;
          _notificacionesActivas = config.notificacionesActivas;
          // Usar el nivel de estrés actual
          _nivelEstres = stressLevel;
          _isLoading = false;
        });
      } else {
        // Si no hay configuración, usar valores por defecto
        _initializeDefaults();
      }
    } catch (e) {
      debugPrint('Error loading configuration: $e');
      _initializeDefaults();
    }
  }

  void _initializeDefaults() {
    setState(() {
      _horaInicio = HoraDelDia(hour: 8, minute: 0);
      _horaFin = HoraDelDia(hour: 18, minute: 0);
      _intervaloDescansos = 60;
      _tiempoDescanso = 5;
      _notificacionesActivas = false;
      _nivelEstres = 1;
      _isLoading = false;
    });
  }

  Future<void> _guardarConfiguracion() async {
    final configuracion = Configuracion(
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      intervaloDescansos: _intervaloDescansos,
      tiempoDescanso: _tiempoDescanso,
      notificacionesActivas: _notificacionesActivas,
      nivelEstresInicial: _nivelEstres,
    );

    final success = await _controller.guardarConfiguracion(configuracion);

    if (!mounted) return;

    if (success) {
      // Actualizar el nivel de estrés si cambió
      final stressService = StressService();
      await stressService.initialize();
      await stressService.setStressLevel(_nivelEstres);

      if (!mounted) return;

      // Resetear el timer cuando se guarda nueva configuración
      TimerService().reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada exitosamente')),
      );
      // Ir al home
      context.go('/home');
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Configuración'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Edita tu configuración',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Actualiza tus preferencias en cualquier momento',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.foreground.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Sección de Jornada Laboral
              Text(
                'Jornada Laboral',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              HorarioInput(
                label: 'Hora de inicio',
                initialTime: _horaInicio,
                onTimeChanged: (time) {
                  setState(() => _horaInicio = time);
                },
              ),
              const SizedBox(height: 16),
              HorarioInput(
                label: 'Hora de fin',
                initialTime: _horaFin,
                onTimeChanged: (time) {
                  setState(() => _horaFin = time);
                },
              ),
              const SizedBox(height: 32),

              // Sección de Intervalos
              Text(
                'Intervalos de Descanso',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              FrecuenciaSlider(
                label: 'Intervalo entre descansos',
                subLabel: 'Tiempo entre cada pausa activa',
                initialValue: _intervaloDescansos,
                minValue: 1,
                maxValue: 120,
                unit: 'min',
                onValueChanged: (value) {
                  setState(() => _intervaloDescansos = value);
                },
              ),
              const SizedBox(height: 24),
              FrecuenciaSlider(
                label: 'Duración del descanso',
                subLabel: 'Tiempo de pausa recomendado',
                initialValue: _tiempoDescanso,
                minValue: 1,
                maxValue: 15,
                unit: 'min',
                onValueChanged: (value) {
                  setState(() => _tiempoDescanso = value);
                },
              ),
              const SizedBox(height: 32),

              // Sección de Nivel de Estrés
              NivelEstresSelector(
                label: 'Nivel de estrés inicial',
                subLabel: 'Selecciona tu nivel actual de estrés',
                initialLevel: _nivelEstres,
                onLevelChanged: (level) {
                  setState(() => _nivelEstres = level);
                },
              ),
              const SizedBox(height: 32),

              // Sección de Notificaciones
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.foreground.withValues(alpha: 0.06),
                  border: Border.all(
                    color: AppColors.foreground.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recibe recordatorios de descanso',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _notificacionesActivas,
                      onChanged: (value) async {
                        // Si activa las notificaciones, solicitar permisos
                        if (value) {
                          // Capturar el messenger ANTES de cualquier operación asíncrona
                          final messenger = ScaffoldMessenger.of(context);

                          final notificationService = NotificationService();
                          await notificationService.initialize();
                          final permissionGranted = await notificationService
                              .requestNotificationPermission();

                          if (!mounted) return;

                          if (permissionGranted) {
                            setState(() => _notificacionesActivas = true);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Permisos de notificaciones habilitados',
                                ),
                              ),
                            );
                          } else {
                            setState(() => _notificacionesActivas = false);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Se necesitan permisos de notificaciones',
                                ),
                              ),
                            );
                          }
                        } else {
                          setState(() => _notificacionesActivas = false);
                        }
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Botón Guardar
              BotonGuardar(
                label: 'Guardar Cambios',
                isLoading: _controller.isLoading,
                onPressed: _guardarConfiguracion,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
