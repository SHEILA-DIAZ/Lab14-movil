# Respuestas del Laboratorio 14

## Actividad 01

### ¿Para qué sirve cada uno de los paquetes?

| Producto del SDK de Firebase | Finalidad |
| --- | --- |
| `FirebaseAuth` | Registra e identifica usuarios. En este laboratorio gestiona el acceso con correo y contraseña y conserva la sesión entre aperturas. |
| `FirebaseCore` | Carga las opciones del proyecto y crea la instancia de Firebase que comparten los demás servicios. |
| `FirebaseDatabase` | Lee y escribe en Realtime Database, un árbol JSON que sincroniza cambios mediante observadores. |
| `FirebaseFirestore` | Accede a Cloud Firestore, que organiza datos en colecciones y documentos y admite consultas y escuchas en tiempo real. La guía lo señala en la captura de dependencias y lo utiliza en el ejemplo de mensajería. La aplicación usa este producto para el chat. |

La guía también menciona Google Analytics durante el asistente de configuración. `FirebaseAnalytics` registra eventos de uso y genera métricas. Su variante histórica sin IDFA evita incorporar la capacidad de recopilar ese identificador publicitario. [Configuración del SDK para Apple](https://firebase.google.com/docs/ios/setup)

### ¿Cuál es la finalidad de FirebaseApp.configure()?

Inicializa la instancia predeterminada de Firebase con las opciones de `GoogleService-Info.plist`. Esa instancia permite que Auth y Cloud Firestore se conecten al proyecto registrado. La aplicación ejecuta la configuración al arrancar y verifica que el identificador del plist corresponda al del target. [Inicialización de Firebase](https://firebase.google.com/docs/ios/setup#initialize_firebase_in_your_app)

### ¿Cuáles son los métodos principales de Auth.auth() usados en AuthView.swift?

- `signIn(withEmail:password:)` verifica las credenciales e inicia la sesión.
- `createUser(withEmail:password:)` registra una cuenta e inicia su sesión al completar el registro.
- `signOut()` cierra la sesión local y puede lanzar un error.
- `addStateDidChangeListener(_:)` informa el estado inicial y los cambios de sesión. `checkAuthState()` lo registra para decidir qué vista mostrar.
- `removeStateDidChangeListener(_:)` retira el observador cuando la vista desaparece.

[Documentación de Firebase Authentication](https://firebase.google.com/docs/auth/ios/start)

## Actividad 02

### ¿Cuál es la ventaja de usar Firebase Database?

Realtime Database entrega el estado inicial y sincroniza los cambios posteriores entre clientes conectados. Cloud Firestore ofrece esa misma actualización mediante listeners de consultas, que el chat usa para observar los mensajes más recientes. Las reglas de seguridad permiten limitar las lecturas a usuarios autenticados y vincular cada mensaje con el usuario que lo escribió. [Lectura y escritura en Realtime Database](https://firebase.google.com/docs/database/ios/read-and-write)

### ¿Qué tres servicios adicionales de Firebase se podrían usar en el proyecto?

1. **Cloud Messaging** para notificar sobre mensajes nuevos cuando la app esté en segundo plano.
2. **Cloud Storage for Firebase** para guardar archivos adjuntos con permisos vinculados a la sesión.
3. **Crashlytics** para identificar fallos de ejecución con diagnósticos agrupados por versión y dispositivo.

## Conclusiones

1. Comprendí que el estado que informa Firebase Authentication debe dirigir la navegación para que la interfaz responda tanto al inicio de sesión como al cierre y a la restauración de una sesión.
2. Aprendí a usar un listener de Cloud Firestore para actualizar el historial del chat y a retirarlo cuando la vista deja de mostrarse.
3. Entendí que validar en SwiftUI mejora la respuesta al usuario, mientras que las reglas de Cloud Firestore son las que aplican los permisos y verifican la identidad del autor en el servidor.
