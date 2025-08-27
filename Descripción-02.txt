Queremos desarrollar una aplicación de software llamada CONECTA, que funcionará como un API Gateway centralizado para nuestra organización. El objetivo principal es simplificar y securizar la comunicación entre nuestros servicios internos y sistemas externos. Actualmente, todo el tráfico de red, tanto entrante como saliente, debe pasar a través de un sistema IBM Datapower por motivos de seguridad. CONECTA se posicionará como el único punto de entrada y salida, eliminando la necesidad de configurar múltiples conexiones directas en Datapower y centralizando la gestión del tráfico.

# Funcionalidades Clave Requeridas:

1. Enrutamiento Dinámico:

    - Enrutar las peticiones entrantes de sistemas externos al servicio interno correspondiente utilizando un segmento específico de la URL como clave de enrutamiento.

2. Gestión de Autenticación y Seguridad:

    - Tráfico Entrante: Validar un token JWT en las peticiones de los sistemas externos. La petición solo se reenviará al servicio interno si la validación del token es exitosa.
    - Tráfico Saliente: Cuando un servicio interno realice una petición a un sistema externo a través de CONECTA, este deberá añadir el token JWT requerido por el sistema externo. No se requerirá autenticación para los servicios internos que se comunican con CONECTA.

3. Auditoría y Trazabilidad:

    - Registrar y almacenar trazas de auditoría completas para cada transacción. Esto debe incluir el mensaje de la petición original y la respuesta recibida del servicio interno.

4. Transaccionalidad:

    - Asegurar que todas las operaciones de enrutamiento y reenvío de mensajes se gestionen de manera transaccional para garantizar la integridad de los datos.

5. Configurabilidad y Escalabilidad:

    - El sistema debe ser altamente configurable para permitir la adición o modificación de nuevos servicios internos y sistemas externos sin necesidad de redesplegar la aplicación.
    - La arquitectura debe estar diseñada para soportar un alto volumen de peticiones concurrentes y garantizar la alta disponibilidad del servicio.

6. Interfaz de Usuario (UI):

    - Desarrollar una interfaz web para que los administradores puedan consultar los logs de auditoría de las peticiones.
    - La UI también permitirá gestionar la configuración del enrutamiento y los endpoints.

7. Stack Tecnológico:

    - Frontend: Angular 18
    - Backend: Spring Boot
