# kenwa_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
│
├── main.dart                # Punto de entrada principal
├── app/                     # Configuración global
│   ├── app.dart             # Widget raíz con MaterialApp
│   ├── router.dart          # Rutas de navegación (GoRouter o Navigator)
│   └── theme/               # Colores, tipografías, estilos globales
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── core/                    # Código común reutilizable (sin lógica de negocio)
│   ├── utils/               # Funciones helper, formatters, etc.
│   ├── widgets/             # Widgets genéricos (botones, loaders, etc.)
│   └── services/            # Servicios compartidos (notificaciones, almacenamiento)
│
├── features/                # Cada módulo o “feature” separado
│   ├── pomodoro/
│   │   ├── data/            # Fuentes de datos, repositorios, modelos
│   │   │   ├── pomodoro_model.dart
│   │   │   └── pomodoro_repository.dart
│   │   ├── logic/           # Controladores, blocs, providers
│   │   │   └── pomodoro_controller.dart
│   │   ├── ui/              # Pantallas y widgets específicos del pomodoro
│   │   │   ├── pomodoro_page.dart
│   │   │   └── widgets/
│   │   │       └── timer_display.dart
│   │   └── pomodoro.dart    # Archivo de exportación central del módulo
│   │
│   ├── stress_meter/
│   │   ├── data/
│   │   │   └── stress_model.dart
│   │   ├── logic/
│   │   │   └── stress_controller.dart
│   │   ├── ui/
│   │   │   └── stress_widget.dart
│   │   └── stress_meter.dart
│   │
│   └── settings/            # (opcional) Configuración, preferencias del usuario
│       ├── data/
│       ├── ui/
│       └── logic/
│
└── l10n/                    # Localización (si usas varios idiomas)
