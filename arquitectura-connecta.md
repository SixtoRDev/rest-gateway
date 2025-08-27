Arquitectura de la Aplicación CONECTA
Este documento detalla la arquitectura propuesta para la aplicación CONECTA, un API Gateway centralizado diseñado para simplificar y securizar la comunicación entre servicios internos y sistemas externos.

1. Entendimiento de la Aplicación
La aplicación CONECTA funcionará como un API Gateway centralizado, cuyo propósito principal es simplificar y securizar la comunicación entre los servicios internos de la organización y los sistemas externos. Se posicionará como el único punto de entrada y salida entre el sistema IBM DataPower existente y los sistemas internos, centralizando la gestión del tráfico y eliminando la necesidad de múltiples configuraciones directas en DataPower.

Para un diseño arquitectónico completo, se han considerado las siguientes aclaraciones:

Formato de Tokens JWT: CONECTA será responsable de la validación de tokens JWT entrantes y de la adición de tokens JWT salientes, asumiendo que los tokens se adhieren a estándares como JWS (JSON Web Signature). No se contempla la generación de tokens JWT por parte de CONECTA, sino su gestión y reenvío.

Formato de Mensajes de Auditoría: Los mensajes de auditoría incluirán el mensaje de la petición original y la respuesta recibida, junto con metadatos como el timestamp, ID de transacción, método HTTP, URL, cabeceras, estado de respuesta y duración.

Estrategia de Alta Disponibilidad y Escalabilidad: Se propone una arquitectura basada en microservicios (Spring Boot es compatible) y se asume un despliegue en entornos de contenedores (Docker/Kubernetes) para facilitar la escalabilidad horizontal y la alta disponibilidad.

Base de Datos: Se ha confirmado el uso de H2 para desarrollo y Oracle para preproducción y producción, para almacenar la configuración de enrutamiento y los logs de auditoría.

Requisitos de Rendimiento: Se priorizará la baja latencia en el enrutamiento y la validación de tokens, aprovechando las capacidades no bloqueantes de Spring WebFlux y la eficiencia de Spring Cloud Gateway.

2. Análisis de Requisitos (MoSCoW)
Must-have (Obligatorios)
Enrutamiento Dinámico: Función principal del API Gateway.

Gestión de Autenticación y Seguridad (Tráfico Entrante): Validación de tokens JWT para seguridad.

Gestión de Autenticación y Seguridad (Tráfico Saliente): Adición de tokens JWT para comunicación con sistemas externos.

Auditoría y Trazabilidad: Registro completo de transacciones para depuración y cumplimiento.

Transaccionalidad: Garantía de integridad en operaciones de enrutamiento y reenvío.

Configurabilidad: Adición/modificación de servicios sin redespliegue, esencial para la agilidad.

Escalabilidad: Soporte para alto volumen de peticiones y alta disponibilidad.

Interfaz de Usuario (UI) - Acceso Restringido: Gestión de la aplicación a través de una UI.

UI - Roles (Administrador y Auditor): Segregación de roles para seguridad y control.

UI - Consulta de Logs de Auditoría (Auditor): Monitoreo del tráfico y operaciones.

UI - Gestión de Configuración (Administrador): Gestión de enrutamiento, endpoints y usuarios.

Auditoría de Acciones de Gestión: Registro de quién realiza qué acción en la UI para trazabilidad y seguridad.

Borrado Lógico: Mantener la información de los elementos borrados en la base de datos para auditoría y recuperación.

Should-have (Deseables)
Personalización del Enrutamiento: Reglas de enrutamiento más complejas (ej., basadas en cabeceras HTTP, métodos).

Métricas y Monitoreo Detallado: Recopilación de métricas de rendimiento y estado.

Could-have (Opcionales)
Caché de Respuestas: Almacenar en caché respuestas para mejorar el rendimiento.

Transformación de Mensajes: Capacidad para transformar formatos de mensajes.

Limitación de Tasas (Rate Limiting): Controlar la cantidad de peticiones por cliente.

Won't-have (No se incluirán)
Funcionalidades de Orquestación de Servicios: No es un motor de orquestación.

Sistema de Notificaciones Avanzado: No se contempla un sistema de notificación en tiempo real.

3. Descomposición del Sistema
El sistema CONECTA se descompone en los siguientes módulos principales:

@startuml
package "CONECTA API Gateway" {
  [Frontend (Angular)] as Frontend
  [Backend (Spring Boot)] as Backend
  [Base de Datos] as DB
  [Servicios Internos] as InternalServices
  [Sistemas Externos] as ExternalSystems
  [IBM DataPower] as Datapower

  Frontend -- Backend : API REST
  Backend -- DB : JDBC
  Backend -- InternalServices : Enrutamiento y Reenvío
  Backend -- ExternalSystems : Enrutamiento y Reenvío
  Datapower -- Frontend : Acceso UI
  Datapower -- Backend : Tráfico del Gateway
}
@enduml

Módulos Principales:

Frontend (Angular): Interfaz de Usuario para administración y consulta.

Backend (Spring Boot): Núcleo del API Gateway, gestiona enrutamiento, seguridad (JWT), auditoría, configuración y comunicación. Utilizará Spring Cloud Gateway.

Base de Datos (H2/Oracle): Almacena configuración y logs de auditoría.

Servicios Internos: Aplicaciones de la organización protegidas por CONECTA.

Sistemas Externos: Sistemas de terceros con los que CONECTA facilita la comunicación.

IBM DataPower: Sistema de seguridad perimetral existente que se conecta con CONECTA.

4. Diseño de Dominio y Flujo de Información
Objetos de Dominio Clave
Clase Ruta
@startuml
class Ruta {
  - id: Long
  - segmentoUrl: String
  - servicioDestino: String
  - esActiva: Boolean
  - fechaCreacion: LocalDateTime
  - fechaModificacion: LocalDateTime
  - usuarioCreacion: String
  - usuarioModificacion: String
  - borradoLogico: Boolean
  + crearRuta(segmento: String, destino: String)
  + actualizarRuta(segmento: String, destino: String, activa: Boolean)
  + desactivarRuta()
}
@enduml

Clase Endpoint
@startuml
class Endpoint {
  - id: Long
  - nombre: String
  - urlBase: String
  - tipo: String // INTERNO, EXTERNO
  - requiereJwtSalida: Boolean
  - jwtConfiguracion: String // JSON con detalles para JWT saliente
  - fechaCreacion: LocalDateTime
  - fechaModificacion: LocalDateTime
  - usuarioCreacion: String
  - usuarioModificacion: String
  - borradoLogico: Boolean
  + crearEndpoint(nombre: String, url: String, tipo: String)
  + actualizarEndpoint(url: String, requiereJwt: Boolean)
  + desactivarEndpoint()
}
@enduml

Clase Usuario
@startuml
class Usuario {
  - id: Long
  - nombreUsuario: String
  - passwordHash: String
  - rol: String // ADMINISTRADOR, AUDITOR
  - fechaCreacion: LocalDateTime
  - fechaModificacion: LocalDateTime
  - usuarioCreacion: String
  - usuarioModificacion: String
  - borradoLogico: Boolean
  + crearUsuario(nombre: String, pass: String, rol: String)
  + actualizarUsuario(pass: String, rol: String)
  + desactivarUsuario()
}
@enduml

Clase AuditoriaGateway
@startuml
class AuditoriaGateway {
  - id: Long
  - timestamp: LocalDateTime
  - idTransaccion: String
  - metodoHttp: String
  - urlPeticion: String
  - headersPeticion: String
  - bodyPeticion: String
  - statusRespuesta: Integer
  - headersRespuesta: String
  - bodyRespuesta: String
  - duracionMs: Long
  - resultado: String // EXITO, FALLO_AUTENTICACION, FALLO_ENRUTAMIENTO, ERROR_INTERNO
  + registrarEntrada(idTx: String, method: String, url: String, headers: String, body: String)
  + registrarSalida(status: Integer, headers: String, body: String, duracion: Long, resultado: String)
}
@enduml

Clase AuditoriaGestion
@startuml
class AuditoriaGestion {
  - id: Long
  - timestamp: LocalDateTime
  - usuario: String
  - tipoAccion: String // ALTA, BAJA, MODIFICACION
  - entidadAfectada: String // RUTA, ENDPOINT, USUARIO
  - idEntidadAfectada: Long
  - detalles: String // JSON con cambios realizados
  + registrarAccion(usuario: String, tipo: String, entidad: String, idEntidad: Long, detalles: String)
}
@enduml

Flujo de Información
Flujo de Petición Entrante (Tráfico Gateway)
@startuml
skinparam handwritten true
skinparam style strict

actor "Sistema Externo" as ExternalSystem
boundary "IBM DataPower" as Datapower
control "CONECTA Backend" as CONECTABackend
entity "Servicios Internos" as InternalServices
database "Base de Datos (Configuración)" as ConfigDB
database "Base de Datos (Auditoría)" as AuditDB

ExternalSystem -[#red]> Datapower : Petición HTTP/S
Datapower -[#red]> CONECTABackend : Petición HTTP/S (Proxy)

CONECTABackend --> ConfigDB : 1. Consultar Reglas de Enrutamiento
CONECTABackend --> CONECTABackend : 2. Validar JWT (Petición Entrante)
alt JWT Válido
  CONECTABackend -> AuditDB : 3. Registrar Inicio Auditoría
  CONECTABackend -[#green]> InternalServices : 4. Reenviar Petición
  InternalServices -[#green]-> CONECTABackend : 5. Respuesta
  CONECTABackend -> AuditDB : 6. Registrar Fin Auditoría y Respuesta
  CONECTABackend -[#red]-> Datapower : 7. Enviar Respuesta
else JWT Inválido
  CONECTABackend -> AuditDB : 3. Registrar Fallo Autenticación
  CONECTABackend -[#red]-> Datapower : 7. Enviar Error (401 Unauthorized)
end
Datapower -[#red]-> ExternalSystem : 8. Enviar Respuesta/Error
@enduml

Flujo de Petición Saliente (Tráfico Gateway)
@startuml
skinparam handwritten true
skinparam style strict

entity "Servicio Interno" as InternalService
control "CONECTA Backend" as CONECTABackend
boundary "IBM DataPower" as Datapower
actor "Sistema Externo" as ExternalSystem
database "Base de Datos (Configuración)" as ConfigDB
database "Base de Datos (Auditoría)" as AuditDB

InternalService -[#blue]> CONECTABackend : Petición HTTP/S (Sin Auth)

CONECTABackend --> ConfigDB : 1. Consultar Config. Endpoint Externo
CONECTABackend --> CONECTABackend : 2. Añadir JWT (Petición Saliente)
CONECTABackend -> AuditDB : 3. Registrar Inicio Auditoría
CONECTABackend -[#red]> Datapower : 4. Reenviar Petición
Datapower -[#red]> ExternalSystem : 5. Petición HTTP/S (Proxy)
ExternalSystem -[#red]-> Datapower : 6. Respuesta
Datapower -[#red]-> CONECTABackend : 7. Respuesta
CONECTABackend -> AuditDB : 8. Registrar Fin Auditoría y Respuesta
CONECTABackend -[#blue]-> InternalService : 9. Enviar Respuesta
@enduml

Flujo de Interacción UI (Administración/Auditoría)
@startuml
skinparam handwritten true
skinparam style strict

actor UsuarioUI as User
participant "CONECTA Frontend (Angular)" as Frontend
participant "CONECTA Backend (Spring Boot)" as Backend
database "Base de Datos (Configuración)" as ConfigDB
database "Base de Datos (Auditoría)" as AuditDB

User -[#blue]> Frontend : Acceso a UI (Login)
Frontend -[#blue]> Backend : 1. Autenticación (Usuario/Contraseña)
Backend -> ConfigDB : 1.1. Validar Credenciales y Rol
Backend -[#blue]-> Frontend : 1.2. Respuesta de Autenticación

alt Rol: Administrador
  Frontend -[#green]> Backend : 2. Gestionar Configuración (Rutas, Endpoints, Usuarios)
  Backend -> ConfigDB : 2.1. CRUD en Configuración
  Backend -> AuditDB : 2.2. Registrar Auditoría de Gestión
  Backend -[#green]-> Frontend : 2.3. Confirmación / Datos
else Rol: Auditor
  Frontend -[#purple]> Backend : 2. Consultar Logs de Auditoría
  Backend -> AuditDB : 2.1. Consultar Registros de Auditoría
  Backend -> AuditDB : 2.2. Registrar Auditoría de Gestión (Consulta)
  Backend -[#purple]-> Frontend : 2.3. Resultados de Logs
end
@enduml

5. Consideraciones Tecnológicas
El diseño está alineado con una arquitectura de Frontend en Angular y Backend en Java Spring Boot, utilizando Spring Cloud Gateway.

Decisiones de Diseño por Pila Tecnológica:
APIs REST entre Frontend y Backend: Comunicación principal a través de APIs RESTful para una arquitectura desacoplada.

Spring Cloud Gateway: Elección clave para implementar enrutamiento dinámico, filtros de seguridad (validación JWT) y auditoría en el backend.

Módulos de Spring Framework: Uso de Spring Security para autenticación y JWT, Spring Data JPA para persistencia de datos (H2/Oracle), Spring WebFlux para manejo no bloqueante de peticiones, y Spring Boot Actuator para monitoreo.

JSON como formato de Intercambio: Uso de JSON para APIs REST y almacenamiento de datos semi-estructurados.

Gestión de Transacciones: Uso de @Transactional en Spring Boot para operaciones de persistencia y patrones de compensación/reintentos para fallos de comunicación.

Manejo de Errores Centralizado: Implementación de un manejo de excepciones centralizado para respuestas de error consistentes.

Ficheros de Configuración
Se utilizarán perfiles de Spring Boot para la configuración específica de cada entorno.

application-dev.yml (Desarrollo)
spring:
  profiles: dev
  h2:
    console:
      enabled: true
      path: /h2-console
  datasource:
    url: jdbc:h2:mem:conecta_dev;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driverClassName: org.h2.Driver
    username: sa
    password: password
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: update # or create-drop for fresh start on each run
    show-sql: true

conecta:
  jwt:
    secret: ThisIsASecretKeyForDevelopmentOnlyAndShouldNotBeUsedInProduction
    expiration: 3600000 # 1 hour in ms
  logging:
    level: DEBUG

application-preprod.yml (Preproducción)
spring:
  profiles: preprod
  datasource:
    url: jdbc:oracle:thin:@//preprod-db.yourcompany.com:1521/CONECTAPREPROD
    driverClassName: oracle.jdbc.OracleDriver
    username: conecta_preprod_user
    password: ${CONECTA_PREPROD_DB_PASSWORD} # Environment variable for security
  jpa:
    database-platform: org.hibernate.dialect.OracleDialect
    hibernate:
      ddl-auto: none # No schema changes in pre-production
    show-sql: false

conecta:
  jwt:
    secret: ${CONECTA_JWT_SECRET_PREPROD} # Environment variable for security
    expiration: 1800000 # 30 minutes in ms
  logging:
    level: INFO

application-prod.yml (Producción)
spring:
  profiles: prod
  datasource:
    url: jdbc:oracle:thin:@//prod-db.yourcompany.com:1521/CONECTAPROD
    driverClassName: oracle.jdbc.OracleDriver
    username: conecta_prod_user
    password: ${CONECTA_PROD_DB_PASSWORD} # Environment variable for security
  jpa:
    database-platform: org.hibernate.dialect.OracleDialect
    hibernate:
      ddl-auto: none # No schema changes in production
    show-sql: false

conecta:
  jwt:
    secret: ${CONECTA_JWT_SECRET_PROD} # Environment variable for security
    expiration: 900000 # 15 minutes in ms
  logging:
    level: WARN # Or INFO depending on verbosity needs
  server:
    port: 8080 # Default port, can be overridden by deployment environment
