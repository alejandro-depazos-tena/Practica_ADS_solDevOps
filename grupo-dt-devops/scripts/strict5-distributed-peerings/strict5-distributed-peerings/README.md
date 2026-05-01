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

