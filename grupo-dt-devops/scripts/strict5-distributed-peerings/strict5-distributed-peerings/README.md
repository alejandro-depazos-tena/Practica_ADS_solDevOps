# Strict 5 distributed peerings

Esta carpeta sirve para crear peerings entre las 5 cuentas sin que una sola persona tenga todos los perfiles AWS.

## Flujo

1. Cada alumno exporta su red a `exports/<LETRA>.json`.
2. Se comparten los JSON entre el equipo.
3. Se fusionan en `strict5-team-topology.json`.
4. Cada alumno ejecuta su `run-<LETRA>-peering.ps1`.

## Exportar datos locales

Alumno E:

```powershell
.\strict5-export-local-network-info.ps1 `
  -AccountKey E `
  -Profile JesusE `
  -Stack dt-e-web-u3 `
  -Region eu-south-2
```

## Fusionar exports recibidos

Cuando tengas `A.json`, `B.json`, `C.json`, `D.json` y `E.json` en `exports/`:

```powershell
.\strict5-merge-exports-into-topology.ps1
```

## Simular antes de aplicar

Alumno E:

```powershell
.\run-E-peering.ps1 -WhatIfOnly
```

## Prueba parcial sin C

Si falta `C.json`, se puede practicar con A, B, D y E usando:

```text
strict5-team-topology-no-C.json
```

Orden recomendado:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-A-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json -WhatIfOnly
powershell -ExecutionPolicy Bypass -File .\run-B-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json -WhatIfOnly
powershell -ExecutionPolicy Bypass -File .\run-D-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json -WhatIfOnly
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json -WhatIfOnly
```

Para aplicar de verdad, ejecutar en este orden:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-A-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json
powershell -ExecutionPolicy Bypass -File .\run-B-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json
powershell -ExecutionPolicy Bypass -File .\run-D-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology-no-C.json
```

## Aplicar

Alumno E:

```powershell
.\run-E-peering.ps1
```

Para E, el script acepta peerings donde E es receptor (`A -> E` y `B -> E`) y crea rutas hacia las VPC remotas. Antes de ejecutarlo sin `-WhatIfOnly`, A y B deben haber creado sus solicitudes de peering.

## Datos que debe mandar cada compañero

Formato recomendado:

```json
{
  "accountKey": "B",
  "profile": "NicolasB",
  "stack": "dt-b-lb-db",
  "region": "eu-south-2",
  "accountId": "123456789012",
  "vpcId": "vpc-xxxxxxxx",
  "vpcCidr": "10.20.0.0/16",
  "publicRouteTableId": "rtb-xxxxxxxx",
  "privateRouteTableId": "rtb-yyyyyyyy"
}
```

Campos obligatorios:

- `accountKey`
- `stack`
- `region`
- `accountId`
- `vpcId`
- `vpcCidr`
- `publicRouteTableId`
- `privateRouteTableId`

## Alumno C pendiente

Para incluir a C en la prueba completa, C debe generar su export desde su equipo, donde exista el perfil `MarioC`:

```powershell
.\strict5-export-local-network-info.ps1 `
  -AccountKey C `
  -Profile MarioC `
  -Stack dt-c-web-u1 `
  -Region eu-south-2
```

Esto crea:

```text
exports/C.json
```

Despues hay que compartir ese archivo y fusionar:

```powershell
.\strict5-merge-exports-into-topology.ps1
```

Las IP privadas del modulo profesores ya preparadas son:

```text
C Web01: 10.30.1.48:80
C Web02: 10.30.1.121:80
Ruta: /profesores/
```
