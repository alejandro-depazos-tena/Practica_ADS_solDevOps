# CloudFormation estricto por 5 cuentas

Este directorio contiene las plantillas CloudFormation separadas por alumno. Es la base de la solucion final desplegada en la practica.

## Plantillas

- `stack-A-ad-client.yaml`: Alumno A, Windows Server AD + cliente Windows.
- `stack-B-lb-db.yaml`: Alumno B, Load Balancer Nginx + PostgreSQL.
- `stack-C-web-upstream1.yaml`: Alumno C, dos Web Servers para `/profesores/`.
- `stack-D-web-upstream2.yaml`: Alumno D, dos Web Servers para `/alumnos/`.
- `stack-E-web-upstream3.yaml`: Alumno E, dos Web Servers para `/practicas/`.

## Despliegue por alumno

Cada alumno despliega su stack con su propio perfil AWS, su propia key pair y su IP administrativa.

### Alumno A

```powershell
aws cloudformation deploy `
  --profile AlejandroA `
  --region eu-south-2 `
  --stack-name dt-a-ad-client `
  --template-file cloudformation/strict-5/stack-A-ad-client.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_A> `
    AdminCidr=<IP_PUBLICA_ADMIN>/32 `
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno B

```powershell
aws cloudformation deploy `
  --profile NicolasB `
  --region eu-south-2 `
  --stack-name dt-b-lb-db `
  --template-file cloudformation/strict-5/stack-B-lb-db.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_B> `
    AdminCidr=<IP_PUBLICA_ADMIN>/32 `
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno C

```powershell
aws cloudformation deploy `
  --profile MarioC `
  --region eu-south-2 `
  --stack-name dt-c-web-u1 `
  --template-file cloudformation/strict-5/stack-C-web-upstream1.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_C> `
    AdminCidr=<IP_PUBLICA_ADMIN>/32
```

### Alumno D

```powershell
aws cloudformation deploy `
  --profile GonzaloD `
  --region eu-south-2 `
  --stack-name dt-d-web-u2 `
  --template-file cloudformation/strict-5/stack-D-web-upstream2.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_D> `
    AdminCidr=<IP_PUBLICA_ADMIN>/32 `
    BudgetEmail=<EMAIL_ALERTAS>
```

### Alumno E

```powershell
aws cloudformation deploy `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3 `
  --template-file cloudformation/strict-5/stack-E-web-upstream3.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_E> `
    AdminCidr=<IP_PUBLICA_ADMIN>/32 `
    LbVpcCidr=10.20.0.0/16 `
    BudgetEmail=<EMAIL_ALERTAS>
```

## Requisitos previos

- AWS CLI instalado.
- Perfiles AWS configurados:
  - `AlejandroA`
  - `NicolasB`
  - `MarioC`
  - `GonzaloD`
  - `JesusE`
- Key pairs EC2 creadas en cada cuenta.
- Permisos IAM suficientes para CloudFormation, EC2, IAM, S3 y Budgets.

## Parametros principales

- `KeyPairName`: nombre de la key pair EC2.
- `AdminCidr`: IP publica administrativa desde la que se permite SSH/RDP.
- `BudgetEmail`: correo de alerta de presupuesto.
- `LbVpcCidr`: CIDR de la VPC del Load Balancer, usado por los alumnos web.

## Verificacion

```powershell
aws cloudformation describe-stacks `
  --profile <PROFILE> `
  --region eu-south-2 `
  --stack-name <STACK_NAME>
```

```powershell
aws cloudformation list-stack-resources `
  --profile <PROFILE> `
  --region eu-south-2 `
  --stack-name <STACK_NAME>
```

## Relacion con el peering

Estas plantillas crean las VPCs y recursos base. La conexion entre VPCs se realiza despues con los scripts de:

`../../scripts/peering-distribuido/`

## Notas

- Las plantillas usan VPCs independientes por alumno.
- Los Web Servers tienen IAM Role para acceso seguro a S3.
- Los Security Groups restringen SSH/RDP mediante `AdminCidr`.
- La comunicacion entre modulos se valida mediante VPC Peering, rutas privadas y Load Balancer.

