# Kenwa - Salud y Armonía 🧘

Aplicación Flutter para monitoreo del bienestar, manejo del estrés y productividad mediante técnicas de mindfulness y cronometraje.

## 📋 Descripción

Kenwa es una aplicación multiplataforma que ofrece herramientas para mejorar la salud mental y productividad:

- **Temporizador**: Control de sesiones de trabajo/descanso
- **Monitor de estrés**: Seguimiento y análisis del nivel de estrés
- **Notificaciones**: Recordatorios y alertas personalizables
- **Sonidos**: Audios relajantes y alertas personalizadas
- **Ejecución en segundo plano**: Funcionalidad continua incluso cuando la app está minimizada

## 🚀 Requisitos

- Flutter 3.9.2 o superior
- Dart 3.9.2 o superior
- Android 13+ o iOS 11+

## 📦 Instalación

### 1. Clonar el repositorio
```bash
git clone <url-repositorio>
cd kenwa_app
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la aplicación
```bash
flutter run
```

Para dispositivos específicos:
```bash
flutter run -d <device-id>  # Android
flutter run -d macos        # macOS
flutter run -d windows      # Windows
flutter run -d linux        # Linux
```

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada
├── app/
│   ├── app.dart                   # Widget raíz
│   ├── router.dart                # Navegación (GoRouter)
│   └── theme/
│       ├── app_theme.dart         # Tema Material
│       └── app_colors.dart        # Paleta de colores
├── features/
│   ├── home/                      # Pantalla principal
│   ├── onboarding/                # Flujo de bienvenida
│   └── config/                    # Configuración de la app
├── services/
│   ├── timer_service.dart         # Gestión de temporizadores
│   ├── stress_service.dart        # Análisis de estrés
│   ├── notification_service.dart  # Notificaciones locales
│   ├── sound_service.dart         # Reproducción de audios
│   └── background_timer_service.dart  # Ejecución en segundo plano
└── assets/
    ├── images/                    # Iconos e imágenes
    └── sounds/                    # Audios y alertas
```

## 📱 Plataformas Soportadas

- ✅ Android (13+)
- ✅ iOS (11+)
- ✅ macOS
- ✅ Windows
- ✅ Linux
- ✅ Web

## 🔧 Dependencias Principales

| Paquete | Versión | Propósito |
|---------|---------|----------|
| `go_router` | 17.0.0 | Navegación y enrutamiento |
| `shared_preferences` | 2.5.3 | Almacenamiento local |
| `flutter_local_notifications` | 19.5.0 | Notificaciones |
| `audioplayers` | 6.5.1 | Reproducción de audio |
| `flutter_svg` | 2.2.2 | Renderizado de SVG |
| `flutter_background` | 1.3.0 | Ejecución en segundo plano |

## 🛠️ Desarrollo

### Ejecutar en modo debug
```bash
flutter run -d <device-id> --debug
```

### Build para producción
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Análisis de código
```bash
flutter analyze
```

### Formatear código
```bash
flutter format lib/
```
