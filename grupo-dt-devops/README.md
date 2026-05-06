# Grupo DT - Propuesta DevOps no ejecutada finalmente

Esta carpeta conserva la linea de trabajo DevOps planteada inicialmente para la practica.

Incluye recursos para:

- Ansible.
- Jenkins.
- GitHub Actions.
- Scripts de automatizacion.
- Codigo de aplicacion.
- Documentacion tecnica auxiliar.

## Estado

Esta no fue la solucion ejecutada finalmente de principio a fin.

Durante la practica se decidio entregar una solucion mas controlada basada en:

- CloudFormation por alumno.
- AWS CLI.
- VPC Peering distribuido.
- Configuracion manual validada de servicios.

La solucion final ordenada para entrega esta en:

`../grupo-dt-CloudFormation`

## Motivo

La automatizacion completa con Ansible/Jenkins era viable como ampliacion, pero aumentaba bastante la complejidad y no dio tiempo a cerrarla con garantias antes de la entrega.

Se conserva esta carpeta para mostrar la linea de mejora y el enfoque DevOps que se habia empezado a preparar.

## Contenido

- `ansible/`: playbooks e inventario para provisionamiento.
- `jenkins/`: pipelines Jenkins.
- `.github/workflows/`: workflows de GitHub Actions.
- `cloudformation/`: plantillas y versiones de trabajo.
- `scripts/`: utilidades de despliegue, validacion y peering.
- `ufv-app/`: codigo de los modulos web.
- `docs/` y `documentacion/`: documentacion auxiliar.

## Aviso de seguridad

Antes de entregar o subir esta carpeta, revisar que no se incluyan:

- Claves `.pem`.
- Archivos `.env`.
- Credenciales AWS.
- Contrasenas reales.

La raiz del proyecto incluye un `.gitignore` para evitar subir este tipo de archivos.
