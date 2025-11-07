import 'package:flutter/material.dart';

/// Widget para seleccionar el nivel de estrés inicial
class NivelEstresSelector extends StatefulWidget {
  final String label;
  final String subLabel;
  final int initialLevel;
  final Function(int) onLevelChanged;

  const NivelEstresSelector({
    super.key,
    required this.label,
    required this.subLabel,
    required this.initialLevel,
    required this.onLevelChanged,
  });

  @override
  State<NivelEstresSelector> createState() => _NivelEstresSelectorState();
}

class _NivelEstresSelectorState extends State<NivelEstresSelector> {
  late int _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
  }

  String _getNivelLabel(int level) {
    switch (level) {
      case 1:
        return 'Bajo';
      case 2:
        return 'Moderado';
      case 3:
        return 'Alto';
      case 4:
        return 'Muy Alto';
      default:
        return '';
    }
  }

  String _getNivelEmoji(int level) {
    switch (level) {
      case 1:
        return '☺️';
      case 2:
        return '😐';
      case 3:
        return '😨';
      case 4:
        return '😡';
      default:
        return '☺️';
    }
  }

  Color _getNivelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          widget.subLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final level = index + 1;
            final isSelected = _selectedLevel == level;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level;
                      widget.onLevelChanged(_selectedLevel);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getNivelColor(level).withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? _getNivelColor(level)
                            : Colors.grey.withValues(alpha: 0.25),
                        width: isSelected ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getNivelEmoji(level),
                          style: const TextStyle(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getNivelLabel(level),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? _getNivelColor(level)
                                : Colors.grey.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
