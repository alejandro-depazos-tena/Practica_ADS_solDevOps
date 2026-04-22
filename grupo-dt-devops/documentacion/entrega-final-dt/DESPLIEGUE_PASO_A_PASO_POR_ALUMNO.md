# Despliegue Completo Paso a Paso por Alumno (Rúbrica AWS)

## 1. Objetivo de esta guía

Este documento describe el despliegue completo de la práctica, explicado por responsabilidades de cada alumno según la rúbrica:

- Alumno A: Windows AD, DNS, DHCP, NTP, GPO.
- Alumno B: Linux LB + PostgreSQL + backup/restore.
- Alumno C: WebServer 1 + backend Node.
- Alumno D: WebServer 2 + redundancia y balanceo.
- Alumno E: Windows Client + unión a dominio + validación GPO.

Además, incluye el orden global de ejecución del equipo para llegar a un entorno funcional y defendible.

---

## 2. Requisitos previos del equipo

### 2.1 Software en máquina de control

- AWS CLI v2
- Ansible
- Python 3
- Acceso a Jenkins (si se usa pipeline)

### 2.2 Perfiles AWS configurados

Deben existir perfiles funcionales:

- AlejandroA
- NicolasB
- MarioC
- GonzaloD
- JesusE

### 2.3 Variables de entorno necesarias

Usar como base el archivo [.env](.env).

Variables críticas:

- AWS_REGION
- ANSIBLE_SSH_USER
- ANSIBLE_SSH_PASSWORD
- ANSIBLE_WIN_USER
- ANSIBLE_WIN_PASSWORD
- AD_SAFE_MODE_PASSWORD
- AD_DEFAULT_USER_PASSWORD
- AD_DOMAIN_JOIN_USER
- AD_DOMAIN_JOIN_PASSWORD
- POSTGRES_READ_USER
- POSTGRES_READ_PASSWORD
- POSTGRES_WRITE_USER
- POSTGRES_WRITE_PASSWORD
- S3_BUCKET_NAME

### 2.4 Validación previa

Ejecutar:

```bash
./scripts/check-prerequisites.sh
```

Si falla, corregir antes de continuar.

---

## 3. Flujo global del equipo (orden obligatorio)

1. Desplegar infraestructura CloudFormation.
2. Construir inventario dinámico Ansible.
3. Configurar AD/DNS/DHCP/NTP/GPO y unir cliente Windows.
4. Configurar Linux para DNS/NTP contra AD.
5. Desplegar LB + DB + Web + Node + S3 integration.
6. Validar endpoints y evidencias de rúbrica.

---

## 4. Paso a paso por alumno

## 4.1 Alumno A (Alejandro) - AD/DNS/DHCP/NTP/GPO

### Objetivos de rúbrica

- Controlador de dominio operativo.
- DNS y DHCP integrados con AD.
- NTP operativo para Linux.
- OU, grupo y al menos dos usuarios.
- GPO NoShutdown y GPO MapDrive aplicadas.

### Pasos

1. Confirmar que la infraestructura está desplegada.
2. Ejecutar playbook de AD:

```bash
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/setup_ad_dns_ntp.yml
```

3. Verificar en Windows DC:
- AD DS instalado.
- Scope DHCP creado y autorizado.
- OU Alumnos creada.
- Grupo grupo_alumnos y usuarios alumno1/alumno2.
- Share CIFS CompartidoAlumnos.
- GPOs vinculadas a la OU.

4. Verificar NTP:

```powershell
w32tm /query /status
```

### Evidencias que debe guardar

- AD Users and Computers (OU, grupo, usuarios).
- DHCP scope y opciones DNS/router.
- GPMC con GPO_NoShutdown y GPO_MapDrive enlazadas.
- Recurso compartido CIFS creado.

---

## 4.2 Alumno B (Nicolás) - LB + PostgreSQL + Backup/Restore

### Objetivos de rúbrica

- LB con Nginx reverse proxy funcional.
- PostgreSQL operativo.
- Estructura de base de datos coherente.
- Control de accesos por roles.
- Backup automatizado y restauración funcional.

### Pasos

1. Configurar clientes Linux para usar AD como DNS/NTP:

```bash
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/configure_dns_clients.yml
```

2. Desplegar stack de aplicación:

```bash
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/deploy_app.yml
```

3. Verificar PostgreSQL:

```bash
sudo -u postgres psql -d academico -c "\dn"
sudo -u postgres psql -d academico -c "\dt academico.*"
```

4. Verificar roles:

```bash
sudo -u postgres psql -c "\du"
```

5. Forzar un backup de prueba:

```bash
sudo /usr/local/bin/backup_academico.sh
```

6. Probar restauración:

```bash
sudo /usr/local/bin/restore_latest_academico.sh
```

7. Comprobar cron:

```bash
crontab -l
```

### Evidencias que debe guardar

- Nginx LB activo y sirviendo contenido.
- PostgreSQL con esquema academico.
- Roles backend_read/backend_write.
- Backup generado en /var/backups/postgresql.
- Restauración exitosa en academico_restore.

---

## 4.3 Alumno C (Mario) - WebServer 1 + API Node

### Objetivos de rúbrica

- WebServer funcional detrás del LB.
- API Node funcional para /profesores.
- Acceso backend a base de datos.
- Integración S3 por IAM role.

### Pasos

1. Verificar servicio Node:

```bash
sudo systemctl status ufvNodeService
sudo journalctl -u ufvNodeService -n 50
```

2. Verificar endpoint de salud local:

```bash
curl -s http://127.0.0.1:3001/health
```

3. Verificar endpoint de profesores local:

```bash
curl -s http://127.0.0.1:3001/profesores
```

4. Verificar endpoint S3 local:

```bash
curl -s http://127.0.0.1:3001/s3/objects
```

5. Confirmar que el servicio usa variables de entorno:
- /etc/ufv-node.env existente.
- DB_HOST, DB_NAME, DB_USER y S3_BUCKET_NAME definidos.

### Evidencias que debe guardar

- ufvNodeService en estado active.
- Respuesta JSON de /health.
- Respuesta JSON de /profesores.
- Respuesta JSON de /s3/objects.

---

## 4.4 Alumno D (Gonzalo) - WebServer 2 + redundancia y balanceo

### Objetivos de rúbrica

- Segundo webserver operativo.
- Balanceo real en LB hacia Web01 y Web02.
- Configuración Nginx y Node consistente.

### Pasos

1. Verificar mismo estado de servicios que en Web01:

```bash
sudo systemctl status nginx
sudo systemctl status ufvNodeService
```

2. Confirmar conectividad hacia DB y AD DNS/NTP.
3. Validar balanceo desde LB:

```bash
curl -I http://<LB_PUBLIC_IP>/
curl -s http://<LB_PUBLIC_IP>/profesores
```

4. Repetir llamadas varias veces para comprobar distribución entre nodos (logs de Nginx/Node en ambos webservers).

### Evidencias que debe guardar

- Web02 activo con nginx y ufvNodeService.
- Prueba de balanceo entre dos backend nodes.
- Capturas de logs de ambos servidores recibiendo tráfico.

---

## 4.5 Alumno E (Jesús) - Windows Client + dominio + validación GPO

### Objetivos de rúbrica

- Cliente unido al dominio.
- DNS apuntando al AD.
- Autenticación con usuario de dominio.
- Aplicación de GPO y acceso a recurso compartido.

### Pasos

1. Ejecutar (incluido en playbook AD, pero se puede relanzar):

```bash
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/setup_ad_dns_ntp.yml --limit windows_clients
```

2. En cliente Windows, validar:
- Equipo unido al dominio corp.ufv.local.
- Inicio de sesión con alumno1 o alumno2.
- Unidad Z: mapeada al share.
- Restricción de apagado aplicada.

3. Ejecutar actualización de políticas:

```powershell
gpupdate /force
```

### Evidencias que debe guardar

- Propiedades del sistema mostrando dominio.
- Login exitoso con usuario AD.
- Unidad de red Z: visible.
- Comportamiento de GPO_NoShutdown.

---

## 5. Ejecución alternativa con Jenkins (equipo)

Pipeline principal de infraestructura: [jenkins/Jenkinsfile-infra](jenkins/Jenkinsfile-infra)

Pipeline de provisión: [jenkins/Jenkinsfile-provision](jenkins/Jenkinsfile-provision)

Orden recomendado:

1. AWS-UFV-CloudFormation-Deploy (ACTION=deploy).
2. AWS-UFV-Ansible-Inventory-Build.
3. AWS-UFV-Ansible-App-Deploy (PLAYBOOK=all).
4. AWS-UFV-Ansible-Web-Deploy para cambios incrementales.

Parámetros obligatorios en provision:

- AD_SAFE_MODE_PASSWORD
- AD_DEFAULT_USER_PASSWORD
- AD_DOMAIN_JOIN_USER
- AD_DOMAIN_JOIN_PASSWORD
- POSTGRES_READ_USER
- POSTGRES_READ_PASSWORD
- POSTGRES_WRITE_USER
- POSTGRES_WRITE_PASSWORD
- S3_BUCKET_NAME

El valor S3_BUCKET_NAME debe ser el output AppStorageBucketName de la stack UFV.

---

## 6. Validación final de rúbrica (equipo completo)

Checklist mínimo:

- Infraestructura en CREATE_COMPLETE (ambas stacks).
- Peering activo con rutas cruzadas funcionales.
- AD + DNS + DHCP + NTP funcionales.
- OU, grupo, usuarios y GPO aplicadas.
- Cliente Windows unido al dominio y validado.
- LB operativo con balanceo entre Web01/Web02.
- Endpoint web / funcionando.
- Endpoint API /profesores funcionando.
- Endpoint /s3/objects funcionando con IAM role.
- PostgreSQL con esquema academico y roles por funcionalidad.
- Backup diario y restore probado.
- Presupuesto AWS y alertas configuradas.

---

## 7. Evidencias recomendadas para defensa

Para cada bloque, guardar capturas con fecha/hora:

- AWS Console (stacks, VPC, SG, budgets).
- Jenkins/GitHub Actions (ejecuciones en verde).
- AD/DHCP/GPMC/cliente de dominio.
- Nginx/Node/PostgreSQL con comandos de verificación.
- Resultado de backup y restore.
- Pruebas curl a /, /profesores, /s3/objects.

---

## 8. Cierre de práctica

Cuando todas las evidencias estén completas:

1. Consolidar capturas y logs en la carpeta de entrega final.
2. Revisar coherencia entre documentación y despliegue real.
3. Preparar defensa: arquitectura, responsabilidades, incidencias, mejoras.

Con este procedimiento, cada alumno cubre su parte técnica y el equipo cubre la integración completa que exige la rúbrica.
