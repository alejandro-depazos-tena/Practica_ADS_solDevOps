# Grupo DT — Práctica AWS con CloudFormation

Infraestructura como código (IaC) para desplegar la solución **Integración de Sistemas en AWS** usando **CloudFormation** de manera standalone, sin necesidad de Jenkins ni Ansible.

## Visión general

Esta carpeta contiene **plantillas CloudFormation reutilizables** para desplegar la arquitectura de 5 cuentas AWS de forma automatizada:

- **Alumno A** (Cuenta Alejandro): AD + Windows Client + LB + DB
- **Alumno B** (Cuenta Nicolás): LB + PostgreSQL
- **Alumno C** (Cuenta Mario): 2 Web Servers (Profesores)
- **Alumno D** (Cuenta Gonzalo): 2 Web Servers (Alumnos)
- **Alumno E** (Cuenta Jesús): 2 Web Servers (Prácticas)

## Estructura

```
grupo-dt-CloudFormation/
├── cloudformation/
│   └── strict-5/
│       ├── stack-A-ad-client.yaml
│       ├── stack-B-lb-db.yaml
│       ├── stack-C-web-upstream1.yaml
│       ├── stack-D-web-upstream2.yaml
│       ├── stack-E-web-upstream3.yaml
│       └── README.md
├── scripts/
│   ├── deploy-all.ps1            # Desplegar todos los stacks
│   ├── deploy-single.ps1         # Desplegar un stack individual
│   ├── get-stack-info.ps1        # Ver información del stack
│   ├── delete-stack.ps1          # Eliminar un stack
│   ├── export-stack-outputs.ps1  # Exportar outputs
│   └── README.md
├── docs/
│   ├── DESPLIEGUE_CLOUDFORMATION.md
│   ├── REQUISITOS_PREVIOS.md
│   └── TROUBLESHOOTING.md
└── README.md (este archivo)
```

## Quick Start

### 1. Requisitos previos

```bash
# Verificar AWS CLI
aws --version

# Verificar perfiles
aws configure list-profiles

# Verificar key pairs
aws ec2 describe-key-pairs --profile AlejandroA --region eu-south-2
```

### 2. Obtener IP administrativa

```powershell
# Desde PowerShell
(Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
```

### 3. Despliegue completo

```powershell
cd .\scripts\
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
```

### 4. Verificar despliegue

```powershell
.\get-stack-info.ps1 -Student A
.\get-stack-info.ps1 -Student B
```

## Características

✅ **Totalmente automatizado**: Sin clicks en consola AWS  
✅ **Reutilizable**: Templates versionables en Git  
✅ **Escalable**: Diseño modular por alumno  
✅ **Observable**: Scripts con feedback en tiempo real  
✅ **Recuperable**: Eliminación limpia y fácil  

## Scripts disponibles

### deploy-all.ps1
Despliegue secuencial de todos los 5 stacks.
```powershell
.\deploy-all.ps1 -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com" -WaitBetweenDeploys 60
```

### deploy-single.ps1
Despliegue individual (útil para debugging).
```powershell
.\deploy-single.ps1 -Student A -AdminCidr "203.0.113.42/32" -BudgetEmail "admin@example.com"
```

### get-stack-info.ps1
Información de un stack (estado, recursos, outputs).
```powershell
.\get-stack-info.ps1 -Student A
```

### delete-stack.ps1
Eliminar un stack de forma segura.
```powershell
.\delete-stack.ps1 -Student A
```

### export-stack-outputs.ps1
Exportar outputs de todos los stacks (JSON, CSV, TXT).
```powershell
.\export-stack-outputs.ps1 -OutputFile "despliegue.json" -Format json
```

## Parámetros clave

Cada template acepta:

| Parámetro | Descripción | Obligatorio |
|-----------|-------------|------------|
| `KeyPairName` | Nombre de la key pair EC2 | Sí |
| `AdminCidr` | CIDR administrativo (RDP/SSH) | Sí |
| `BudgetEmail` | Email para alertas de presupuesto | Sí |
| `VpcCidr` | CIDR de la VPC | No (default configurado) |
| `InstanceType` | Tipo de instancia | No (default: t3.micro) |

Ver [cloudformation/strict-5/README.md](cloudformation/strict-5/README.md) para detalles.

## Flujo de despliegue

1. **Validación** (Pre-flight checks)
   - AWS CLI disponible
   - Perfiles configurados
   - Key pairs creados

2. **Despliegue** (Sequential deployment)
   - Stack A → Espera 30s → Stack B → ... → Stack E
   - Cada stack espera a completarse antes del siguiente

3. **Verificación** (Post-deployment)
   - Ver outputs con `export-stack-outputs.ps1`
   - Conectar a instancias via RDP/SSH
   - Validar conectividad entre VPCs (peering necesario en próximo paso)

## Peering (Próximo paso)

Para conectar las 5 VPCs:
```powershell
# Los scripts de peering están en ../grupo-dt-devops/scripts/strict5-distributed-peerings/
# O configura manualmente en CloudFormation/EC2
```

## Monitoreo

```powershell
# Ver eventos de stack
aws cloudformation describe-stack-events `
    --profile AlejandroA `
    --region eu-south-2 `
    --stack-name dt-a-ad-client

# Ver presupuesto
aws budgets describe-budgets `
    --profile AlejandroA `
    --account-id <ACCOUNT_ID>
```

## Troubleshooting

### Error: "Unresolved tag"
Los linters YAML reportan falsos positivos con `!Ref`, `!GetAtt`. Son válidos en CloudFormation.

### Error: "Key pair not found"
```powershell
# Crear key pair
aws ec2 create-key-pair --key-name dt-a-key --region eu-south-2 --profile AlejandroA
```

### Stack se queda en CREATE_IN_PROGRESS
Espera 10 minutos. Si persiste, revisa eventos en consola CloudFormation.

Ver [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) para más.

## Integración con grupo-dt-devops

Esta carpeta es **independiente** pero compatible con el flujo completo:

```
Opción 1 (Solo CloudFormation):
─────────────────────────────────
grupo-dt-CloudFormation/
  ├─ CloudFormation (despliegue)
  └─ Luego: provisioning manual u Ansible externo

Opción 2 (CloudFormation + Ansible):
──────────────────────────────────────
CloudFormation (crear EC2) → Ansible (configurar)
  ↓
grupo-dt-devops/ansible/
  └─ playbooks/ (setup-ad, deploy-app, etc.)

Opción 3 (Completo DevOps + Jenkins):
────────────────────────────────────────
grupo-dt-devops/
  ├─ CloudFormation (IaC)
  ├─ Ansible (provisioning)
  └─ Jenkins (CI/CD)
```

Ver [grupo-dt-devops/README.md](../grupo-dt-devops/README.md) para flujo completo.

## Documentación

- [DESPLIEGUE_CLOUDFORMATION.md](docs/DESPLIEGUE_CLOUDFORMATION.md): Paso a paso detallado
- [REQUISITOS_PREVIOS.md](docs/REQUISITOS_PREVIOS.md): Configuración previa necesaria
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md): Diagnóstico de errores
- [scripts/README.md](scripts/README.md): Referencia de scripts
- [cloudformation/strict-5/README.md](cloudformation/strict-5/README.md): Referencia de templates

## Ejemplo completo

```powershell
# 1. Configurar perfiles AWS
aws configure --profile AlejandroA
# (repetir para NicolasB, MarioC, GonzaloD, JesusE)

# 2. Crear key pairs
aws ec2 create-key-pair --key-name dt-a-key --profile AlejandroA --region eu-south-2
# (repetir para cada cuenta)

# 3. Obtener IP pública
$adminIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
Write-Host "Tu IP: $adminIp"

# 4. Desplegar
cd scripts
.\deploy-all.ps1 `
  -AdminCidr "$adminIp/32" `
  -BudgetEmail "tu-email@example.com" `
  -WaitBetweenDeploys 60

# 5. Verificar
.\export-stack-outputs.ps1 -OutputFile "outputs.json"

# 6. Conectar a instancias
# RDP: dt-a-dc01 (Windows)
# SSH: dt-b-lb01, etc. (Linux)
```

## Notas

- Templates uso **CloudFormation estándar** (compatible con AWS)
- Scripts en **PowerShell** (Windows 5.1+, también en PowerShell Core)
- Compatible con **AWS CLI v2+**
- Costo estimado: ~\$5-10/día por 5 cuentas (t3.micro)

## Próximos pasos

1. ✅ Desplegar infraestructura (CloudFormation)
2. ⏳ Configurar peering entre VPCs
3. ⏳ Provisioning: AD, DNS, DB, Apps (Ansible o manual)
4. ⏳ Validar conectividad end-to-end

## Relacionado

- [grupo-dt-devops](../grupo-dt-devops/): Solución completa con Ansible + Jenkins
- [AWS CloudFormation Docs](https://docs.aws.amazon.com/cloudformation/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

## Autor

Grupo DT — Práctica ADS 2026

## Licencia

Uso interno — Práctica educativa
