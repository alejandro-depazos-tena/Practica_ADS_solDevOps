# CloudFormation estricto por 5 cuentas

Este directorio contiene plantillas CloudFormation separadas por alumno para cumplir la rúbrica con despliegue por cuenta individual.

## Plantillas

- `stack-A-ad-client.yaml` -> Alumno A (AD + Windows cliente)
- `stack-B-lb-db.yaml` -> Alumno B (LB + DB)
- `stack-C-web-upstream1.yaml` -> Alumno C (2 web para location/upstream 1)
- `stack-D-web-upstream2.yaml` -> Alumno D (2 web para location/upstream 2)
- `stack-E-web-upstream3.yaml` -> Alumno E (2 web para location/upstream 3)

## Despliegue por alumno

Ejecutar cada comando con su propio perfil y key pair:

```bash
# Alumno A
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

# Alumno B
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

# Alumno C
aws cloudformation deploy \
  --profile MarioC \
  --region eu-south-2 \
  --stack-name dt-c-web-u1 \
  --template-file cloudformation/strict-5/stack-C-web-upstream1.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_C> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    LbVpcCidr=10.20.0.0/16 \
    BudgetEmail=<EMAIL_ALERTAS>

# Alumno D
aws cloudformation deploy \
  --profile GonzaloD \
  --region eu-south-2 \
  --stack-name dt-d-web-u2 \
  --template-file cloudformation/strict-5/stack-D-web-upstream2.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_D> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    LbVpcCidr=10.20.0.0/16 \
    BudgetEmail=<EMAIL_ALERTAS>

# Alumno E
aws cloudformation deploy \
  --profile JesusE \
  --region eu-south-2 \
  --stack-name dt-e-web-u3 \
  --template-file cloudformation/strict-5/stack-E-web-upstream3.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    KeyPairName=<KEYPAIR_E> \
    AdminCidr=<IP_PUBLICA_ADMIN>/32 \
    LbVpcCidr=10.20.0.0/16 \
    BudgetEmail=<EMAIL_ALERTAS>
```

## Outputs que debéis guardar

Cada alumno debe exportar y guardar:

```bash
aws cloudformation describe-stacks --profile <PERFIL> --region eu-south-2 --stack-name <STACK> --query "Stacks[0].Outputs" --output table
```

Estos outputs se usarán para:
- Configurar peering y rutas intercuenta.
- Configurar inventario y despliegue Ansible.
- Adjuntar evidencias de defensa.

## Integración intercuenta (peering + rutas)

Una vez desplegados los 5 stacks, ejecutar:

```powershell
Set-Location <ruta-repo>
./scripts/strict5-integrate-peerings.ps1 -Region eu-south-2
```

Modo simulación (no aplica cambios):

```powershell
./scripts/strict5-integrate-peerings.ps1 -Region eu-south-2 -WhatIfOnly
```

El script crea/acepta peerings necesarios y configura rutas en tablas públicas/privadas para:

- A<->B
- A<->C
- A<->D
- A<->E
- B<->C
- B<->D
- B<->E

Con esto queda habilitada la conectividad base para AD, LB y DB entre cuentas.
