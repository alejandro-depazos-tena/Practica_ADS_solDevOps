# Runbook E2E propuesto - 5 cuentas

Este runbook describe como se habria ejecutado la automatizacion DevOps completa. Se conserva como ampliacion tecnica, no como procedimiento final usado en la entrega.

## 1. Prerrequisitos

- AWS CLI instalado.
- Perfiles AWS configurados:
  - `AlejandroA`
  - `NicolasB`
  - `MarioC`
  - `GonzaloD`
  - `JesusE`
- Key pair creada en cada cuenta.
- Ansible instalado.
- Jenkins o GitHub Actions configurado.
- Secretos cargados como variables de entorno o credenciales del pipeline.

## 2. Despliegue CloudFormation

Cada alumno desplegaria su stack desde `cloudformation/strict-5/`.

Ejemplo:

```powershell
aws cloudformation deploy `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3 `
  --template-file cloudformation/strict-5/stack-E-web-upstream3.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=<KEYPAIR_E> `
    AdminCidr=<IP_PUBLICA>/32 `
    LbVpcCidr=10.20.0.0/16 `
    BudgetEmail=<EMAIL_ALERTAS>
```

## 3. Exportacion de red y peering

Cada alumno exportaria su informacion de red:

```powershell
powershell -ExecutionPolicy Bypass -File .\strict5-export-local-network-info.ps1 `
  -AccountKey E `
  -Profile JesusE `
  -Stack dt-e-web-u3 `
  -Region eu-south-2
```

Despues se fusionarian los exports y cada alumno ejecutaria su `run-<LETRA>-peering.ps1`.

## 4. Provisioning con Ansible

La idea era ejecutar playbooks para:

- Configurar AD, DNS y NTP.
- Configurar clientes DNS.
- Preparar Python/Node.
- Instalar y configurar PostgreSQL.
- Desplegar aplicaciones.
- Configurar Nginx.

Ejemplo:

```powershell
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/deploy_app.yml
```

## 5. Validacion

Validaciones previstas:

- Stacks en `CREATE_COMPLETE`.
- Peerings activos.
- Rutas privadas creadas.
- Nginx activo.
- PostgreSQL escuchando en `5432`.
- Modulos accesibles:
  - `/profesores/`
  - `/alumnos/`
  - `/practicas/`
- S3 accesible mediante IAM Role.

## Estado final

Este runbook queda como referencia de mejora futura. La ejecucion real validada se documento y ordeno en `../../grupo-dt-CloudFormation`.

