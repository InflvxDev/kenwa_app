import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';

/// Widget para seleccionar la hora de inicio/fin
class HorarioInput extends StatefulWidget {
  final String label;
  final HoraDelDia initialTime;
  final Function(HoraDelDia) onTimeChanged;

  const HorarioInput({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<HorarioInput> createState() => _HorarioInputState();
}

class _HorarioInputState extends State<HorarioInput> {
  late HoraDelDia _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _selectTime() async {
    // Simulamos el selector de hora (Flutter no tiene TimeOfDay picker nativo)
    showDialog(
      context: context,
      builder: (context) {
        int hour = _selectedTime.hour;
        int minute = _selectedTime.minute;

        return AlertDialog(
          title: Text(widget.label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hora
                  SizedBox(
                    width: 70,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '00',
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                      maxLength: 2,
                      controller: TextEditingController(
                        text: hour.toString().padLeft(2, '0'),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          hour = int.tryParse(value) ?? hour;
                          if (hour > 23) hour = 23;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(':', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  // Minuto
                  SizedBox(
                    width: 70,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '00',
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                      maxLength: 2,
                      controller: TextEditingController(
                        text: minute.toString().padLeft(2, '0'),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          minute = int.tryParse(value) ?? minute;
                          if (minute > 59) minute = 59;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTime = HoraDelDia(hour: hour, minute: minute);
                  widget.onTimeChanged(_selectedTime);
                });
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.foreground.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Icon(
                  Icons.access_time,
                  color: AppColors.foreground.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
