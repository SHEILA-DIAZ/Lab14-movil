# Evidencias y resultados

Xcode 26.3, Swift 6.2.4, Firebase SDK 12.14.0 e iPhone 17 Pro simulado con iOS 26.3. Las cuentas de prueba usan direcciones de ejemplo.

| Comprobación | Resultado observado |
| --- | --- |
| Proyecto, dependencias y compilación | Xcode abrió el proyecto. `xcodebuild` compiló y firmó localmente la app con FirebaseCore, FirebaseAuth y FirebaseFirestore. [Extracto de compilación](02-compilacion.txt) |
| Inclusión del plist e inicialización | Xcode copió el plist de `app01-lab14-b254f` al producto. La app arrancó y mostró el formulario conectado. [Captura](03-firebase-configurado.png) |
| Validación de campos | La app mostró la alerta al intentar entrar con los campos vacíos. [Captura](04-validacion-campos.png) |
| Registro con email y contraseña | Firebase Auth creó una cuenta de prueba desde el simulador. [Captura](05-registro.png) |
| Persistencia | La app recuperó la sesión tras terminar el proceso y relanzarlo. [Captura](06-sesion-restaurada.png) |
| Cierre de sesión | La app volvió al formulario y mostró la confirmación. [Captura](07-cierre.png) |
| Contraseña incorrecta | Firebase Auth rechazó las credenciales. [Captura](08-credenciales-incorrectas.png) |
| Inicio de sesión | La app volvió a iniciar sesión con la contraseña correcta. [Captura](09-inicio.png) |
| Chat con dos cuentas en iOS | La cuenta A envió un mensaje y la cuenta B lo recibió al iniciar su sesión. B envió su respuesta y la app mostró ambos correos de prueba. El campo se vació tras cada escritura confirmada. [Envío de A](10-mensaje-usuario-a.png) · [Conversación desde B](11-mensajes-dos-usuarios.png) |
| Escritura, lectura cruzada y remitente en Cloud Firestore | Dos cuentas autenticadas crearon mensajes con su propio correo y UID. Cada cuenta leyó el mensaje de la otra por REST y se verificaron ambos campos contra Authentication. [Resultados del servidor](12-firestore-servidor.txt) |
| Reglas publicadas de Cloud Firestore | El servidor rechazó lecturas anónimas, modificaciones y eliminaciones. Aceptó una escritura con el correo de otra cuenta. `firestore.rules` comprueba correo y UID contra el token y queda pendiente verificar esa versión publicada. [Resultados del servidor](12-firestore-servidor.txt) |

La [captura inicial](01-autenticacion.png) corresponde a la primera compilación, antes de incorporar el plist. El primer intento de registro en el simulador detectó un error de Keychain en el producto sin firma. La compilación firmada pasó todas las pruebas de Authentication.
