# RTO y RPO

## Definiciones

- **RTO (Recovery Time Objective):** tiempo máximo aceptable para recuperar el servicio.
- **RPO (Recovery Point Objective):** pérdida máxima aceptable de datos.

## Propuesta de objetivos para la práctica

| Componente | RTO objetivo | RPO objetivo | Justificación |
|---|---:|---:|---|
| Active Directory | 2-4 horas | 24 horas | Es la base de identidad y GPO. |
| PostgreSQL | 1-2 horas | 24 horas | La BD es crítica, pero se puede restaurar desde dump diario. |
| Web servers | 30-60 minutos | 0-24 horas | Se reprovisionan por IaC y Ansible. |
| S3 | 1-2 horas | 24 horas | Contiene evidencias o datos auxiliares. |
| Peering / rutas | 15-30 minutos | 0 | Debe reconstruirse de forma determinista. |

## Cómo justificarlo en defensa

La práctica no necesita tener RTO de producción bancaria, pero sí una lógica clara:

- Lo que es más fácil de reprovisionar tiene RTO menor.
- Lo que contiene identidad o datos tiene mayor prioridad.
- El RPO depende de la frecuencia de backup y de la criticidad del dato.

## Recomendación

No inventar cifras si no se han probado. Si se mide la restauración, se documenta el tiempo real y se usa ese valor en la memoria técnica.
