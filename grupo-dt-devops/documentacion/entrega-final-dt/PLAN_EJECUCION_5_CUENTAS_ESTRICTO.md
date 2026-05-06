# Plan de ejecucion DevOps propuesto para 5 cuentas AWS

Este documento describe el flujo DevOps que se planteo inicialmente para automatizar la practica completa. No representa el flujo ejecutado finalmente de principio a fin.

La solucion final entregada se encuentra en `../../grupo-dt-CloudFormation` y se basa en CloudFormation por alumno, scripts de peering distribuido y configuracion validada manualmente.

## Objetivo

Automatizar el despliegue y provisionamiento de la arquitectura de cinco alumnos:

- Alumno A: Windows Server, Active Directory, DNS, DHCP y cliente Windows.
- Alumno B: Load Balancer Nginx y PostgreSQL.
- Alumno C: modulo `/profesores/`.
- Alumno D: modulo `/alumnos/`.
- Alumno E: modulo `/practicas/`.

## Flujo propuesto

1. Cada alumno configura su perfil AWS local.
2. Cada alumno crea su key pair EC2.
3. CloudFormation despliega la infraestructura base.
4. Se exportan outputs de red de cada stack.
5. Se crea la topologia de peering entre VPCs.
6. Ansible configura servicios:
   - AD/DNS/NTP.
   - PostgreSQL.
   - Nginx.
   - Node.js.
   - Aplicaciones web.
7. Jenkins o GitHub Actions ejecutan el flujo de forma controlada.

## Automatizaciones planteadas

- `cloudformation/strict-5/`: plantillas IaC por alumno.
- `scripts/strict5-*.ps1`: scripts PowerShell para despliegue y peering.
- `ansible/`: playbooks de configuracion.
- `jenkins/`: pipelines de CI/CD.
- `.github/workflows/`: alternativa con GitHub Actions.

## Motivo por el que no fue el flujo final

El enfoque era viable, pero aumentaba mucho la complejidad:

- Requeria coordinar secretos entre varias cuentas.
- Necesitaba inventario dinamico fiable.
- Exigia validar WinRM, SSH, Ansible, Jenkins y AWS al mismo tiempo.
- El tiempo disponible no permitia cerrarlo con garantias.

Por ello, la entrega final prioriza una solucion estable y demostrable con CloudFormation, VPC Peering y configuracion controlada.

