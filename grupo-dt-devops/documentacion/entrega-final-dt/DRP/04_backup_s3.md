# Backup de S3

## Objetivo

Garantizar que los objetos almacenados en S3 puedan recuperarse aunque falle la instancia, la cuenta principal o el flujo normal de despliegue.

## Estrategia recomendada

### 1. Versionado

Activar versionado en el bucket principal para evitar pérdida accidental por sobrescritura o borrado.

### 2. Copia externa

Mantener una copia adicional en una de estas opciones:

- Bucket de recuperación en otra cuenta
- Replicación entre buckets si está disponible
- Exportación periódica con `aws s3 sync`

### 3. Verificación

No basta con copiar. Hay que comprobar que:

- El objeto aparece en la copia secundaria.
- La versión recuperada coincide con la esperada.
- El acceso IAM funciona desde el entorno restaurado.

## Recomendación operativa

- Definir un bucket principal de trabajo.
- Definir un bucket secundario en cuenta alternativa.
- Programar sincronización periódica o copia manual controlada.
- Documentar el proceso de restore de forma exacta.

## Evidencias mínimas

- Bucket con versionado habilitado.
- Lista de objetos antes y después de la copia.
- Prueba de lectura desde la cuenta de recuperación.
- Resultado de sincronización o replicación.
