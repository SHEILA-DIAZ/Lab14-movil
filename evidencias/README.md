# Evidencias y resultados

Pruebas ejecutadas en macOS con Xcode 26.3, Swift 6.2.4 y un iPhone 17 Pro simulado con iOS 26.3.

| Comprobación | Resultado observado |
| --- | --- |
| Proyecto y dependencias | Xcode abrió `Lab14IntroFirebase.xcodeproj` y mostró Firebase 12.14.0 en Package Dependencies. Core, Auth y Database figuran en el [extracto de xcodebuild](02-compilacion.txt). |
| Compilación para iOS Simulator | `BUILD SUCCEEDED` en [xcodebuild](02-compilacion.txt). |
| Instalación, arranque y formulario | `simctl` instaló y lanzó la app. El [formulario de autenticación](01-autenticacion.png) muestra el estado previo a incorporar el plist del proyecto. |
| Registro y verificación en Authentication | Pendiente de configuración de Firebase. |
| Inicio de sesión, credenciales incorrectas y cierre | Pendiente de configuración de Firebase. |
| Persistencia al relanzar la app | Pendiente de configuración de Firebase. |
| Mensajería con dos usuarios y verificación en Realtime Database | Pendiente de configuración de Firebase. |
