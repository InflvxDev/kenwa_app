import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/presentation/widgets/nivel_estres_selector.dart';
import 'package:kenwa_app/services/stress_service.dart';

/// Modal que aparece al abrir la app para preguntar el estado de ánimo actual.
class EstadoAnimoModal extends StatefulWidget {
  const EstadoAnimoModal({super.key});

  @override
  State<EstadoAnimoModal> createState() => _EstadoAnimoModalState();

  /// Muestra el modal y guarda el nuevo nivel en StressService
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: EstadoAnimoModal(),
      ),
    );
  }
}

class _EstadoAnimoModalState extends State<EstadoAnimoModal> {
  int _selectedLevel = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLevel();
  }

  Future<void> _loadCurrentLevel() async {
    final stressService = StressService();
    await stressService.initialize();
    setState(() {
      _selectedLevel = stressService.stressLevel;
    });
  }

  Future<void> _saveLevel() async {
    setState(() => _saving = true);
    final stressService = StressService();
    await stressService.initialize();
    await stressService.setStressLevel(_selectedLevel);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '¿Cómo te sientes hoy?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Selecciona tu nivel actual de estrés',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          NivelEstresSelector(
            label: '',
            subLabel: '',
            initialLevel: _selectedLevel,
            onLevelChanged: (value) {
              setState(() => _selectedLevel = value);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _saveLevel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Guardar y continuar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
