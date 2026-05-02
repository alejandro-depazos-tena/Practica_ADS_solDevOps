# CloudFormation estricto por 5 cuentas

Este directorio contiene plantillas CloudFormation separadas por alumno para cumplir la rúbrica con despliegue por cuenta individual.

## Plantillas

- `stack-A-ad-client.yaml` → Alumno A (AD + Windows cliente)
- `stack-B-lb-db.yaml` → Alumno B (LB + DB)
- `stack-C-web-upstream1.yaml` → Alumno C (2 web para location/upstream 1)
- `stack-D-web-upstream2.yaml` → Alumno D (2 web para location/upstream 2)
- `stack-E-web-upstream3.yaml` → Alumno E (2 web para location/upstream 3)

## Despliegue por alumno

Ejecutar cada comando con su propio perfil y key pair:

### Alumno A (AD + Client Windows)
```bash
aws cloudformation deploy \
  --profile AlejandroA \
  --region eu-south-2 \
  --stack-name dt-a-ad-client \
  --template-file cloudformation/strict-5/stack-A-ad-client.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_A> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno B (LB + DB)
```bash
aws cloudformation deploy \
  --profile NicolasB \
  --region eu-south-2 \
  --stack-name dt-b-lb-db \
  --template-file cloudformation/strict-5/stack-B-lb-db.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_B> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno C (Web Upstream 1 - Profesores)
```bash
aws cloudformation deploy \
  --profile MarioC \
  --region eu-south-2 \
  --stack-name dt-c-web-u1 \
  --template-file cloudformation/strict-5/stack-C-web-upstream1.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_C> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32
```

### Alumno D (Web Upstream 2 - Alumnos)
```bash
aws cloudformation deploy \
  --profile GonzaloD \
  --region eu-south-2 \
  --stack-name dt-d-web-u2 \
  --template-file cloudformation/strict-5/stack-D-web-upstream2.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_D> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno E (Web Upstream 3 - Practicas)
```bash
aws cloudformation deploy \
  --profile JesusE \
  --region eu-south-2 \
  --stack-name dt-e-web-u3 \
  --template-file cloudformation/strict-5/stack-E-web-upstream3.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_E> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    BudgetEmail=<EMAIL_ALERTAS>
```

## Requisitos previos

1. **AWS CLI instalado y configurado** con 5 perfiles:
   - `AlejandroA`
   - `NicolasB`
   - `MarioC`
   - `GonzaloD`
   - `JesusE`

2. **Key pairs de EC2** creados en cada cuenta (usar los nombres esperados en parámetros)

3. **Permisos IAM** para:
   - CloudFormation: CreateStack, UpdateStack, DescribeStacks
   - EC2: CreateVpc, CreateSubnet, CreateSecurityGroup, RunInstances, AllocateAddress
   - IAM: CreateRole, CreateInstanceProfile, PutRolePolicy
   - S3: CreateBucket, PutBucketVersioning
   - Budgets: CreateBudget

## Parámetros obligatorios

Para cada despliegue, reemplaza:

- `<KEYPAIR_X>`: Nombre de la key pair EC2 en esa cuenta (ej: `dt-a-key`)
- `<IP_PUBLICA_ADMIN>/32`: IP pública del administrador desde la que se conectará RDP/SSH (ej: `203.0.113.42/32`)
- `<EMAIL_ALERTAS>`: Email para notificaciones de presupuesto

## Monitoreo

Después de cada despliegue:

```bash
# Ver stack
aws cloudformation describe-stacks \
  --profile <PROFILE> \
  --region eu-south-2 \
  --stack-name <STACK_NAME>

# Ver eventos del stack
aws cloudformation describe-stack-events \
  --profile <PROFILE> \
  --region eu-south-2 \
  --stack-name <STACK_NAME>

# Ver recursos creados
aws cloudformation list-stack-resources \
  --profile <PROFILE> \
  --region eu-south-2 \
  --stack-name <STACK_NAME>
```

## Eliminación de stacks

```bash
aws cloudformation delete-stack \
  --profile <PROFILE> \
  --region eu-south-2 \
  --stack-name <STACK_NAME>
```

## Notas

- Los templates usan **Elastic IPs** para acceso remoto consistente
- **Security Groups** están preconfigurados para:
  - RDP/WinRM (Windows)
  - SSH (Linux)
  - Tráfico interno entre VPCs
- **IAM Roles** para S3 en servidores web (acceso scoped)
- **Presupuestos AWS** opcionales con alertas por email
