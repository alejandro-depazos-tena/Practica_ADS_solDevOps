# Despliegue paso a paso por alumno — Grupo DT

## 1. Reparto oficial (equipo de 5)

- Alumno A: AD/DNS/DHCP/NTP + cliente Windows
- Alumno B: LB + PostgreSQL + backup/restore
- Alumno C: Web01 + location `/profesores`
- Alumno D: Web02 + location `/alumnos`
- Alumno E: Web03 + location `/practicas`

## 2. Secuencia global

1. Desplegar infraestructura (`infra`).
2. Actualizar inventario dinámico.
3. Provisionar AD y cliente Windows.
4. Provisionar Linux DNS/NTP.
5. Desplegar LB, DB y web módulos.
6. Validar endpoints y evidencias.

## 3. Alumno A (AD + cliente Windows)

### Tareas

- Ejecutar `setup_ad_dns_ntp.yml`.
- Verificar AD DS, DNS, DHCP y NTP.
- Validar OU, grupo, usuarios y GPO.
- Verificar cliente Windows unido al dominio por DHCP.

### Comprobaciones mínimas

- `Get-ADDomain`
- `Get-DhcpServerv4Scope`
- `w32tm /query /status`
- Inicio de sesión con usuario de AD en cliente.

## 4. Alumno B (LB + DB)

### Tareas

- Ejecutar `deploy_app.yml` para LB y PostgreSQL.
- Validar Nginx LB y rutas por location.
- Validar tablas y datos de `academico`.
- Confirmar cron de backup y restauración.

### Comprobaciones mínimas

- `systemctl status nginx`
- `sudo -u postgres psql -d academico -c "\dt academico.*"`
- `crontab -l | grep backup_academico`

## 5. Alumno C (Web01 /profesores)

### Tareas

- Validar Web01 en inventario.
- Confirmar servicio Node activo con módulo profesores.
- Probar endpoint `/profesores` vía LB.

### Comprobaciones mínimas

- `systemctl status ufvNodeService`
- `curl http://<LB_PUBLIC_IP>/profesores`

## 6. Alumno D (Web02 /alumnos)

### Tareas

- Validar Web02 en inventario.
- Confirmar servicio Node activo con módulo alumnos.
- Probar endpoint `/alumnos` vía LB.

### Comprobaciones mínimas

- `systemctl status ufvNodeService`
- `curl http://<LB_PUBLIC_IP>/alumnos`

## 7. Alumno E (Web03 /practicas)

### Tareas

- Validar Web03 en inventario.
- Confirmar servicio Node activo con módulo prácticas.
- Probar endpoint `/practicas` vía LB.

### Comprobaciones mínimas

- `systemctl status ufvNodeService`
- `curl http://<LB_PUBLIC_IP>/practicas`

## 8. Checklist final conjunto

- Peering y rutas cruzadas activos.
- AD + GPO + cliente Windows demostrables.
- LB enruta correctamente a 3 módulos.
- DB con 5 tablas de rúbrica.
- Evidencias cerradas en `CHECKLIST_EVIDENCIAS_DT.md`.
