# DRP — Grupo DT

## 1. Objetivo

Recuperar el servicio completo ante fallo grave manteniendo continuidad operativa de AD, Linux, base de datos y almacenamiento S3.

Este documento es el resumen ejecutivo; la versión completa y operativa del DRP está en `documentacion/entrega-final-dt/DRP/`.

## 2. Alcance de backup

- AD (DC01): System State backup.
- Linux DB: dump lógico de PostgreSQL (`academico`).
- Linux LB/Web: reprovisión por IaC + Ansible.
- S3: versionado habilitado + copia de verificación.

## 3. Procedimiento resumido de restauración

1. Desplegar infraestructura en cuenta de recuperación con CloudFormation.
2. Reconfigurar peering/rutas entre cuentas involucradas.
3. Restaurar AD desde backup de System State.
4. Provisionar Linux con Ansible (`setup_ad_dns_ntp`, `configure_dns_clients`, `deploy_app`).
5. Restaurar base de datos con `restore_latest_academico.sh`.
6. Verificar endpoints:
   - `/profesores`
   - `/alumnos`
   - `/practicas`
7. Verificar autenticación de dominio y GPO en cliente Windows.

## 4. Evidencias mínimas a guardar

- Logs de pipeline de despliegue y provisionado.
- Comandos de restauración ejecutados.
- Capturas de pruebas funcionales post-restauración.
- Registro de tiempos de recuperación (RTO) y pérdida de datos (RPO).

## 5. Criterios de éxito

- Todas las locations responden correctamente por LB.
- AD y cliente Windows operativos con políticas aplicadas.
- DB restaurada y consultas con resultados válidos.
- Integración S3 funcional por IAM Role.

## 6. Documentación extendida

La versión detallada y operativa del DRP se mantiene en:

- `documentacion/entrega-final-dt/DRP/`

Incluye:

- Estrategia 3-2-1
- Backups de Active Directory, PostgreSQL y S3
- Procedimiento de restauración end-to-end
- Objetivos RTO/RPO
- Checklist de evidencias
- Scripts de ejemplo para backup y restore
