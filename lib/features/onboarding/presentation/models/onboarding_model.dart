/// Modelo que representa un paso del onboarding
class OnboardingStep {
  final int id;
  final String title;
  final String description;
  final String icon;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
