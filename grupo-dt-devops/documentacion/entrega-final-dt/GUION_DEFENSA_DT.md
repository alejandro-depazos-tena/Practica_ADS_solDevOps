# Guion corto - propuesta DevOps

Este guion sirve solo para explicar la parte DevOps como mejora planteada. No debe presentarse como el flujo final ejecutado.

## Idea principal

Durante el proyecto se planteo una linea DevOps para automatizar despliegue, configuracion y actualizacion de la infraestructura.

La entrega final se cerro con CloudFormation por alumno, peering distribuido y configuracion validada manualmente. La carpeta `grupo-dt-devops` queda como propuesta de ampliacion.

## Que incluia la propuesta

- CloudFormation para infraestructura como codigo.
- Scripts PowerShell para despliegue y peering.
- Ansible para configurar servicios.
- Jenkins para orquestar pipelines.
- GitHub Actions como alternativa CI/CD.
- Aplicacion Node.js desplegable en los Web Servers.

## Valor que aportaria

- Despliegues repetibles.
- Menos configuracion manual.
- Trazabilidad por commits y ejecuciones.
- Provisioning mas rapido ante recreacion de infraestructura.
- Mejor base para DRP y recuperacion.

## Por que no fue el flujo final

- Requeria cerrar muchos puntos al mismo tiempo: AWS, SSH, WinRM, Ansible, Jenkins, inventario dinamico y secretos.
- La prioridad fue entregar una solucion estable y demostrable.
- El enfoque DevOps queda como ampliacion razonable y documentada.

## Frase para defensa

Ademas de la solucion final con CloudFormation, dejamos planteada una linea DevOps con Ansible y Jenkins. No fue el flujo ejecutado finalmente por tiempo y complejidad, pero muestra como podria evolucionar el proyecto hacia despliegues mas repetibles y automatizados.

