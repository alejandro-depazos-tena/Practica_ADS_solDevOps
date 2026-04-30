# Backup de Active Directory

## Alcance

Se protege el controlador de dominio de Alumno A, incluyendo:

- Active Directory Domain Services
- DNS integrado en AD
- DHCP configurado en el DC
- Políticas de grupo y estructura de OU
- Configuración necesaria para recuperación del servicio

## Tipo de backup recomendado

### System State Backup

Es la opción más adecuada para un controlador de dominio porque preserva:

- Base de datos de AD
- Registro
- SYSVOL
- Configuración de arranque y servicios relacionados

## Frecuencia sugerida

- **Diario**: backup automático de System State
- **Semanal**: copia de verificación fuera del host
- **Antes de cambios críticos**: backup manual adicional

## Procedimiento operativo

1. Abrir PowerShell como administrador en el DC.
2. Ejecutar la herramienta de backup de Windows Server.
3. Incluir System State en la selección.
4. Guardar el respaldo en una ruta de backup dedicada.
5. Copiar el backup a ubicación externa o a S3 si la política del laboratorio lo permite.

## Verificación mínima

Después del backup debe comprobarse:

- Tamaño del fichero generado.
- Fecha y hora correctas.
- Que el backup no esté vacío.
- Que exista una ruta clara para restauración.

## Restauración

La recuperación de AD debe hacerse desde una cuenta o entorno alternativo y siguiendo el orden correcto:

1. Restaurar System State.
2. Reiniciar el DC según el procedimiento.
3. Validar el servicio de DNS.
4. Validar OU, usuarios y GPO.
5. Comprobar autenticación desde el cliente unido al dominio.

## Evidencia a conservar

- Captura del backup completado.
- Captura del fichero generado.
- Captura de la restauración.
- Captura de `Get-ADDomain` y `Get-ADUser` tras recuperar.
