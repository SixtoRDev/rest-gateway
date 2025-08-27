### Planificación de Desarrollo del Proyecto CONECTA

**Objetivo General:** Desarrollar el API Gateway CONECTA, incluyendo su frontend administrativo y backend de procesamiento de tráfico, con un enfoque en la calidad del código y la cobertura de pruebas.

---

#### **Tarea 1: Arquitectura Base y "Hola Mundo"**

*   **Descripción:** Configuración inicial de los proyectos frontend (Angular) y backend (Spring Boot). Creación de una página de inicio simple en el frontend y un endpoint "Hola Mundo" en el backend, sin autenticación ni conexión a base de datos. Establecimiento de la estructura de directorios y dependencias básicas.
*   **Componentes Afectados:**
    *   **Frontend:** Estructura de proyecto Angular, componente `AppComponent`, routing básico.
    *   **Backend:** Estructura de proyecto Spring Boot, `Application.java`, un controlador REST simple (`/hello`).
*   **Casos de Test:**
    *   **Unitarias:** Verificar que los componentes y servicios básicos se inicializan correctamente.
    *   **Integración:** Probar la comunicación básica entre el frontend y el endpoint "Hola Mundo" del backend.
*   **Cobertura:** Asegurar que los archivos de configuración y los componentes/controladores iniciales estén cubiertos.

---

#### **Tarea 2: Gestión de Usuarios (CRUD) y Autenticación Básica**

*   **Descripción:** Implementación completa de las funcionalidades CRUD (Crear, Leer, Actualizar, Eliminar) para la entidad `User`. Esto incluye la persistencia en base de datos, la lógica de negocio para la gestión de usuarios y la autenticación básica (login/logout) para el acceso a la UI administrativa.
*   **Componentes Afectados:**
    *   **Frontend:** `UI Authentication` (componentes de login), `Admin Dashboard` (componentes de gestión de usuarios), servicios HTTP para usuarios.
    *   **Backend:** `User Management` (controladores, servicios, repositorios), `Database Access` (entidades JPA para `User`, `UserRole`), `Security Module` (lógica de autenticación inicial).
*   **Casos de Test:**
    *   **Unitarias:** Métodos de servicio de usuario, validación de datos, lógica de autenticación.
    *   **Integración:** Flujo completo de login, creación/actualización/eliminación de usuarios a través de la API.
    *   **Funcionales:** Pruebas de interfaz de usuario para la gestión de usuarios y el proceso de login.
*   **Cobertura:** Alta cobertura en servicios de usuario, controladores y lógica de seguridad.

---

#### **Tarea 3: Gestión de Configuración (CRUD)**

*   **Descripción:** Implementación de las funcionalidades CRUD para las entidades de configuración: `RouteConfiguration`, `JWTConfiguration` y `SystemConfiguration`. Esto permitirá la gestión dinámica de rutas, secretos JWT y configuraciones generales del sistema desde la UI.
*   **Componentes Afectados:**
    *   **Frontend:** `Configuration Management` (componentes para cada tipo de configuración), servicios HTTP.
    *   **Backend:** `Configuration Service` (controladores, servicios, repositorios), `Database Access` (entidades JPA para `RouteConfiguration`, `JWTConfiguration`, `SystemConfiguration`).
*   **Casos de Test:**
    *   **Unitarias:** Métodos de servicio de configuración, validación de datos.
    *   **Integración:** Creación/actualización/eliminación de configuraciones a través de la API.
    *   **Funcionales:** Pruebas de interfaz de usuario para la gestión de cada tipo de configuración.
*   **Cobertura:** Alta cobertura en servicios de configuración y controladores.

---

#### **Tarea 4: Procesamiento de Tokens JWT para Tráfico Entrante**

*   **Descripción:** Implementación de la lógica para validar y extraer tokens JWT de las peticiones entrantes. Esto incluye la integración con el `JWT Handler` y el `Security Module` para asegurar que solo las peticiones con tokens válidos sean procesadas.
*   **Componentes Afectados:**
    *   **Backend:** `Security Module` (filtros/interceptores de seguridad), `JWT Handler` (métodos de validación de token).
*   **Casos de Test:**
    *   **Unitarias:** Métodos de validación de JWT (tokens válidos, expirados, inválidos).
    *   **Integración:** Envío de peticiones con y sin JWT, verificación de respuestas de autorización (401).
*   **Cobertura:** Cobertura exhaustiva en la lógica de validación de JWT y los filtros de seguridad.

---

#### **Tarea 5: Enrutamiento Dinámico de Peticiones**

*   **Descripción:** Desarrollo del `Routing Engine` para resolver dinámicamente las rutas de las peticiones entrantes basándose en la `RouteConfiguration` almacenada. Esto incluye la lógica para redirigir las peticiones al `targetServiceUrl` correspondiente.
*   **Componentes Afectados:**
    *   **Backend:** `Routing Engine` (lógica de resolución de rutas), `Gateway Controller` (integración con el motor de enrutamiento).
*   **Casos de Test:**
    *   **Unitarias:** Lógica de mapeo de rutas, manejo de rutas no encontradas.
    *   **Integración:** Envío de peticiones a diferentes rutas configuradas y verificación de la redirección correcta.
*   **Cobertura:** Cobertura completa en la lógica del motor de enrutamiento.

---

#### **Tarea 6: Generación e Inyección de Tokens JWT para Tráfico Saliente**

*   **Descripción:** Implementación de la lógica para generar tokens JWT y añadirlos a los headers de las peticiones salientes hacia sistemas externos. Esto se basará en la `JWTConfiguration` para el sistema externo de destino.
*   **Componentes Afectados:**
    *   **Backend:** `JWT Handler` (métodos de generación de token), `Routing Engine` (inyección de token antes de reenviar).
*   **Casos de Test:**
    *   **Unitarias:** Métodos de generación de JWT (claims, expiración).
    *   **Integración:** Envío de peticiones salientes y verificación de la presencia y validez del JWT en los headers.
*   **Cobertura:** Cobertura exhaustiva en la lógica de generación de JWT.

---

#### **Tarea 7: Módulo de Auditoría**

*   **Descripción:** Implementación del `Audit Service` y la entidad `AuditLog` para registrar todas las transacciones de tráfico (entrante y saliente) y las acciones administrativas. Esto incluye la persistencia de los logs y la funcionalidad de consulta desde el `Audit Console` del frontend.
*   **Componentes Afectados:**
    *   **Frontend:** `Audit Console` (componentes de visualización y filtrado de logs).
    *   **Backend:** `Audit Service` (controladores, servicios, repositorios), `Database Access` (entidad JPA para `AuditLog`), `Gateway Controller` y `Management Services` (integración para registrar eventos).
*   **Casos de Test:**
    *   **Unitarias:** Métodos de servicio de auditoría, persistencia de logs.
    *   **Integración:** Verificación de que las acciones y transacciones generan logs correctos.
    *   **Funcionales:** Consulta de logs desde la UI, aplicación de filtros.
*   **Cobertura:** Alta cobertura en el servicio de auditoría y los puntos de integración.

---

#### **Tarea 8: Gestión Transaccional**

*   **Descripción:** Implementación del `Transaction Manager` para asegurar la integridad de las operaciones, especialmente aquellas que involucran múltiples pasos (ej. enrutamiento con registro de auditoría). Esto incluye el manejo de `commit` y `rollback`.
*   **Componentes Afectados:**
    *   **Backend:** `Transaction Manager` (lógica transaccional), `Gateway Controller` y `Management Services` (integración con el gestor de transacciones).
*   **Casos de Test:**
    *   **Unitarias:** Lógica de inicio, commit y rollback de transacciones.
    *   **Integración:** Pruebas de escenarios de éxito y fallo para asegurar que las transacciones se manejan correctamente (ej. un fallo en el servicio interno provoca un rollback y un registro de error).
*   **Cobertura:** Cobertura completa en la lógica del gestor de transacciones y su integración.

---