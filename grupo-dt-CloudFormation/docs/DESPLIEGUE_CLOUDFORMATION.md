# Despliegue CloudFormation - Paso a Paso

Guía detallada para desplegar toda la arquitectura usando CloudFormation.

## Fase 1: Preparación (15 minutos)

### 1.1 Verificar AWS CLI

```powershell
# Verificar instalación
aws --version

# Debe mostrar: aws-cli/2.x.x
```

Si no está instalado, descárgalo desde https://aws.amazon.com/cli/

### 1.2 Configurar perfiles AWS

```powershell
# Crear perfil para Alejandro (Cuenta A)
aws configure --profile AlejandroA
# Ingresa: Access Key, Secret Key, región (eu-south-2), formato (json)

# Repetir para los otros 4
aws configure --profile NicolasB
aws configure --profile MarioC
aws configure --profile GonzaloD
aws configure --profile JesusE
```

### 1.3 Verificar perfiles

```powershell
# Listar todos
aws configure list-profiles

# Probar cada uno
aws sts get-caller-identity --profile AlejandroA
aws sts get-caller-identity --profile NicolasB
# ... etc

# Todos deben mostrar AccountId, UserId, Arn
```

### 1.4 Crear/Verificar key pairs EC2

```powershell
# Verificar key pairs existentes
aws ec2 describe-key-pairs --profile AlejandroA --region eu-south-2

# Si no existen, crear
aws ec2 create-key-pair `
    --key-name dt-a-key `
    --region eu-south-2 `
    --profile AlejandroA `
    | Out-File -Encoding UTF8 dt-a-key.pem

# Repetir para B, C, D, E
aws ec2 create-key-pair --key-name dt-b-key --region eu-south-2 --profile NicolasB
aws ec2 create-key-pair --key-name dt-c-key --region eu-south-2 --profile MarioC
aws ec2 create-key-pair --key-name dt-d-key --region eu-south-2 --profile GonzaloD
aws ec2 create-key-pair --key-name dt-e-key --region eu-south-2 --profile JesusE

# Proteger archivos (opcional)
icacls dt-a-key.pem /grant:r "%username%:F"
icacls dt-a-key.pem /inheritance:r
```

### 1.5 Obtener IP administrativa

```powershell
# Tu IP pública (desde donde accederás RDP/SSH)
$adminIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
Write-Host "Tu IP pública: $adminIp"

# Guardar como variable para luego
$AdminCidr = "$adminIp/32"
$BudgetEmail = "tu-email@empresa.com"
```

## Fase 2: Despliegue (30-45 minutos)

### 2.1 Opción A: Despliegue completo (recomendado)

```powershell
# Navegar a carpeta scripts
cd .\grupo-dt-CloudFormation\scripts\

# Ejecutar despliegue completo
.\deploy-all.ps1 `
    -AdminCidr $AdminCidr `
    -BudgetEmail $BudgetEmail `
    -WaitBetweenDeploys 60

# Esperar a que se complete (10-15 minutos)
```

**Qué hace:**
1. Valida perfiles AWS
2. Despliega Stack A (AD + Client) → espera
3. Despliega Stack B (LB + DB) → espera
4. Despliega Stack C (Web Profesores) → espera
5. Despliega Stack D (Web Alumnos) → espera
6. Despliega Stack E (Web Prácticas)

### 2.2 Opción B: Despliegue individual (debugging)

```powershell
cd .\grupo-dt-CloudFormation\scripts\

# Desplegar Solo Stack A
.\deploy-single.ps1 `
    -Student A `
    -AdminCidr $AdminCidr `
    -BudgetEmail $BudgetEmail

# Verificar antes de continuar
.\get-stack-info.ps1 -Student A

# Luego Stack B
.\deploy-single.ps1 -Student B -AdminCidr $AdminCidr -BudgetEmail $BudgetEmail
# ... etc
```

## Fase 3: Verificación (10 minutos)

### 3.1 Ver estado de stacks

```powershell
# Información del Stack A
.\get-stack-info.ps1 -Student A

# Debe mostrar:
# - StackName: dt-a-ad-client
# - StackStatus: CREATE_COMPLETE (o UPDATE_COMPLETE)
# - Resources creados
# - Outputs (VPC ID, Security Groups, IPs)
```

### 3.2 Exportar outputs

```powershell
# Guardar todos los outputs en JSON
.\export-stack-outputs.ps1 `
    -OutputFile "despliegue-outputs.json" `
    -Format json

# Revisar archivo
Get-Content .\despliegue-outputs.json

# Formatos alternativos
.\export-stack-outputs.ps1 -OutputFile "outputs.csv" -Format csv
.\export-stack-outputs.ps1 -OutputFile "outputs.txt" -Format txt
```

### 3.3 Verificar recursos en consola AWS

```powershell
# Listar EC2 en Cuenta A
aws ec2 describe-instances `
    --profile AlejandroA `
    --region eu-south-2 `
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value | [0],State.Name,PublicIpAddress]' `
    --output table

# Debe mostrar:
# - DT-A-DC01 (running)
# - DT-A-WINCLIENT01 (running)
```

## Fase 4: Próximos pasos

### 4.1 Peering entre VPCs (futuro)

```powershell
# Los scripts de peering están en:
# ../grupo-dt-devops/scripts/strict5-distributed-peerings/

# Por ahora: cada VPC está aislada (es normal)
```

### 4.2 Provisioning (Ansible - futuro)

```powershell
# Una vez las VPCs estén conectadas por peering:
# 1. Configurar AD en Windows (Stack A)
# 2. Configurar LB + DB (Stack B)
# 3. Configurar Web servers (Stacks C, D, E)

# Usa los playbooks de ../grupo-dt-devops/ansible/
```

## Troubleshooting durante despliegue

### ❌ Error: "AccessDenied" en CloudFormation

**Causa:** Permisos IAM insuficientes  
**Solución:**
```powershell
# Verifica que el perfil tenga permisos:
# - cloudformation:*
# - ec2:*
# - iam:*
# - s3:*
# - budgets:*

# Test: intenta crear un VPC manualmente
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --profile AlejandroA
aws ec2 delete-vpc --vpc-id vpc-xxxxx --profile AlejandroA
```

### ❌ Error: "Key pair not found"

**Causa:** Key pair no existe en esa cuenta/región  
**Solución:**
```powershell
# Crear el key pair
aws ec2 create-key-pair `
    --key-name dt-a-key `
    --region eu-south-2 `
    --profile AlejandroA
```

### ❌ Error: "VPC CIDR already exists"

**Causa:** Ya existe una VPC con ese CIDR  
**Solución:**
```powershell
# Opción 1: Eliminar VPC antigua
aws ec2 delete-vpc --vpc-id vpc-xxxxx --profile AlejandroA

# Opción 2: Cambiar CIDR en template (no recomendado)
```

### ⏳ Stack se queda en "CREATE_IN_PROGRESS"

**Causa:** Algo se quedó esperando  
**Solución:**
```powershell
# Esperar 10 minutos
Start-Sleep -Seconds 600

# Ver eventos
aws cloudformation describe-stack-events `
    --profile AlejandroA `
    --region eu-south-2 `
    --stack-name dt-a-ad-client `
    --query 'StackEvents[0:10]'

# Si sigue bloqueado: cancelar y recrear
aws cloudformation cancel-update-stack --stack-name dt-a-ad-client --profile AlejandroA
Start-Sleep -Seconds 30

# Reintentar despliegue
.\deploy-single.ps1 -Student A -AdminCidr $AdminCidr -BudgetEmail $BudgetEmail
```

## Checklist de despliegue

- [ ] AWS CLI instalado y en PATH
- [ ] 5 perfiles AWS configurados
- [ ] AWS credentials válidas (sin expiración)
- [ ] 5 key pairs creados en eu-south-2
- [ ] IP pública obtenida
- [ ] Email para alertas disponible
- [ ] Scripts PowerShell en modo sin restricciones (si es necesario)
- [ ] Deploy A, B, C, D, E completados
- [ ] Todos los stacks en estado "CREATE_COMPLETE"
- [ ] Outputs exportados a JSON/CSV
- [ ] Presupuestos creados (opcional)
- [ ] Recurso cost de instancias visibles en AWS Console

## Siguientes pasos

1. **Peering** (15 min): Conectar VPCs entre cuentas
2. **Provisioning** (30 min): Configurar AD, DNS, DB, Apps
3. **Testing** (15 min): Validar conectividad E2E
4. **Documentación** (10 min): Registrar outputs y IPs

## Soporte

Si algo no funciona:

1. Revisa [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Consulta logs en CloudFormation Console
3. Revisa [scripts/README.md](../scripts/README.md) para sintaxis de scripts
