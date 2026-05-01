# Checklist de evidencias DRP

## 1. Active Directory

- [ ] Backup de System State ejecutado en DC01.
- [ ] Evidencia del fichero de backup generado.
- [ ] Restauración de AD verificada.
- [ ] DNS operativo tras la restauración.
- [ ] OU, usuarios y GPO visibles tras la recuperación.

## 2. PostgreSQL

- [ ] Backup automático de `academico` creado.
- [ ] Cron de backup validado.
- [ ] Restauración en base de datos de prueba o de recuperación.
- [ ] Consulta de conteo o tablas tras la restauración.

## 3. S3

- [ ] Versionado activado en el bucket principal.
- [ ] Copia secundaria o exportación verificada.
- [ ] Lectura del objeto desde entorno de recuperación.

## 4. Infraestructura

- [ ] Stack de infraestructura desplegado en cuenta de recuperación.
- [ ] Peering y rutas cruzadas restauradas.
- [ ] Security groups verificados.

## 5. Validación funcional

- [ ] `/profesores` responde.
- [ ] `/alumnos` responde.
- [ ] `/practicas` responde.
- [ ] Cliente Windows unido al dominio.
- [ ] GPO aplicadas correctamente.

## 6. Evidencias de proceso

- [ ] Logs de backup.
- [ ] Logs de restauración.
- [ ] Capturas de pruebas finales.
- [ ] Tiempos de RTO y RPO documentados.
- [ ] Protocolo de comunicación ante incidentes.
