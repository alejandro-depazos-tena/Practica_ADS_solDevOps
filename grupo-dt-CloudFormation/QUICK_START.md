# Quick reference - Comandos más usados

## Configuración inicial
```powershell
# Configurar perfiles AWS
aws configure --profile AlejandroA
aws configure --profile NicolasB
aws configure --profile MarioC
aws configure --profile GonzaloD
aws configure --profile JesusE

# Crear key pairs
aws ec2 create-key-pair --key-name dt-a-key --region eu-south-2 --profile AlejandroA | Out-File dt-a-key.pem
```

## Despliegue
```powershell
# Despliegue completo
.\deploy-all.ps1 -AdminCidr "$ip/32" -BudgetEmail "admin@example.com"

# Despliegue individual
.\deploy-single.ps1 -Student A -AdminCidr "$ip/32" -BudgetEmail "admin@example.com"
```

## Verificación
```powershell
# Ver estado de un stack
.\get-stack-info.ps1 -Student A

# Exportar todos los outputs
.\export-stack-outputs.ps1 -OutputFile outputs.json

# Ver eventos de CloudFormation
aws cloudformation describe-stack-events --stack-name dt-a-ad-client --profile AlejandroA
```

## Limpieza
```powershell
# Eliminar un stack
.\delete-stack.ps1 -Student A

# Eliminar todos
foreach ($s in "A", "B", "C", "D", "E") { .\delete-stack.ps1 -Student $s -Confirm $false }
```

## Obtener datos
```powershell
# Tu IP pública
(Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content

# IPs de instancias
aws ec2 describe-instances --profile AlejandroA --region eu-south-2 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text

# Listar perfiles
aws configure list-profiles

# Validar perfil
aws sts get-caller-identity --profile AlejandroA
```

Ver documentación completa en docs/
