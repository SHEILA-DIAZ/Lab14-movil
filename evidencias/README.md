# Evidencias y resultados

Xcode 26.3, Swift 6.2.4, Firebase SDK 12.14.0 e iPhone 17 Pro simulado con iOS 26.3. Las cuentas de prueba usan direcciones de ejemplo. Las capturas del simulador están en el informe del laboratorio.

| Comprobación | Resultado observado |
| --- | --- |
| Proyecto, dependencias y compilación | Xcode abrió el proyecto. `xcodebuild` compiló y firmó localmente la app con FirebaseCore, FirebaseAuth y FirebaseFirestore. [Extracto de compilación](02-compilacion.txt) |
| Inclusión del plist e inicialización | Xcode copió el plist de `app01-lab14-b254f` al producto. La app arrancó y mostró el formulario conectado. |
| Validación de campos | La app mostró la alerta al intentar entrar con los campos vacíos. |
| Registro con email y contraseña | Firebase Auth creó una cuenta de prueba desde el simulador. |
| Persistencia | La app recuperó la sesión tras terminar el proceso y relanzarlo. |
| Cierre de sesión | La app volvió al formulario y mostró la confirmación. |
| Contraseña incorrecta | Firebase Auth rechazó las credenciales. |
| Inicio de sesión | La app volvió a iniciar sesión con la contraseña correcta. |
| Chat con dos cuentas en iOS | La cuenta A envió un mensaje y la cuenta B lo recibió al iniciar su sesión. B envió su respuesta y la app mostró ambos correos de prueba. El campo se vació tras cada escritura confirmada. |
| Escritura, lectura cruzada y remitente en Cloud Firestore | Dos cuentas autenticadas crearon mensajes con su propio correo y UID. Cada cuenta leyó el mensaje de la otra por REST y se verificaron ambos campos contra Authentication. [Resultados del servidor](12-firestore-servidor.txt) |
| Reglas publicadas de Cloud Firestore | Con la versión publicada de `firestore.rules`, el servidor rechazó lecturas anónimas, modificaciones, eliminaciones y escrituras con el correo o UID de otra cuenta (HTTP 403). La publicación corrigió la aceptación de un correo ajeno detectada en la primera prueba. [Resultados del servidor](12-firestore-servidor.txt) |

La corresponde a la primera compilación, antes de incorporar el plist. El primer intento de registro en el simulador detectó un error de Keychain en el producto sin firma. La compilación firmada pasó todas las pruebas de Authentication.
