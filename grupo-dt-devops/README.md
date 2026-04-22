# Grupo DT — Práctica AWS en formato DevOps

Proyecto automatizado para la práctica de **Integración de Sistemas en AWS** siguiendo la solución de Alex y la rúbrica.

## Integrantes
- Alejandro — Alumno A (Windows AD/DC + cliente Windows AD)
- Nicolás — Alumno B (Linux LB + Linux DB)
- Mario — Alumno C (Linux Web01: location /profesores)
- Gonzalo — Alumno D (Linux Web02: location /alumnos)
- Jesús — Alumno E (Linux Web03: location /practicas)

## Estructura
- `cloudformation/`: infraestructura AWS (2 cuentas y peering)
- `jenkins/`: pipelines Jenkins
- `ansible/`: inventario dinámico y playbooks
- `ufv-app/`: app web, nginx y Node.js
- `scripts/`: utilidades de bootstrap y validación
- `.github/workflows/`: CI/CD para GitHub Actions
- `docs/`: guía de operación y evidencias

## Flujo DevOps recomendado
1. Desplegar infraestructura (`Jenkinsfile-infra` o workflow `deploy.yml`)
2. Generar inventario dinámico (`Jenkinsfile-inventory`)
3. Configurar AD + DNS + NTP + Linux (`Jenkinsfile-provision`)
4. Desplegar/actualizar app (`Jenkinsfile-webdeploy`)

## Alcance técnico alineado con rúbrica
- 2 VPC en cuentas distintas conectadas por peering + rutas cruzadas.
- Cuenta personal: AD DS + DNS + DHCP + NTP, LB Nginx, PostgreSQL, cliente Windows.
- Cuenta UFV: 3 webservers Linux (Web01/Web02/Web03) con módulos separados por location.
- LB con locations dedicadas:
	- `/profesores` -> Web01
	- `/alumnos` -> Web02
	- `/practicas` -> Web03
- BD `academico` con tablas: `asignaturas`, `alumnos`, `inscripciones`, `practicas`, `entregas`.
- Integración S3 por IAM Role en servidores web.

## Requisitos mínimos
- AWS CLI configurado con 5 perfiles: `AlejandroA`, `NicolasB`, `MarioC`, `GonzaloD`, `JesusE`
- Jenkins + Java 17 en nodo de control Ubuntu
- Ansible + colecciones necesarias
- Llaves SSH y credenciales WinRM

## Nota de seguridad
No subas credenciales reales al repositorio. Usa variables de entorno y secretos de Jenkins/GitHub Actions.
