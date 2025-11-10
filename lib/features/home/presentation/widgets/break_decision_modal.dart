import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Modal flotante para preguntar si el usuario quiere descansar después del trabajo
class BreakDecisionModal extends StatelessWidget {
  final VoidCallback onBreakPressed;
  final VoidCallback onContinueWorkPressed;
  final int stressLevel;

  const BreakDecisionModal({
    super.key,
    required this.onBreakPressed,
    required this.onContinueWorkPressed,
    required this.stressLevel,
  });

  // Niveles 1-3: Tranquilo/Relajado
  static final List<String> _lowStressMessages = [
    '¡Todo va genial! ¿Necesitas un descanso?',
    'Estás muy relajado. ¿Un pequeño respiro?',
    'Vas muy tranquilo. ¿Tomamos un break?',
    'Todo bajo control. ¿Descansamos un momento?',
    '¡Qué calma! ¿Te gustaría estirarte un poco?',
    'Vas muy bien. ¿Un descanso corto?',
    'Excelente ritmo. ¿Quieres tomar aire?',
    '¡Qué paz trabajar así! ¿Descansemos?',
  ];

  // Niveles 4-6: Normal/Moderado
  static final List<String> _mediumStressMessages = [
    'Has estado trabajando duro ¿Quieres descansar?',
    '¡Buen trabajo! ¿Necesitas un descanso?',
    'Has avanzado mucho. ¿Tomamos un respiro?',
    'Ese ritmo de trabajo es bueno. ¿Descanso?',
    'Estás enfocado. ¿Te gustaría descansar?',
    '¡Vas bien! ¿Necesitas un respiro?',
    'Tu progreso es sólido. ¿Descansemos?',
    'Has trabajado bastante. ¿Un break?',
    '¡Mírate bro! ¿Quieres tomarte un descanso?',
    'Tu enfoque es admirable. ¿Descansamos?',
  ];

  // Niveles 7-9: Estresado
  static final List<String> _highStressMessages = [
    '¡Uff! Has trabajado intenso. ¿Necesitas descansar?',
    'Ese ritmo es fuerte. ¿Un descanso te vendría bien?',
    '¡Wow! ¿No te sientes cansado? ¿Descansamos?',
    'Has dado mucho. ¿Tomamos un respiro?',
    '¡Estás a full! Considera descansar un poco',
    'Ese esfuerzo es notable. ¿Necesitas un break?',
    '¡Vaya presión! ¿Quieres tomarte un descanso?',
    'Has empujado duro. ¿Descansemos un momento?',
    '¡Menudo ritmo! ¿No necesitas relajarte?',
  ];

  // Nivel 10: Muy estresado
  static final List<String> _veryHighStressMessages = [
    '¡ALTO! Necesitas descansar YA. ¿Tomamos un break?',
    '¡Estás al límite! Por favor, considera descansar',
    '¡Cuidado! Tu nivel es máximo. ¿Descansamos?',
    'URGENTE: Necesitas un descanso. ¿Lo tomamos?',
    '¡Alerta roja! Tu cuerpo necesita un respiro',
    '¡Frena un poco! ¿Tomamos un descanso necesario?',
    '¡Estás en rojo! Es momento de descansar',
    '¡Máximo estrés! Deberías descansar ahora',
    'No te pagan lo suficiente para esto. ¡Descansa ya!',
  ];

  String _getRandomMessage() {
    List<String> messages;

    if (stressLevel <= 3) {
      messages = _lowStressMessages;
    } else if (stressLevel <= 6) {
      messages = _mediumStressMessages;
    } else if (stressLevel <= 9) {
      messages = _highStressMessages;
    } else {
      messages = _veryHighStressMessages;
    }

    messages.shuffle();
    return messages.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 24,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono decorativo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.thumb_up_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Mensaje principal
            Text(
              _getRandomMessage(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Botones
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBreakPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Descansar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onContinueWorkPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: AppColors.foreground.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Seguir Trabajando',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Modal informativo después del descanso
  static Future<void> showRestCompletedModal(
    BuildContext context,
    VoidCallback onOkPressed,
    int stressLevel,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RestCompletedModal(
        onOkPressed: onOkPressed,
        stressLevel: stressLevel,
      ),
    );
  }
}

/// Modal informativo después del descanso
class RestCompletedModal extends StatefulWidget {
  final VoidCallback onOkPressed;
  final int stressLevel;

  const RestCompletedModal({
    super.key,
    required this.onOkPressed,
    required this.stressLevel,
  });

  @override
  State<RestCompletedModal> createState() => _RestCompletedModalState();
}

class _RestCompletedModalState extends State<RestCompletedModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Niveles 1-3: Muy relajado después del descanso
  static final List<String> _lowStressMessages = [
    '¡Perfecto! Estás súper relajado. Vamos con todo',
    'Te ves increíblemente fresco. ¡A brillar!',
    '¡Qué paz! Ahora a continuar con esa energía',
    'Estás en tu mejor momento. ¡Adelante!',
    '¡Totalmente renovado! Vamos por más',
    'Ese nivel de calma es ideal. ¡Sigamos!',
    '¡Qué bien te ves! A trabajar con entusiasmo',
    'Recargado al 100%. ¡Es tu momento!',
  ];

  // Niveles 4-6: Nivel normal después del descanso
  static final List<String> _mediumStressMessages = [
    'Me alegra que estés descansado. Volvamos al trabajo',
    '¡Recargado y listo! Volvamos al trabajo',
    'Descansaste bien, ahora a darle duro nuevamente',
    '¡Qué descanso tan merecido! Volvamos a la acción',
    'Estás listo para más, ¡a trabajar!',
    'Te ves fresco. ¡Volvamos a conquistar!',
    'Ese descanso te hizo bien. ¿Listo para más?',
    '¡Energía renovada! Es hora de continuar',
    'Descansaste perfecto. Ahora a darle todo',
    'Relajado y motivado. ¡Sigue adelante!',
  ];

  // Niveles 7-9: Aún algo estresado después del descanso
  static final List<String> _highStressMessages = [
    'Ese descanso ayudó. Vamos con más calma ahora',
    'Mejor que antes. Continuemos con buen ritmo',
    'Has recuperado algo. Sigamos con cuidado',
    'El break te hizo bien. Ahora más tranquilo',
    'Mejoró tu nivel. Volvamos con mejor energía',
    'Descansaste. Ahora a trabajar más relajado',
    'Te sientes mejor. Continuemos con ritmo sano',
    'El respiro funcionó. Vamos con más calma',
  ];

  // Nivel 10: Todavía muy estresado (raro después de descanso)
  static final List<String> _veryHighStressMessages = [
    'El descanso fue un inicio. Cuídate hoy',
    'Has descansado, pero ve con calma ahora',
    'Mejor que antes. Trabaja sin presión',
    'El break ayudó algo. Ritmo tranquilo ahora',
    'Descansaste, ahora mantén la calma',
    'Ve despacio. El descanso fue solo el inicio',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getRandomMessage() {
    List<String> messages;

    if (widget.stressLevel <= 3) {
      messages = _lowStressMessages;
    } else if (widget.stressLevel <= 6) {
      messages = _mediumStressMessages;
    } else if (widget.stressLevel <= 9) {
      messages = _highStressMessages;
    } else {
      messages = _veryHighStressMessages;
    }

    messages.shuffle();
    return messages.first;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 24,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con animación
              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sentiment_very_satisfied_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mensaje motivador
              Text(
                _getRandomMessage(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Botón OK
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onOkPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    '¡Vamos!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
