import 'package:flutter/material.dart';
import 'package:kenwa_app/app/router.dart';
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

/// Página de configuración inicial del usuario
class ConfiguracionInicialPage extends StatefulWidget {
  const ConfiguracionInicialPage({super.key});

  @override
  State<ConfiguracionInicialPage> createState() =>
      _ConfiguracionInicialPageState();
}

class _ConfiguracionInicialPageState extends State<ConfiguracionInicialPage> {
  late ConfiguracionController _controller;
  late HoraDelDia _horaInicio;
  late HoraDelDia _horaFin;
  late int _intervaloDescansos;
  late int _tiempoDescanso;
  late bool _notificacionesActivas;
  late int _nivelEstres;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeDefaults();
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

  void _initializeDefaults() {
    _horaInicio = HoraDelDia(hour: 9, minute: 0);
    _horaFin = HoraDelDia(hour: 18, minute: 0);
    _intervaloDescansos = 60; // minutos
    _tiempoDescanso = 5; // minutos
    _notificacionesActivas = true;
    _nivelEstres = 2;
  }

  Future<void> _guardarConfiguracion() async {
    final configuracion = Configuracion(
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      intervaloDescansos: _intervaloDescansos,
      tiempoDescanso: _tiempoDescanso,
      notificacionesActivas: _notificacionesActivas,
    );

    final success = await _controller.guardarConfiguracion(configuracion);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada exitosamente')),
      );
      // Navegar a la pantalla principal
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          AppRouter.goHome(context);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Configuración Inicial'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personaliza tu experiencia en Kenwa',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Estos datos nos ayudarán a ofrecerte recomendaciones personalizadas',
              style: Theme.of(context).textTheme.bodySmall,
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
              minValue: 15,
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                    onChanged: (value) {
                      setState(() => _notificacionesActivas = value);
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Botón Guardar
            BotonGuardar(
              label: 'Guardar Configuración',
              isLoading: _controller.isLoading,
              onPressed: _guardarConfiguracion,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
