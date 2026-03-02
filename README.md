# Verificador de Billetes Bolivia

Aplicación Flutter que permite verificar si un billete boliviano (Bs 10, 20 o 50) figura en la lista de billetes **sin valor legal** según el comunicado **CP9/2026** del Banco Central de Bolivia.

---

## Características

- **Escaneo OCR en tiempo real** — usa la cámara del dispositivo y Google ML Kit para leer el número de serie del billete automáticamente.
- **Entrada manual** — botón de teclado para ingresar la serie a mano cuando el escaneo no es posible.
- **Soporte para tres cortes** — Bs 10, Bs 20 y Bs 50, seleccionables con un pill animado.
- **Base de datos local (SQLite)** — los rangos de series inhabilitadas están embebidos en la app; no requiere conexión a internet para verificar.
- **UI oscura / verde** — diseño fiel al comunicado oficial, con marco de escaneo con esquinas animadas y línea de barrido.
- **Resultado instantáneo** — overlay de color rojo (inhabilitado), verde (válido) u naranja (error de lectura).
- **Contacto directo** — botón WhatsApp en la pantalla principal y diálogo "Acerca de" con iconos sociales (GitHub, LinkedIn, WhatsApp).

---

## Capturas de pantalla

> _Proximamente_

---

## Rangos inhabilitados (CP9/2026 BCB)

| Corte | Series incluidas |
|-------|-----------------|
| Bs 10 | Según anexo CP9/2026 |
| Bs 20 | Según anexo CP9/2026 |
| Bs 50 | Según anexo CP9/2026 |

Los rangos completos están codificados en `lib/src/services/database_helper.dart`.

---

## Arquitectura

```
lib/
├── main.dart                          # Entry point, Provider setup, orientación portrait
└── src/
    ├── services/
    │   └── database_helper.dart       # Singleton SQLite con rangos BCB, esBilleteAnulado()
    ├── repositories/
    │   └── bill_repository.dart       # Abstracción sobre DatabaseHelper
    └── features/
        └── scanner/
            ├── scanner_controller.dart  # ChangeNotifier — estados idle/scanning/anulado/valido/error
            ├── camera_handler.dart      # CameraController + TextRecognizer ML Kit
            └── scanner_page.dart        # UI completa (página única)
```

**Patrón de estado:** `Provider` + `ChangeNotifier` (`ScannerController`).  
**Base de datos:** `sqflite` — abierta una sola vez en el ciclo de vida de la app.  
**OCR:** `google_mlkit_text_recognition` — procesamiento en el dispositivo, sin envío de datos a la nube.

---

## Dependencias principales

| Paquete | Uso |
|---------|-----|
| `camera` | Acceso a la cámara del dispositivo |
| `google_mlkit_text_recognition` | OCR on-device para leer series |
| `sqflite` | Base de datos SQLite local con rangos inhabilitados |
| `provider` | Gestión de estado (ChangeNotifier) |
| `url_launcher` | Apertura de WhatsApp, LinkedIn y GitHub |
| `font_awesome_flutter` | Iconos oficiales de WhatsApp, LinkedIn y GitHub |
| `google_fonts` | Tipografía Inter |

---

## Requisitos

- Flutter SDK `>=3.11.0`
- Android: `minSdk` según `flutter.minSdkVersion`, compileSdk según `flutter.compileSdkVersion`
- iOS: requiere macOS + Xcode para compilar
- Permiso de **cámara** — solicitado en tiempo de ejecución (declarado en `AndroidManifest.xml` e `Info.plist`)

---

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Analizar / lints (debe retornar 0 issues)
flutter analyze

# Formatear código
dart format .

# Ejecutar tests (9 tests unitarios)
flutter test

# Ejecutar en dispositivo (debug)
flutter run -d <device-id>

# Compilar APK release
flutter build apk --release
# APK generado en: build/app/outputs/flutter-apk/app-release.apk

# Compilar App Bundle (Play Store)
flutter build appbundle
```

---

## Configuración Android

El archivo `android/app/proguard-rules.pro` contiene reglas R8 necesarias para el build release:

- Supresión de warnings de ML Kit (reconocedores opcionales: chino, japonés, coreano, devanagari).
- Supresión de warnings de Flutter Play Core deferred components (no usados en distribución directa).

El bloque `<queries>` en `AndroidManifest.xml` declara visibilidad de paquetes para Android 11+:

```xml
<queries>
    <!-- url_launcher: abrir HTTPS en browser -->
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="https"/>
    </intent>
    <!-- WhatsApp nativo -->
    <package android:name="com.whatsapp"/>
    <package android:name="com.whatsapp.w4b"/>
</queries>
```

---

## Tests

```bash
flutter test
# 9 tests — todos pasando
```

Los tests cubren:
- Inserción y consulta de rangos inhabilitados en SQLite (FFI).
- `esBilleteAnulado()` para series dentro y fuera del rango.
- Casos límite (serie en el borde del rango, corte inexistente).

Usan `sqflite_common_ffi` para correr SQLite en el host sin necesidad de emulador.

---

## Autor

**Miguel Angel Zenteno Orellana**

- GitHub: [SudoCode76](https://github.com/SudoCode76)
- LinkedIn: [miguel-zenteno](https://www.linkedin.com/in/miguel-zenteno/)
- WhatsApp: [+591 62994685](https://wa.me/59162994685)

---

## Licencia

Uso personal / demostrativo. Los rangos de series inhabilitadas son de dominio público (comunicado oficial del BCB).
