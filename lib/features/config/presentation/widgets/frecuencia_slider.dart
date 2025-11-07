import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Widget para seleccionar la frecuencia de descansos mediante un slider
class FrecuenciaSlider extends StatefulWidget {
  final String label;
  final String subLabel;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int) onValueChanged;
  final String unit;

  const FrecuenciaSlider({
    super.key,
    required this.label,
    required this.subLabel,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
    required this.unit,
  });

  @override
  State<FrecuenciaSlider> createState() => _FrecuenciaSliderState();
}

class _FrecuenciaSliderState extends State<FrecuenciaSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.foreground.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_currentValue ${widget.unit}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: _currentValue.toDouble(),
          min: widget.minValue.toDouble(),
          max: widget.maxValue.toDouble(),
          divisions: widget.maxValue - widget.minValue,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.foreground.withValues(alpha: 0.15),
          label: '$_currentValue ${widget.unit}',
          onChanged: (value) {
            setState(() {
              _currentValue = value.toInt();
              widget.onValueChanged(_currentValue);
            });
          },
        ),
      ],
    );
  }
}
