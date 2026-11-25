# Laboratorio 14 de Programación de Móviles Avanzados

Aplicación iOS de Tecsup para registrar usuarios, iniciar y cerrar sesión con Firebase Authentication y compartir mensajes en tiempo real mediante Firebase Realtime Database.

## Tecnologías y estructura

El proyecto usa Swift, SwiftUI, Xcode 26.3 y el SDK de Firebase 12.14.0 mediante Swift Package Manager. El destino mínimo es iOS 17. El identificador de la app es `pe.edu.tecsup.dma.Lab14IntroFirebase`.

| Ruta | Contenido |
| --- | --- |
| `Lab14IntroFirebase.xcodeproj` | Proyecto de Xcode y dependencias de Firebase Core, Auth y Database |
| `Lab14IntroFirebase/Lab14IntroFirebaseApp.swift` | Punto de entrada e inicialización de Firebase |
| `Lab14IntroFirebase/ContentView.swift` | Vista raíz |
| `Lab14IntroFirebase/AuthView.swift` | Formulario, estado de sesión, alertas y estilos |
| `Lab14IntroFirebase/DatabaseService.swift` | Modelo de mensaje, escritura y suscripción a Realtime Database |
| `Lab14IntroFirebase/MessagesView.swift` | Historial y composición de mensajes |
| `database.rules.json` | Reglas e índice para el nodo `/messages` |
| `RESPUESTAS-LAB14.md` | Preguntas y conclusiones de la guía |
| `evidencias/` | Capturas y registro de las comprobaciones |

El ejemplo ilustrado en la Actividad 02 utiliza Cloud Firestore. Para la entrega se conserva la interfaz y se implementa la mensajería con Realtime Database. El chat muestra los 100 mensajes más recientes, en orden cronológico. La marca temporal la asigna el servidor y las reglas verifican que el correo y UID correspondan a la sesión autenticada.

## Configuración de Firebase

1. En la consola de Firebase, crea el proyecto **App01-Lab14** con tu cuenta de Tecsup y registra una aplicación Apple con el bundle identifier indicado arriba.
2. En **Authentication → Sign-in method**, habilita **Email/Password**.
3. En **Realtime Database**, crea una instancia en modo bloqueado. En **Rules**, pega el contenido de `database.rules.json` y publícalo. El acceso anónimo queda denegado y cada usuario puede crear mensajes a su nombre.
4. Descarga `GoogleService-Info.plist` desde la configuración de la app Apple y guarda el archivo en `Lab14IntroFirebase/GoogleService-Info.plist`. Verifica que incluya `DATABASE_URL`. Si falta, vuelve a descargar el plist tras crear la base o agrega localmente esa clave con la URL que aparece en la consola de Realtime Database. Xcode incluye automáticamente el plist de la carpeta del target. Git lo excluye.
5. Abre `Lab14IntroFirebase.xcodeproj`, selecciona el esquema **Lab14IntroFirebase** y un simulador iOS. Espera a que Swift Package Manager resuelva las dependencias y ejecuta con **⌘R**.

[Configuración de Firebase para Apple](https://firebase.google.com/docs/ios/setup) · [Configuración de Realtime Database](https://firebase.google.com/docs/database/ios/start)

También puedes compilar desde la raíz del repositorio.

```sh
xcodebuild -project Lab14IntroFirebase.xcodeproj \
  -scheme Lab14IntroFirebase \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## Verificación

El registro de cada prueba y el vínculo a su evidencia se mantienen en [evidencias/README.md](evidencias/README.md). Las comprobaciones de integración requieren el proyecto Firebase de Tecsup, Email/Password habilitado y las reglas publicadas.

Para comprobar la sesión, registra una cuenta de prueba, cierra y vuelve a abrir la app, cierra sesión y prueba una contraseña incorrecta antes de volver a entrar con las credenciales correctas. Para comprobar la mensajería, inicia sesión con dos cuentas de prueba en dos simuladores. Envía un mensaje desde cada dispositivo y verifica que el otro lo reciba sin recargar la vista. Contrasta los usuarios con la pestaña **Users** y los mensajes con el nodo `/messages` de **Realtime Database → Data**.
