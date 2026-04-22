# Runbook E2E - 5 cuentas (modo estricto)

## 1) Prerrequisitos del equipo

1. AWS CLI instalado y en PATH.
2. Ansible instalado y en PATH.
3. Perfiles AWS operativos: AlejandroA, NicolasB, MarioC, GonzaloD, JesusE.
4. Key pair creada en cada cuenta.

## 2) Despliegue de infraestructura por CloudFormation

Opción rápida (todo en bloque):

```powershell
Set-Location <ruta-repo>
./scripts/strict5-deploy-all.ps1 `
  -Region eu-south-2 `
  -AdminCidr <IP_PUBLICA>/32 `
  -BudgetEmail <EMAIL_ALERTAS> `
  -KeyPairA <KEYPAIR_A> `
  -KeyPairB <KEYPAIR_B> `
  -KeyPairC <KEYPAIR_C> `
  -KeyPairD <KEYPAIR_D> `
  -KeyPairE <KEYPAIR_E>
```

Opción individual: ver `cloudformation/strict-5/README.md`.

## 3) Exportar outputs

```powershell
./scripts/strict5-export-outputs.ps1 -Region eu-south-2
```

## 4) Integración intercuenta (peering + rutas)

```powershell
./scripts/strict5-integrate-peerings.ps1 -Region eu-south-2
```

Simulación:

```powershell
./scripts/strict5-integrate-peerings.ps1 -Region eu-south-2 -WhatIfOnly
```

## 5) Provisioning y despliegue de servicios

1. Cargar secretos requeridos para AD/PostgreSQL/S3.
2. Ejecutar provision completo:

```powershell
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/update_inventory.yml
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/setup_ad_dns_ntp.yml
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/configure_dns_clients.yml
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/setup_python_venv.yml
ansible-playbook -i ansible/inventory/aws_inventory.sh ansible/playbooks/deploy_app.yml
```

## 6) Validación funcional

1. `/profesores`
2. `/alumnos`
3. `/practicas`
4. AD + DHCP + GPO + cliente dominio
5. PostgreSQL + backup/restore

## 7) Evidencias

Completar:

- `documentacion/entrega-final-dt/CHECKLIST_EVIDENCIAS_DT.md`
- `documentacion/entrega-final-dt/DRP_DT.md`
