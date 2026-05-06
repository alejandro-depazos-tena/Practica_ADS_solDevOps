# Grupo DT - Solucion entregada con CloudFormation

Esta carpeta contiene la solucion final entregada para la practica ADS.

El despliegue real se ha realizado principalmente con:

- AWS CloudFormation para crear la infraestructura de cada alumno.
- AWS CLI para lanzar y validar stacks.
- Scripts PowerShell para exportar informacion de red y aplicar VPC Peering.
- Configuracion manual controlada para Nginx, PostgreSQL y los modulos web.

La propuesta DevOps con Ansible/Jenkins se conserva aparte en `../grupo-dt-devops`, pero no forma parte del flujo ejecutado finalmente por falta de tiempo y por complejidad adicional.

## Arquitectura

La practica se organiza en cinco cuentas/alumnos:

- Alumno A: Windows Server, Active Directory, DNS, DHCP y cliente Windows.
- Alumno B: Load Balancer Nginx y base de datos PostgreSQL.
- Alumno C: modulo web `/profesores/`.
- Alumno D: modulo web `/alumnos/`.
- Alumno E: modulo web `/practicas/`, gestion de entregas e integracion con S3.

Cada alumno despliega su propia infraestructura en una VPC independiente. La comunicacion entre VPCs se realiza mediante VPC Peering y rutas privadas.

## Estructura

```text
grupo-dt-CloudFormation/
  cloudformation/
    strict-5/
      stack-A-ad-client.yaml
      stack-B-lb-db.yaml
      stack-C-web-upstream1.yaml
      stack-D-web-upstream2.yaml
      stack-E-web-upstream3.yaml
  scripts/
    peering-distribuido/
      run-A-peering.ps1
      run-B-peering.ps1
      run-C-peering.ps1
      run-D-peering.ps1
      run-E-peering.ps1
      strict5-team-topology.json
      exports/
  app/
    ufv-app/
      node/
  README.md
```

## Plantillas CloudFormation

Las plantillas finales estan en:

`cloudformation/strict-5/`

Stacks principales:

- `stack-A-ad-client.yaml`: infraestructura Windows del Alumno A.
- `stack-B-lb-db.yaml`: Load Balancer y PostgreSQL del Alumno B.
- `stack-C-web-upstream1.yaml`: servidores web del Alumno C.
- `stack-D-web-upstream2.yaml`: servidores web del Alumno D.
- `stack-E-web-upstream3.yaml`: servidores web del Alumno E.

## Peering distribuido

Los scripts de peering usados para conectar las VPCs estan en:

`scripts/peering-distribuido/`

Flujo usado:

1. Cada alumno exporta la informacion de su stack con `strict5-export-local-network-info.ps1`.
2. Se recopilan los JSON de `exports/`.
3. Se genera o actualiza `strict5-team-topology.json`.
4. Cada alumno ejecuta su script:
   - `run-A-peering.ps1`
   - `run-B-peering.ps1`
   - `run-C-peering.ps1`
   - `run-D-peering.ps1`
   - `run-E-peering.ps1`

Estos scripts crean o aceptan peerings y actualizan las rutas necesarias en cada cuenta.

## Aplicacion web

El codigo de aplicacion usado como referencia esta en:

`app/ufv-app/node/`

Incluye:

- Backends Node.js.
- Frontends HTML.
- Modulos:
  - `profesores`
  - `alumnos`
  - `practicas`

El modulo del Alumno E se encuentra principalmente en:

- `app/ufv-app/node/practicas.js`
- `app/ufv-app/node/practicas.html`

## Comandos principales

Ejemplo de despliegue del Alumno E:

```powershell
aws cloudformation deploy `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3 `
  --template-file cloudformation/strict-5/stack-E-web-upstream3.yaml `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    KeyPairName=dt-e-key `
    AdminCidr=<TU_IP_PUBLICA>/32 `
    LbVpcCidr=10.20.0.0/16 `
    BudgetEmail=<EMAIL>
```

Ejemplo de ejecucion de peering del Alumno E:

```powershell
cd scripts/peering-distribuido
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology.json
```

## Seguridad

No se deben subir a la entrega:

- Ficheros `.pem`.
- Ficheros `.env`.
- Access Keys.
- Secret Access Keys.
- Contrasenas sin enmascarar.

El `.gitignore` raiz ya excluye:

- `*.pem`
- `*.key`
- `.env`

## Estado final

La solucion funcional validada fue:

- Cliente Windows accede mediante `www.corp.ufv.local`.
- DNS corporativo apunta al Load Balancer del Alumno B.
- Load Balancer enruta:
  - `/profesores/` a C.
  - `/alumnos/` a D.
  - `/practicas/` a E.
- Los modulos consumen PostgreSQL central en B.
- El modulo E usa S3 con bucket versionado e IAM Role.
