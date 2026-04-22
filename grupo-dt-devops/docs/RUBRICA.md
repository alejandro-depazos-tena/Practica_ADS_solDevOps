# RUBRICA: Integración de Sistemas en AWS

## Indice

1. OBJETIVO DE LA PRÁCTICA  
2. SERVICIOS AWS UTILIZADOS  
3. REQUISITOS PREVIOS  
4. ESTRUCTURA TÉCNICA DE LA PRÁCTICA  
4.1 Infraestructura Base  
4.2 Componente Windows Server – Active Directory  
4.3 Componentes Linux  
4.4 Disaster Recovery Plan (DRP)  
4.5 Memoria Técnica  
5. ORGANIZACION DE EQUIPOS  
6. CRITERIOS DE EVALUACIÓN  
6.1. PONDERACIÓN GLOBAL  
6.2. PONDERACIÓN DETALLADA  
7. CRITERIO DE CALIFICACIÓN FINAL  
7.1 Condición indispensable de superación  
7.2 Defensa de la practica  
7.3 Evaluación de coherencia y veracidad  
7.4 Cálculo de la nota final  
7.5 Principio de responsabilidad colectiva  
8. FECHA DE ENTREGA  

---

## 1. OBJETIVO DE LA PRÁCTICA

Diseñar, desplegar e integrar una arquitectura distribuida en AWS utilizando cuentas 
individuales por alumno, garantizando:

 Uso coordinado de múltiples sistemas operativos (Windows Server y Linux).  
 Integración real entre cuentas AWS diferentes.  
 Aplicación de buenas prácticas de seguridad, red y control de costes.  
 Implementación de un Plan de Recuperación ante Desastres (DRP).  
 Documentación técnica profesional.  

La práctica evalúa tanto la competencia técnica individual como la capacidad de integración y 
coordinación en equipo.

---

## 2. SERVICIOS AWS UTILIZADOS

 IAM (roles, políticas, acceso entre cuentas)  
 VPC, Subnets, Route Tables, Internet Gateway  
 Security Groups  
 EC2 (Windows Server + Linux)  
 S3 (almacenamiento compartido y backups)  
 Budgets (control de costes)  

---

## 3. REQUISITOS PREVIOS

 Cuenta AWS individual por alumno.  
 Presupuesto configurado antes de desplegar infraestructura.  
 Usuario IAM creado (NO uso de root).  

---

## 4. ESTRUCTURA TÉCNICA DE LA PRÁCTICA

### 4.1 Infraestructura Base

Cada alumno debe:

 Diseñar una VPC con subred pública y privada.  
 Configurar correctamente tablas de rutas.  
 Aplicar principio de mínimo privilegio en Security Groups.  
 Crear roles IAM para acceso seguro a S3 (sin credenciales hardcodeadas).  
 Configurar un Budget funcional con alertas.  

---

### 4.2 Componente Windows Server – Active Directory

#### Windows Server – Controlador de Dominio (AD)

• Asignar IP fija (Elastic IP) a la instancia EC2 que actuará como AD.  
• Configuracion de Service Group para permitir conexiones desde todos los servidores Linux  
• Instalación y configuración funcional de Active Directory Domain Services (AD DS).  
• Configuración de DNS + DHCP integrado con AD.  
• Configuración de servidor NTP en Windows AD para que los clientes Linux puedan sincronizar la hora (puerto UDP 123).  
• Creacion de un recurso CIFS para usarlo en la politica GPO como punto de montaje  
• Creación de OU jerárquicas coherentes con la práctica.  
• Crear al meos un grupo de usuarios, al que se asignarán al menos dos usuarios.  
• Implementación de GPOs aplicadas al grupo:  
• GPO 1: impedir que los usuarios puedan apagar la máquina.  
• GPO 2: asignar una unidad de red mapeada automáticamente al iniciar sesión.  
• Evidencias de que el AD está operativo, accesible desde clientes y que las GPOs funcionan correctamente.  

#### Windows Server – Cliente del AD

• Configurar la instancia EC2 como cliente de dominio.  
• Obtener IP y DNS automáticamente mediante DHCP (proporcionado por el AD).  
• Unirse correctamente al dominio gestionado por el AD.  
• Comprobación de que puede autenticarse con usuarios del AD.  
• Evidencias de que puede acceder a recursos de red compartidos según la política de la práctica.  
• Verificación de que el cliente aplica GPO heredadas del AD correctamente.  

---

### 4.3 Componentes Linux

#### Load Balancer

 Asignar Elastic IP fija a la instancia EC2 del Load Balancer.  
 Creacion de un Service Group para permitir conexion desde un cliente externo.  
 Configuracion de cliente NTP con Servicio NTP de Windows AD  
 Nginx configurado como reverse proxy para redirigir tráfico a los distintos Web Servers. Mas detalles en seccion  
 Configuración de upstreams funcionales y balanceo operativo.  
 Separación de locations, cada una apuntando a un Web Server distinto y a una función diferente de la aplicación web.  
 Configuracion de Service Group para permitir conexiones desde los Web Servers  
 Configuración segura, evitando exposición de puertos innecesarios.  

#### Database Server

 La instancia EC2 de la base de datos tiene Elastic IP fija.  
 Configuracion de cliente NTP con Servicio NTP de Windows AD  
 Configuracion de Service Group para permitir conexiones desde los Web Servers  
 PostgreSQL instalado y funcionando correctamente.  
 Estructura de base de datos coherente con las funcionalidades de la aplicación web.  
 Control de accesos configurado (usuarios y permisos por location / funcionalidad).  
 Backup automatizado funcional y accesible para restauración.  

#### Web Servers

 Asignar Elastic IP fija a la a instancia E2C webserver  
 Configuracion de cliente NTP con Servicio NTP de Windows AD  
 Configuracion de Service Group para permitir conexiones desde el LB  
 Nginx operativo y correctamente estructurado.  
 Cada location corresponde a una funcionalidad concreta de la aplicación web y apunta a la base de datos correspondiente.  
 Integración con S3 mediante IAM Role para almacenamiento de archivos de la aplicación.  
 Acceso backend funcional hacia la base de datos asociada a cada location.  

---

### Frontend + Backend

Cada location configurada en los Web Servers corresponde a un módulo funcional de la aplicación (por ejemplo, /profesores, /alumnos, /laboratorios). El desarrollo del frontend y backend de cada location es responsabilidad exclusiva del miembro del equipo encargado de ese Web Server. Esto incluye la implementación de la lógica de negocio, las rutas del servidor, el acceso a la base de datos correspondiente y la correcta integración con S3 si aplica. Los demás miembros no deben modificar ni desarrollar código en esa location, aunque sí pueden verificar el funcionamiento durante las pruebas de integración.

---

### Funcionalidad de cada location y tablas asociadas

#### Profesores – Módulo de Profesores

Funcionalidad:  
• Gestión de asignaturas  
• Consulta de los estudiantes inscritos en cada asignatura.  

Tablas de base de datos asociadas:  
• asignaturas: lista de asignaturas y datos relevantes.  
• inscripciones: relación entre alumnos y clases.  

#### Alumnos – Módulo de Alumnos

Funcionalidad:  
• Consulta de notas y resultados de clases y asignaturas.  
• Inscripción en asignaturas/clases disponibles.  

Tablas de base de datos asociadas:  
• alumnos: información de cada alumno (nombre, correo, ID).  
• inscripciones: relación entre alumnos y clases.  

#### Prácticas – Módulo de Prácticas de Laboratorio

Funcionalidad:  
• Gestión de prácticas asignadas: creación y seguimiento de entregas.  

Tablas de base de datos asociadas:  
• practicas: descripción de cada práctica, asignaturas asociadas.  
• entregas: registro de las entregas de los alumnos.  

---

### 4.4 Disaster Recovery Plan (DRP)

Debe incluir:

 Backup documentado de AD.  
 Backup de instancias Linux y base de datos.  
 Backup de S3.  
 Procedimiento detallado de restauración en otra cuenta.  
 Verificación funcional post-restauración.  
 Protocolo de comunicación entre alumnos ante fallo.  

---

### 4.5 Memoria Técnica

Debe incluir:

 Diagramas claros de arquitectura.  
 Descripción de red y segmentación.  
 Explicación de roles individuales.  
 Procedimientos técnicos paso a paso.  
 Evidencias reales (capturas, comandos CLI, logs).  
 Conclusiones técnicas y problemas encontrados.  

---

## 5. ORGANIZACION DE EQUIPOS

Nº ALUMNOS Alumno Roles / Sistemas Esfuerzo  

1 Alumno A Windows Server AD + Windows Server + Web Server 100%  
2 Alumno A Windows Server AD + Windows Server 50%  
Alumno B Linux servicio web + Linux DB Server 50%  
3 Alumno A Windows Server AD + Windows Server 33%  
Alumno B Linux servicio web (LB) + Linux DB Server 33%  
Alumno C 2 x Linux servicio web 33%  
4 Alumno A Windows Server AD + Windows Server 25%  
Alumno B Linux servicio web (LB) + Linux DB Server 25%  
Alumno C 2 x Linux servicio web (location 1 + upstream 1) 25%  
Alumno D 2 x Linux servicio web (location 2 + upstream 2) 25%  
5 Alumno A Windows Server AD + Windows Server 20%  
Alumno B Linux servicio web (LB) + Linux DB Server 20%  
Alumno C 2 x Linux servicio web (location 1 + upstream 1) 20%  
Alumno D 2 x Linux servicio web (location 2 + upstream 2) 20%  
Alumno E 2 x Linux servicio web (location 3 + upstream 3) 20%  

Nota sobre tamaño de los equipos:  
Los equipos deberán estar formados al menos por 4 o 5 miembros. Cualquier propuesta de equipo con menos miembros deberá ser justificada ante el profesor.

---

## 6. CRITERIOS DE EVALUACIÓN

### 6.1. PONDERACIÓN GLOBAL

Bloque Peso  

Infraestructura AWS Base 10%  
Windows Server – AD 20%  
Componentes Linux 20%  
Integración Inter-Cuenta 15%  
DRP 15%  
Memoria Técnica 20%  

---

### 6.2. PONDERACIÓN DETALLADA

Infraestructura AWS Base (100%)

IAM 10%  
Diseño de VPC 30%  
Control de costes 10%  
Instancias E2C 40%  
Security Groups 10%  

Windows Server – AD (100%)

AD funcional 20%  
DNS + DHCP + NTP 20%  
Recurso CIFS 10%  
OU estructuradas 20%  
Usuarios y grupos 10%  
GPOs funcionales 20%  

Componentes Linux (100%)

Load Balancer (50%)

Reverse Proxy 40%  
Upstreams 25%  
Locations 25%  
NTP Client 10%  

Database Server (50%)

Instalación PostgreSQL 40%  
Modelo de datos 40%  
NTP Client 10%  
Uso de S3 10%  

Web Servers (100%)

Nginx operativo 25%  
Acceso a BD 25%  
Uso de S3 10%  
Frontend + Backend 40%  

---

## 7. CRITERIO DE CALIFICACIÓN FINAL

### 7.1 Condición indispensable de superación

• Todos los bloques deben estar aprobados (≥50%) de forma individual.  
• Si un bloque obtiene una calificación inferior al 50%, la práctica completa quedará automáticamente suspendida.  
• No se realizará compensación entre bloques.  
• No se aplicará redondeo para compensar suspensos parciales.  

---

### 7.2 Defensa de la practica

La defensa es obligatoria para todos los miembros del equipo.  

---

### 7.3 Evaluación de coherencia y veracidad

Se podrán solicitar pruebas reales, logs, comandos CLI y demostraciones.  

---

### 7.4 Cálculo de la nota final

1. Calcular cada bloque  
2. Verificar mínimos  
3. Aplicar ponderación  
4. Ajustar tras defensa  

---

### 7.5 Principio de responsabilidad colectiva

• Arquitectura → equipo  
• Comprensión → individual  
• Integración → compartida  

---

## 8. FECHA DE ENTREGA

La práctica deberá ser entregada como muy tarde durante las dos últimas clases previas al examen. No se aceptarán entregas fuera de este plazo.