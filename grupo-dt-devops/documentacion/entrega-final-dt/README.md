# Entrega final — Grupo DT

Esta carpeta contiene la documentación final de la práctica en formato DevOps, alineada con la rúbrica y con la solución base propuesta por Alex.

## Archivos incluidos
- `MEMORIA_TECNICA_DT.md` → memoria técnica completa para entregar.
- `CHECKLIST_EVIDENCIAS_DT.md` → lista de evidencias y capturas que debéis adjuntar.
- `GUION_DEFENSA_DT.md` → guion breve para defensa oral en clase.
- `PLAN_EJECUCION_5_CUENTAS_ESTRICTO.md` → plan operativo estricto por rúbrica (despliegue por cuenta individual).

## Equipo
- Alejandro (Alumno A)
- Nicolás (Alumno B)
- Mario (Alumno C)
- Gonzalo (Alumno D)
- Jesús (Alumno E)

## Proyecto
Repositorio de trabajo: `grupo-dt-devops/`

## Paso a paso minimo obligatorio (cuentas nuevas)

Este bloque resume lo minimo que pide la rubrica para poder empezar desde cero.

### 1. Minimo previo por cada cuenta AWS

Cada alumno debe tener en su propia cuenta:

1. Un usuario IAM operativo (no usar root para desplegar).
2. Una key pair EC2 creada en la region eu-south-2.
3. Un perfil AWS CLI configurado en su equipo.
4. Budget habilitado (puede crearlo la plantilla o tenerlo ya creado).

Perfiles esperados:

1. AlejandroA
2. NicolasB
3. MarioC
4. GonzaloD
5. JesusE

Validacion rapida por perfil:

	aws sts get-caller-identity --profile AlejandroA
	aws sts get-caller-identity --profile NicolasB
	aws sts get-caller-identity --profile MarioC
	aws sts get-caller-identity --profile GonzaloD
	aws sts get-caller-identity --profile JesusE

### 2. Despliegue de infraestructura CloudFormation

Opcion recomendada (todo en un solo comando):

	Set-Location <ruta-del-repo>\grupo-dt-devops
	.\scripts\strict5-deploy-all.ps1 -Region eu-south-2 -AdminCidr <TU_IP_PUBLICA>/32 -BudgetEmail <EMAIL_ALERTAS> -KeyPairA <KEYPAIR_A> -KeyPairB <KEYPAIR_B> -KeyPairC <KEYPAIR_C> -KeyPairD <KEYPAIR_D> -KeyPairE <KEYPAIR_E>

Si preferis por alumno, usar los comandos del archivo cloudformation/strict-5/README.md.

### 3. Exportar outputs de los 5 stacks

	.\scripts\strict5-export-outputs.ps1 -Region eu-south-2

### 4. Integrar cuentas (peering y rutas)

Primero simulacion:

	.\scripts\strict5-integrate-peerings.ps1 -Region eu-south-2 -WhatIfOnly

Luego ejecucion real:

	.\scripts\strict5-integrate-peerings.ps1 -Region eu-south-2

### 5. Minimo de validacion para considerar cumplimiento

Cada alumno debe poder demostrar:

1. Recursos creados en su cuenta (VPC, SG, EC2, EIP y Budget).
2. Funcionalidad de su rol (A AD/cliente, B LB+DB, C-D-E web por modulo).
3. Integracion intercuenta operativa (conectividad real y probada).
4. Outputs y evidencias guardadas.

### 6. Archivos de referencia

1. Plan estricto por rubrica: PLAN_EJECUCION_5_CUENTAS_ESTRICTO.md
2. Runbook E2E: RUNBOOK_E2E_5_CUENTAS.md
3. Plantillas CloudFormation: ../../cloudformation/strict-5/
4. Scripts de automatizacion: ../../scripts/
