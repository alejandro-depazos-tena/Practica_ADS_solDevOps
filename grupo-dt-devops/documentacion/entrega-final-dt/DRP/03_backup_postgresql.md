# Backup de PostgreSQL

## Objetivo

Proteger la base de datos `academico` para poder restaurar rápidamente tablas, datos y permisos después de un fallo.

## Estrategia

La solución del repositorio ya crea dos scripts:

- `backup_academico.sh`
- `restore_latest_academico.sh`

Además programa un cron diario para generar respaldos automáticos.

## Qué se respalda

- Base de datos `academico`
- Estructura de tablas
- Datos funcionales de las locations
- Roles y permisos necesarios para el servicio

## Política de retención sugerida

- **Diarios**: 7 días
- **Semanales**: 4 semanas
- **Mensuales**: 3 a 6 meses, según espacio disponible

## Flujo de backup

1. El script crea el directorio de backups si no existe.
2. Ejecuta `pg_dump` sobre `academico`.
3. Nombra el archivo con fecha y hora.
4. Deja trazabilidad del backup generado.
5. Opcionalmente copia el fichero a S3 o a otra cuenta.

## Flujo de restauración

1. Buscar el último dump válido.
2. Crear la base de datos de recuperación.
3. Importar el dump en el entorno restaurado.
4. Validar tablas y conteos mínimos.
5. Probar endpoints de la aplicación contra la base restaurada.

## Buenas prácticas

- Hacer backups consistentes fuera de horas pico si el tamaño crece.
- Validar que el usuario de backup tiene permisos mínimos.
- Probar restauración al menos una vez antes de la defensa.
- Registrar fecha, tamaño y checksum si se quiere mayor control.

## Evidencia recomendada

- Cron configurado.
- Archivo de backup generado.
- Restauración en base de datos de prueba.
- Consulta `SELECT COUNT(*)` o `\dt` tras recuperar.
