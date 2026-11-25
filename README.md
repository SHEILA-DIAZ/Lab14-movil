# Laboratorio 14 de Programación de Móviles Avanzados

Aplicación iOS de Tecsup para registrar usuarios, iniciar y cerrar sesión con Firebase Authentication y compartir mensajes en tiempo real mediante Cloud Firestore.

## Tecnologías y estructura

El proyecto usa Swift, SwiftUI, Xcode 26.3 y el SDK de Firebase 12.14.0 mediante Swift Package Manager. El destino mínimo es iOS 17. El identificador de la app es `pe.edu.tecsup.dma.Lab14IntroFirebase`.

| Ruta | Contenido |
| --- | --- |
| `Lab14IntroFirebase.xcodeproj` | Proyecto de Xcode y dependencias de Firebase Core, Auth y Firestore |
| `Lab14IntroFirebase/Lab14IntroFirebaseApp.swift` | Punto de entrada e inicialización de Firebase |
| `Lab14IntroFirebase/ContentView.swift` | Vista raíz |
| `Lab14IntroFirebase/AuthView.swift` | Formulario, estado de sesión, alertas y estilos |
| `Lab14IntroFirebase/DatabaseService.swift` | Modelo de mensaje, escritura y suscripción a Cloud Firestore |
| `Lab14IntroFirebase/MessagesView.swift` | Historial y composición de mensajes |
| `firestore.rules` | Reglas para la colección `messages` |
| `evidencias/` | Capturas y registro de las comprobaciones |

El chat muestra los 100 mensajes más recientes, en orden cronológico. La marca temporal la asigna el servidor y las reglas verifican que el correo y UID correspondan a la sesión autenticada.

## Configuración de Firebase

La app usa el proyecto de laboratorio existente **App01-Lab14** (`app01-lab14-b254f`), con Cloud Firestore Standard, base `(default)` en `nam5` y Authentication mediante correo y contraseña.

1. En la configuración del proyecto existente, comprueba que esté registrada la app Apple con el bundle identifier indicado arriba.
2. En **Authentication → Sign-in method**, comprueba que **Email/Password** esté habilitado.
3. En **Firestore Database**, abre la base **(default)** y verifica que **Rules** coincida con `firestore.rules`. Cada usuario autenticado puede leer el chat y crear mensajes a su nombre.
4. Descarga `GoogleService-Info.plist` desde la configuración de la app Apple y guárdalo en `Lab14IntroFirebase/GoogleService-Info.plist`. Xcode incluye automáticamente el plist de la carpeta del target. Git lo excluye.
5. Abre `Lab14IntroFirebase.xcodeproj`, selecciona el esquema **Lab14IntroFirebase** y un simulador iOS. Espera a que Swift Package Manager resuelva las dependencias y ejecuta con **⌘R**.

[Configuración de Firebase para Apple](https://firebase.google.com/docs/ios/setup) · [Configuración de Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)

También puedes compilar desde la raíz del repositorio. Mantén la firma local que Xcode genera para el simulador, porque Firebase Authentication usa Keychain para persistir la sesión.

```sh
xcodebuild -project Lab14IntroFirebase.xcodeproj \
  -scheme Lab14IntroFirebase \
  -destination 'generic/platform=iOS Simulator' build
```

## Verificación

El registro de cada prueba y el vínculo a su evidencia se mantienen en [evidencias/README.md](evidencias/README.md). El registro incluye la prueba de suplantación de remitente y el resultado observado con las reglas publicadas.

Para comprobar la sesión, registra una cuenta de prueba, cierra y vuelve a abrir la app, cierra sesión y prueba una contraseña incorrecta antes de volver a entrar con las credenciales correctas. Para comprobar la mensajería, inicia sesión con dos cuentas de prueba en dos simuladores. Envía un mensaje desde cada dispositivo y verifica que el otro lo reciba sin recargar la vista. Contrasta los usuarios con la pestaña **Users** y los mensajes con el colección `messages` de **Firestore Database → Data**.
