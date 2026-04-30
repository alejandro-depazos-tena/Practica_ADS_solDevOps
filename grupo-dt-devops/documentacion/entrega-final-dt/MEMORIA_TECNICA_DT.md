# Memoria Técnica — Integración de Sistemas en AWS (Grupo DT)

## 1. Objetivo

Implementar una arquitectura distribuida en AWS con integración real entre cuentas, combinando Windows y Linux, y automatizando despliegue y operación con IaC + CI/CD + Ansible.

## 2. Organización del equipo (5 alumnos)

- **Alumno A (Alejandro):** AD DS, DNS, DHCP, NTP, GPO, cliente Windows de dominio.
- **Alumno B (Nicolás):** Nginx Load Balancer y PostgreSQL (incluye backup/restore).
- **Alumno C (Mario):** Web01 y módulo `/profesores`.
- **Alumno D (Gonzalo):** Web02 y módulo `/alumnos`.
- **Alumno E (Jesús):** Web03 y módulo `/practicas`.

## 3. Arquitectura desplegada

### 3.1 Redes

- Cinco cuentas AWS individuales, una por alumno.
- Cada cuenta contiene su propia VPC, subredes, route tables, security groups y recursos del rol asignado.
- Integración entre cuentas mediante peering y rutas cruzadas según necesidad de AD, LB, DB y webservers.

### 3.1.1 Diagrama técnico de red e ինտեգración

```mermaid
flowchart TB
  Internet[Acceso externo / navegador] --> LB[Nginx Load Balancer]

  subgraph Identity[Identidad y directorio]
    AD[Active Directory / DNS / DHCP / NTP]
    WIN[Cliente Windows unido al dominio]
  end

  subgraph Apps[Servicios web]
    W1[Web módulo /profesores]
    W2[Web módulo /alumnos]
    W3[Web módulo /practicas]
  end

  subgraph Data[Persistencia y ficheros]
    DB[(PostgreSQL academico)]
    S3[(S3 / evidencias y objetos)]
  end

  subgraph Net[Red privada]
    VPC[VPCs y subredes]
    PEER[Peering + rutas cruzadas]
    SG[Security Groups por rol]
  end

  Internet --> LB
  LB --> W1
  LB --> W2
  LB --> W3
  W1 --> DB
  W2 --> DB
  W3 --> DB
  W1 --> S3
  W2 --> S3
  W3 --> S3
  AD --> WIN
  AD -. DNS / NTP .-> W1
  AD -. DNS / NTP .-> W2
  AD -. DNS / NTP .-> W3
  AD -. DNS / NTP .-> LB
  VPC --> PEER
  PEER --> SG
  SG --> AD
  SG --> LB
  SG --> W1
  SG --> W2
  SG --> W3
```

**Lectura técnica:** la arquitectura se organiza por capas funcionales: identidad, aplicación, persistencia y red. El balanceador distribuye el tráfico a los módulos web, las aplicaciones consumen la base de datos y S3, y AD aporta DNS, DHCP, NTP y autenticación del dominio.

### 3.2 Capa Windows

- DC01 Windows con AD DS.
- DNS y DHCP integrados en AD.
- NTP activo para sincronización de Linux.
- GPO NoShutdown y GPO MapDrive.
- Cliente Windows unido al dominio y validado.

### 3.2.1 Diagrama de AD y cliente de dominio

```mermaid
flowchart TB
  Usuario[Usuario del dominio] --> Cliente[Cliente Windows]
  Cliente --> Validacion{DHCP + DNS correctos}
  Validacion -->|Sí| AD[Controlador de dominio]
  Validacion -->|No| Error[No se une al dominio]
  AD --> DNS[Servicio DNS]
  AD --> DHCP[Servicio DHCP]
  AD --> NTP[Servidor NTP]
  AD --> GPO1[GPO: impedir apagado]
  AD --> GPO2[GPO: unidad de red mapeada]
  DNS --> Cliente
  DHCP --> Cliente
  NTP --> Cliente
  GPO1 --> Cliente
  GPO2 --> Cliente
```

**Qué demuestra:** el servidor Windows centraliza identidad, resolución de nombres, asignación automática de red, sincronización horaria y políticas de grupo. El cliente solo funciona correctamente si recibe esos servicios de forma coherente.

### 3.3 Capa Linux

- LB Nginx con locations por módulo:
  - `/profesores` -> Web01
  - `/alumnos` -> Web02
  - `/practicas` -> Web03
- PostgreSQL con base `academico` y tablas:
  - `asignaturas`
  - `alumnos`
  - `inscripciones`
  - `practicas`
  - `entregas`
- Webservers Linux con Node.js y Nginx local.
- Integración S3 mediante IAM Role (sin credenciales hardcodeadas en código).

### 3.3.1 Diagrama de flujo de aplicaciones y datos

```mermaid
flowchart TB
  Usuario --> LB[Nginx Load Balancer]
  LB --> P1[Módulo /profesores]
  LB --> P2[Módulo /alumnos]
  LB --> P3[Módulo /practicas]

  P1 --> DB[(Base de datos academico)]
  P2 --> DB
  P3 --> DB

  P1 --> S3[(S3)]
  P2 --> S3
  P3 --> S3

  DB --> BK[Backup lógico programado]
  BK --> RS[Restauración del último dump]
```

**Lectura técnica:** cada location representa una funcionalidad distinta de la aplicación, pero todas comparten la misma base de datos y el mismo modelo de persistencia. S3 actúa como almacenamiento complementario y el DRP protege la información con backup y restauración verificable.

## 4. Automatización

### 4.1 Infraestructura como código

- `cloudformation/strict-5/stack-A-ad-client.yaml`
- `cloudformation/strict-5/stack-B-lb-db.yaml`
- `cloudformation/strict-5/stack-C-web-upstream1.yaml`
- `cloudformation/strict-5/stack-D-web-upstream2.yaml`
- `cloudformation/strict-5/stack-E-web-upstream3.yaml`

### 4.2 CI/CD

- GitHub Actions:
  - `.github/workflows/deploy.yml`
  - `.github/workflows/ansible-provision.yml`
- Jenkins:
  - `jenkins/Jenkinsfile-infra`
  - `jenkins/Jenkinsfile-provision`
  - `jenkins/Jenkinsfile-webdeploy`

### 4.3 Provisioning

- `ansible/playbooks/setup_ad_dns_ntp.yml`
- `ansible/playbooks/configure_dns_clients.yml`
- `ansible/playbooks/deploy_app.yml`
- `ansible/playbooks/update_web.yml`

## 5. Seguridad

- IAM por mínimo privilegio para acceso S3 desde instancias web.
- SG segmentados por rol y puerto.
- `AdminCidr` sin default abierto para obligar acceso administrativo controlado.
- Sin uso operativo de usuario root.

## 6. DRP (estado)

### 6.1 Implementado en repositorio

- Backup automático de PostgreSQL diario (`backup_academico.sh`).
- Script de restauración al último backup (`restore_latest_academico.sh`).
- Reprovisión completa vía CloudFormation + Ansible.

### 6.2 Pendiente de evidencia final

- Evidencia de backup AD (System State).
- Evidencia de backup S3.
- Restauración documentada en cuenta alternativa.
- Verificación funcional post-restauración.
- Protocolo de comunicación de incidencias entre integrantes.

## 7. Evidencias y defensa

Todas las capturas y logs deben consolidarse en:
- `documentacion/entrega-final-dt/CHECKLIST_EVIDENCIAS_DT.md`

Sin ese cierre, el trabajo técnico está implementado pero no completamente defendible en evaluación formal de rúbrica.
