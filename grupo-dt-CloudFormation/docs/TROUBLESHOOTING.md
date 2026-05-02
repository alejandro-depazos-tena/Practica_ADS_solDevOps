# Troubleshooting CloudFormation

Diagnóstico y solución de problemas comunes.

## Errores durante configuración

### ❌ "AWS CLI not recognized"

**Síntomas:**
```powershell
aws: The term 'aws' is not recognized
```

**Soluciones:**
1. Instalar AWS CLI v2 desde https://awscli.amazonaws.com/AWSCLIV2.msi
2. Reiniciar PowerShell/Terminal después de instalar
3. Verificar que está en PATH:
```powershell
$env:PATH -split ';' | Select-String 'Program Files'
```

---

### ❌ "The AWS Access Key Id you provided does not exist"

**Síntomas:**
```
An error occurred (InvalidClientTokenId) when calling the GetUser operation: The AWS Access Key Id you provided does not exist in our records.
```

**Soluciones:**
1. Verificar que Access Key es válido:
```powershell
aws sts get-caller-identity --profile AlejandroA
```
2. Si muestra "Invalid": regenerar Access Key
   - AWS Console → IAM → Users → Access Keys → Create
3. Reconfigurar perfil:
```powershell
aws configure --profile AlejandroA
```
4. Verificar que no tiene espacios en blanco:
```powershell
aws configure list --profile AlejandroA
```

---

### ❌ "Profile not found"

**Síntomas:**
```
The config profile (AlejandroA) could not be found
```

**Soluciones:**
1. Verificar que existe:
```powershell
aws configure list-profiles
```
2. Si no aparece: crear perfil
```powershell
aws configure --profile AlejandroA
```
3. Revisar archivo de credenciales:
```powershell
# Windows
notepad "$env:USERPROFILE\.aws\credentials"
notepad "$env:USERPROFILE\.aws\config"

# Mac/Linux
cat ~/.aws/credentials
cat ~/.aws/config
```

---

## Errores de despliegue

### ❌ "An error occurred (InvalidParameterValue) when calling the CreateStack operation: Value of null is invalid for parameter KeyPairName"

**Síntomas:**
```
Invalid parameter value: KeyPairName
```

**Soluciones:**
1. Verificar que key pair existe:
```powershell
aws ec2 describe-key-pairs --profile AlejandroA --region eu-south-2
```
2. Si no existe: crear
```powershell
aws ec2 create-key-pair --key-name dt-a-key --region eu-south-2 --profile AlejandroA
```
3. Verificar nombre en script (sin espacios)
4. Pasar explícitamente si está en path diferente:
```powershell
.\deploy-single.ps1 -Student A -AdminCidr $AdminCidr -BudgetEmail $Email -KeyPairName "mi-key"
```

---

### ❌ "User: arn:aws:iam::123456789:user/xxx is not authorized to perform: cloudformation:CreateStack"

**Síntomas:**
```
AccessDenied: User is not authorized
```

**Soluciones:**
1. Verificar permisos IAM:
```powershell
aws iam list-attached-user-policies --user-name <USERNAME> --profile AlejandroA
```
2. Agregar políticas necesarias:
   - `CloudFormationFullAccess`
   - `EC2FullAccess`
   - `IAMFullAccess`
   - `AmazonS3FullAccess`
   - `AWBudgetsFullAccess`

3. Si acabas de agregar permisos: esperar 1-2 minutos (cache)

---

### ❌ "An error occurred (AlreadyExistsException) when calling the CreateStack operation: Stack with id dt-a-ad-client already exists"

**Síntomas:**
```
Stack already exists
```

**Soluciones:**
1. El stack ya existe. Opciones:
   - Actualizar stack (update en lugar de create):
     ```powershell
     .\deploy-single.ps1 -Student A ...
     # CloudFormation detecta que existe y hace update
     ```
   - Eliminar stack anterior:
     ```powershell
     .\delete-stack.ps1 -Student A
     # Esperar 5 minutos
     .\deploy-single.ps1 -Student A ...
     ```

---

### ❌ "An error occurred (ValidationError) when calling the CreateStack operation: Template format error: unresolved resource dependencies"

**Síntomas:**
```
Template format error
```

**Soluciones:**
1. Verificar que el archivo YAML es válido:
```powershell
# Abrir en editor y revisar indentación
notepad ..\cloudformation\strict-5\stack-A-ad-client.yaml
```
2. No debe haber tabs (solo espacios)
3. Colons deben estar seguidos de espacio
4. Revisar que no falta comilla o bracket

---

### ❌ Stack se queda en "CREATE_IN_PROGRESS"

**Síntomas:**
```powershell
aws cloudformation describe-stacks --stack-name dt-a-ad-client | Select StackStatus
# Muestra: CREATE_IN_PROGRESS por >10 minutos
```

**Soluciones:**
1. **Esperar**: A veces toma 10-15 minutos
2. **Ver eventos**:
```powershell
aws cloudformation describe-stack-events `
    --stack-name dt-a-ad-client `
    --profile AlejandroA `
    --query 'StackEvents[0:20]' `
    --output table
```
3. **Buscar errores**: Cualquier evento con "FAILED" o "ERROR"
4. **Si está realmente atascado**: Cancelar
```powershell
aws cloudformation cancel-update-stack `
    --stack-name dt-a-ad-client `
    --profile AlejandroA
# Esperar 5 minutos
# Reintentar despliegue
```

---

## Errores de red / Security Groups

### ❌ "No puedo conectar por RDP al Windows"

**Síntomas:**
```
Connection refused / Cannot connect
```

**Soluciones:**
1. Verificar que Security Group permite RDP desde tu IP:
```powershell
aws ec2 describe-security-groups `
    --group-ids sg-xxxxx `
    --profile AlejandroA `
    --query 'SecurityGroups[0].IpPermissions' `
    --output table
```
2. Debe haber regla: `Port 3389, Protocol TCP, CIDR: <TU_IP>/32`
3. Si no está: crear regla manually o actualizar template
4. Verificar que tu IP es correcta:
```powershell
(Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
```

---

### ❌ "No puedo conectar por SSH a Linux"

**Síntomas:**
```
Connection refused / timeout
```

**Soluciones:**
1. Verificar key pair y permisos:
```powershell
# Debe existir y ser accesible
Test-Path .\dt-a-key.pem

# Windows: permisos restrictivos
icacls .\dt-a-key.pem /inheritance:r /grant:r "%username%:(F)"
```
2. Obtener IP pública:
```powershell
aws ec2 describe-instances `
    --instance-ids i-xxxxx `
    --profile NicolasB `
    --query 'Reservations[0].Instances[0].PublicIpAddress'
```
3. Intentar SSH:
```powershell
ssh -i .\dt-b-key.pem ubuntu@<IP_PUBLICA>
```
4. Si aún no: esperar 2-3 minutos (instancia puede estar iniciando)

---

## Errores de presupuesto

### ❌ "Budget email not verified"

**Síntomas:**
```
You have not verified this email address for Budget SNS notifications
```

**Soluciones:**
1. Revisar bandeja de email (incluyendo spam)
2. Debe haber email de AWS con confirmación
3. Hacer click en link de confirmación
4. Reintentar despliegue

---

### ❌ "Budget limits not working"

**Síntomas:**
```
No alerts received even after spending limit exceeded
```

**Soluciones:**
1. Verificar que email fue confirmado (ver arriba)
2. Verificar email en AWS Budgets Console
3. Esperar 1 hora (hay delay en alerts)
4. Revisar email spam/junk

---

## Errores de S3 (web servers)

### ❌ "Access Denied to S3 bucket"

**Síntomas:**
```
Access Denied when trying to read/write to S3 bucket
```

**Soluciones:**
1. Verificar que IAM Role está asignado a instancia:
```powershell
aws ec2 describe-instances `
    --instance-ids i-xxxxx `
    --query 'Reservations[0].Instances[0].IamInstanceProfile'
```
2. Si vacío: necesita role (adjuntar en CloudFormation)
3. Verificar permisos del role:
```powershell
aws iam list-attached-role-policies --role-name <ROLE_NAME>
```

---

## Errores de eliminación

### ❌ "Cannot delete stack because it contains resources"

**Síntomas:**
```
The following resource(s) failed to update: [Resource], Reason: ...
```

**Soluciones:**
1. Esperar a que todas las operaciones terminen
2. Revisar eventos para ver qué está bloqueado
3. Si es un Elastic IP: necesita desvincular primero
4. Forzar eliminación (último recurso):
```powershell
# Vaciar S3 buckets primero
aws s3 rm s3://dt-c-web-storage-xxx/ --recursive --profile MarioC

# Luego eliminar stack
aws cloudformation delete-stack --stack-name dt-c-web-u1 --profile MarioC
```

---

## Checklist de debugging

1. ✓ Revisa eventos en consola AWS CloudFormation
2. ✓ Verifica que credenciales no han expirado: `aws sts get-caller-identity`
3. ✓ Asegúrate que estás en región correcta: `eu-south-2`
4. ✓ Comprueba limits de servicio: `aws service-quotas list-service-quotas --service-code ec2`
5. ✓ Revisa logs en CloudWatch (si aplica)
6. ✓ Prueba con `--debug` para más verbosidad:
```powershell
aws cloudformation describe-stacks --debug --profile AlejandroA ...
```

---

## Comandos útiles

```powershell
# Ver todos los stacks
aws cloudformation list-stacks --profile AlejandroA

# Ver eventos de un stack
aws cloudformation describe-stack-events --stack-name dt-a-ad-client --profile AlejandroA

# Ver recursos de un stack
aws cloudformation list-stack-resources --stack-name dt-a-ad-client --profile AlejandroA

# Validar template antes de desplegar
aws cloudformation validate-template --template-body file://..\cloudformation\strict-5\stack-A-ad-client.yaml --profile AlejandroA

# Ver outputs de stack
aws cloudformation describe-stacks --stack-name dt-a-ad-client --profile AlejandroA --query 'Stacks[0].Outputs'
```

---

## Contacto de soporte

Si nada funciona:
1. Recopila: Logs, stack events, ID de stack, región
2. Contacta al administrador del laboratorio
3. Consulta https://docs.aws.amazon.com/cloudformation/latest/userguide/troubleshooting.html
