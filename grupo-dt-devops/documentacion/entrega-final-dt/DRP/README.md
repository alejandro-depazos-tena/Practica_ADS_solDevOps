# DRP — Grupo DT

Este directorio centraliza el Plan de Recuperación ante Desastres (DRP) del proyecto.

## Objetivo

Definir una estrategia profesional de continuidad de negocio para recuperar el servicio tras una caída grave de cualquiera de los pilares de la práctica.

La recuperación se diseña para **todo el sistema**, no solo para la base de datos:

- Active Directory / DNS / DHCP / NTP
- Base de datos PostgreSQL
- Servidores Linux de aplicación
- Almacenamiento S3
- Conectividad entre cuentas y VPCs

## Principios

- **3-2-1**: 3 copias de la información, en 2 soportes distintos, con 1 copia fuera del entorno principal.
- **Recuperación verificable**: no existe backup válido si no se prueba la restauración.
- **Automatización**: los backups y la reprovisión deben poder ejecutarse con tiempos predecibles.
- **Trazabilidad**: cada backup y cada restauración debe dejar evidencia.

## Estructura de este DRP

- `00_vision_general.md`: alcance integral del DRP y diagrama de arquitectura.
- `00_vision_general.md`: alcance integral del DRP y enfoque por capas.
- `01_estrategia_3-2-1.md`: estrategia general y mapa de copias.
- `02_backup_active_directory.md`: backup de DC01 y validación.
- `03_backup_postgresql.md`: backup lógico, retención y restauración.
- `04_backup_s3.md`: versionado, exportación y copia fuera de línea.
- `05_restauracion_end_to_end.md`: secuencia de recuperación completa.
- `06_rto_rpo.md`: objetivos de recuperación por servicio.
- `07_checklist_evidencias.md`: evidencias mínimas para defensa.
- `scripts/`: scripts de ejemplo y comandos de respaldo/restauración.

## Fuentes ya implementadas en el repositorio

- `ansible/playbooks/deploy_app.yml`: crea `backup_academico.sh`, `restore_latest_academico.sh` y el cron diario.
- `documentacion/entrega-final-dt/DRP_DT.md`: resumen ejecutivo del DRP.
- `documentacion/entrega-final-dt/RUNBOOK_E2E_5_CUENTAS.md`: secuencia de despliegue y validación.

## Criterio de calidad

Este DRP está pensado para que sirva como documento de defensa y como runbook operativo. Si algo no se puede restaurar en un entorno alternativo, entonces todavía no está realmente protegido.
