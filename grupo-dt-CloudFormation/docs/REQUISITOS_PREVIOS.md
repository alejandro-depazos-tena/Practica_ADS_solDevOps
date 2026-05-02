# Requisitos Previos

Lista de requisitos necesarios antes de comenzar el despliegue CloudFormation.

## Hardware / Entorno

- **SO**: Windows 10+ o macOS / Linux (con PowerShell Core)
- **Memoria**: 2GB mínimo
- **Conexión**: Internet (no requiere ancho de banda especial)

## Software obligatorio

### 1. AWS CLI v2

**Descargar:**
- Windows: https://awscli.amazonaws.com/AWSCLIV2.msi
- macOS: `brew install awscli`
- Linux: `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" | unzip -`

**Verificar:**
```powershell
aws --version
# Debe mostrar: aws-cli/2.x.x
```

### 2. PowerShell 5.1 o superior

**Instalado por defecto en:**
- Windows 10 / 11
- Windows Server 2016+

**Verificar:**
```powershell
$PSVersionTable.PSVersion
# Debe mostrar: Major: 5, Minor: 1 (o superior)
```

**En Mac/Linux:** Instalar PowerShell Core
```bash
brew install powershell  # macOS
sudo apt-get install powershell  # Ubuntu/Debian
```

### 3. Acceso AWS

**Necesitas:**
- 5 Cuentas AWS (una por alumno)
- Access Key + Secret Access Key para cada cuenta
- Región: `eu-south-2` (disponible y asequible)

**Verificar acceso:**
```powershell
aws sts get-caller-identity
# Debe mostrar: UserId, Account, Arn
```

## Configuración previa

### 1. Perfiles AWS

Ejecutar para cada cuenta:
```powershell
aws configure --profile AlejandroA
aws configure --profile NicolasB
aws configure --profile MarioC
aws configure --profile GonzaloD
aws configure --profile JesusE
```

**Ingresa para cada uno:**
- AWS Access Key ID: `AKIA...`
- AWS Secret Access Key: `wJal...`
- Default region name: `eu-south-2`
- Default output format: `json`

**Verificar:**
```powershell
aws configure list-profiles
# Debe listar todos 5 perfiles
```

### 2. Key pairs EC2

Crear una key pair en cada cuenta/región:

```powershell
# Cuenta A
aws ec2 create-key-pair `
    --key-name dt-a-key `
    --region eu-south-2 `
    --profile AlejandroA `
    | Out-File -Encoding UTF8 dt-a-key.pem

# Repetir para B, C, D, E
```

O crear desde consola AWS:
1. Ir a EC2 → Key Pairs
2. Create Key Pair → Nombre: `dt-x-key`
3. Guardar `.pem` en carpeta segura

### 3. Permisos IAM

Cada cuenta necesita que el usuario tenga políticas:

**Mínimo requerido:**
- `CloudFormationFullAccess` (o `CloudFormationAdministrator`)
- `EC2FullAccess` (o permisos específicos)
- `IAMFullAccess` (para roles de S3)
- `AmazonS3FullAccess` (para buckets de almacenamiento)
- `AWBudgetsFullAccess` (para presupuestos)

**Verificar:**
```powershell
# Ver políticas del usuario actual
aws iam list-attached-user-policies --user-name <USERNAME> --profile AlejandroA
```

## Configuración de red

### IP administrativa

Necesitas la **IP pública desde la que te conectarás** a las instancias:

```powershell
# Obtener tu IP
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
Write-Host "Tu IP: $myIp/32"

# Guardar como variable
$AdminCidr = "$myIp/32"
```

**Importante:** Si tu IP cambia (dinámica), necesitarás:
- Obtener la nueva IP
- Actualizar Security Groups en CloudFormation

### Email para alertas

Tener un email válido para recibir alertas de presupuesto:
```powershell
$BudgetEmail = "tu-email@empresa.com"
```

## Límites de servicio

Verificar que la cuenta tiene capacidad:

```powershell
# Límite de instancias EC2 por región (default: 20)
aws service-quotas list-service-quotas `
    --service-code ec2 `
    --region eu-south-2 `
    --profile AlejandroA

# Debe mostrar: Running On-Demand instances ≥ 10 (para t3.micro)
```

**Si el límite es bajo (<10):**
- Crear ticket con AWS Support
- O cambiar `InstanceType` a `t2.micro` (menos disponible pero más barato)

## Permisos a nivel de carpeta

Scripts necesitan permisos de lectura/escritura:

```powershell
# Verificar permisos de carpeta
Get-Acl .\grupo-dt-CloudFormation\

# Corregir si es necesario
icacls .\grupo-dt-CloudFormation\ /grant:r "%username%:(F)" /inheritance:e /t
```

## PowerShell execution policy

Si los scripts no ejecutan:

```powershell
# Ver política actual
Get-ExecutionPolicy

# Cambiar a RemoteSigned (para desarrollo local)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# O solo para este script
powershell -ExecutionPolicy Bypass -File .\script.ps1
```

## Checklist de requisitos

- [ ] AWS CLI v2 instalado
- [ ] PowerShell 5.1+ disponible
- [ ] 5 perfiles AWS configurados
- [ ] Credenciales válidas (sin expiración)
- [ ] 5 key pairs creados en eu-south-2
- [ ] Permisos IAM verificados
- [ ] IP pública obtenida
- [ ] Email para alertas disponible
- [ ] Límites de servicio ok
- [ ] Scripts con permisos de ejecución

## Costos estimados

| Recurso | Por hora | Por día | Por mes |
|---------|----------|---------|----------|
| Windows t3.micro | \$0.10 | \$2.40 | \$72 |
| Linux t3.micro | \$0.02 | \$0.48 | \$14 |
| Elastic IP | \$0.05 | \$1.20 | \$36 |
| Data transfer | ~\$0.01 | ~\$0.24 | ~\$7 |
| **Total (5 cuentas)** | ~\$0.18 | ~\$4.32 | ~\$129 |

*Nota: Presupuestos en templates pueden detener instancias si se supera límite*

## Soporte

Si tienes problemas:

1. Revisa [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Consulta [DESPLIEGUE_CLOUDFORMATION.md](DESPLIEGUE_CLOUDFORMATION.md)
3. Revisa logs en CloudFormation Console
4. Contacta al administrador

## Siguiente paso

Cuando todos los requisitos estén listos → [DESPLIEGUE_CLOUDFORMATION.md](DESPLIEGUE_CLOUDFORMATION.md)
