# Script de despliegue CloudFormation - Grupo DT

Este directorio contiene scripts PowerShell para automatizar el despliegue de infraestructura en AWS con CloudFormation.

## Scripts disponibles

### 1. `deploy-all.ps1`
Despliegue completo de todos los stacks de las 5 cuentas en secuencia.

```powershell
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
```

**Parámetros:**
- `-AdminCidr`: CIDR administrativo para RDP/SSH (obligatorio)
- `-BudgetEmail`: Email para alertas de presupuesto (obligatorio)
- `-Region`: Región AWS (default: `eu-south-2`)
- `-WaitBetweenDeploys`: Segundos de espera entre despliegues (default: 30)

### 2. `deploy-single.ps1`
Despliegue individual de un stack específico.

```powershell
.\deploy-single.ps1 -Student A -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
```

**Parámetros:**
- `-Student`: Alumno (A, B, C, D, E) (obligatorio)
- `-AdminCidr`: CIDR administrativo (obligatorio)
- `-BudgetEmail`: Email para alertas (obligatorio)
- `-Region`: Región AWS (default: `eu-south-2`)
- `-KeyPairName`: Nombre custom de key pair (si no usa patrón estándar)

### 3. `delete-stack.ps1`
Eliminar un stack de CloudFormation.

```powershell
.\delete-stack.ps1 -Student A
```

**Parámetros:**
- `-Student`: Alumno (A, B, C, D, E) (obligatorio)
- `-Region`: Región AWS (default: `eu-south-2`)
- `-Confirm`: Pedir confirmación antes de eliminar (default: true)

### 4. `get-stack-info.ps1`
Obtener información de un stack desplegado.

```powershell
.\get-stack-info.ps1 -Student A
```

**Parámetros:**
- `-Student`: Alumno (A, B, C, D, E) (obligatorio)
- `-Region`: Región AWS (default: `eu-south-2`)
- `-ShowOutputs`: Mostrar outputs del stack (default: true)

### 5. `export-stack-outputs.ps1`
Exportar los outputs de todos los stacks a un archivo.

```powershell
.\export-stack-outputs.ps1 -OutputFile "stack-outputs.json"
```

**Parámetros:**
- `-OutputFile`: Archivo donde guardar los outputs (default: `stack-outputs.json`)
- `-Region`: Región AWS (default: `eu-south-2`)
- `-Format`: Formato de salida (json, csv, txt) (default: json)

## Configuración previa

1. **AWS CLI y PowerShell**
   ```powershell
   # Verificar AWS CLI
   aws --version
   
   # Verificar perfiles configurados
   aws configure list-profiles
   ```

2. **Key pairs en cada cuenta**
   ```powershell
   # Crear key pair (si no existe)
   aws ec2 create-key-pair --key-name dt-a-key --query 'KeyMaterial' --output text > dt-a-key.pem
   ```

3. **IP administrativa**
   ```powershell
   # Obtener IP pública
   (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
   ```

## Ejemplos de uso

### Despliegue completo
```powershell
# Desplegar todas las 5 cuentas
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "equipo@domain.com"

# Desplegar con espera más larga entre stacks
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "equipo@domain.com" -WaitBetweenDeploys 60
```

### Despliegue selectivo
```powershell
# Desplegar solo Stack A (AD + Client)
.\deploy-single.ps1 -Student A -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"

# Desplegar solo Stack B (LB + DB)
.\deploy-single.ps1 -Student B -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
```

### Consultar estado
```powershell
# Ver información del Stack C
.\get-stack-info.ps1 -Student C

# Exportar todos los outputs
.\export-stack-outputs.ps1 -OutputFile "despliegue-outputs.json"
```

### Eliminación
```powershell
# Eliminar Stack A con confirmación
.\delete-stack.ps1 -Student A

# Eliminar Stack A sin confirmación
.\delete-stack.ps1 -Student A -Confirm $false
```

## Troubleshooting

### Error: "The user with id arn:aws:iam::... is not authorized"
- Verifica que el perfil AWS está configurado con credenciales válidas
- Comprueba que tienes permisos IAM en CloudFormation, EC2, IAM, S3 y Budgets

### Error: "Key pair not found"
- Asegúrate de crear las key pairs en cada cuenta antes de desplegar
- Usa el parámetro `-KeyPairName` si el nombre es diferente al esperado

### Error: "VPC CIDR already exists"
- Puede ser que haya una VPC previa con el mismo CIDR
- Modifica el parámetro `VpcCidr` en el template o elimina la VPC anterior

### Stack se queda en "CREATE_IN_PROGRESS"
- Espera 5-10 minutos adicionales
- Revisa los eventos del stack con CloudFormation Console
- Cancela y reinicia si es necesario

## Notas

- Los scripts esperan que AWS CLI esté instalado y configurado
- Se requiere PowerShell 5.1 o superior
- Todos los comandos incluyen validación de parámetros
- Los scripts son idempotentes donde es posible

## Relacionado

Ver [README.md](README.md) para más detalles sobre templates y parámetros.
