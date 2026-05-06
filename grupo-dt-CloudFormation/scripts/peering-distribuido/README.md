# Peering distribuido strict-5

Scripts usados para conectar las VPCs de los cinco alumnos sin que una sola persona tenga todos los perfiles AWS.

## Flujo final

1. Cada alumno exporta la informacion de su stack a `exports/<LETRA>.json`.
2. Se comparten los JSON entre el equipo.
3. Se fusionan en `strict5-team-topology.json`.
4. Cada alumno ejecuta su script `run-<LETRA>-peering.ps1`.

## Exportar datos locales

Ejemplo Alumno E:

```powershell
powershell -ExecutionPolicy Bypass -File .\strict5-export-local-network-info.ps1 `
  -AccountKey E `
  -Profile JesusE `
  -Stack dt-e-web-u3 `
  -Region eu-south-2
```

## Fusionar exports

Cuando existan `A.json`, `B.json`, `C.json`, `D.json` y `E.json` dentro de `exports/`:

```powershell
powershell -ExecutionPolicy Bypass -File .\strict5-merge-exports-into-topology.ps1
```

## Aplicar peerings

Cada alumno ejecuta su script desde esta carpeta.

Ejemplo Alumno E:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology.json
```

Orden recomendado para una prueba completa:

1. Alumno A ejecuta `run-A-peering.ps1`.
2. Alumno B ejecuta `run-B-peering.ps1`.
3. Alumno C ejecuta `run-C-peering.ps1`.
4. Alumno D ejecuta `run-D-peering.ps1`.
5. Alumno E ejecuta `run-E-peering.ps1`.

## Archivos importantes

- `strict5-team-topology.json`: topologia final A-B-C-D-E.
- `exports/`: datos de red exportados por cada alumno.
- `strict5-apply-peerings-local.ps1`: logica comun de creacion/aceptacion de peerings y rutas.
- `run-<LETRA>-peering.ps1`: wrapper por alumno.

## Nota

Estos scripts solo gestionan conectividad entre VPCs. La configuracion de Nginx, PostgreSQL y aplicaciones se realizo despues sobre las instancias correspondientes.

