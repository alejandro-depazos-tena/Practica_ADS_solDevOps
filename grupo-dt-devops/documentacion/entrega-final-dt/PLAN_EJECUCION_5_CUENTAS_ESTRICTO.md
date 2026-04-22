# Plan de ejecución estricto (5 cuentas AWS)

## 1. Regla de oro de la rúbrica

Cada alumno debe desplegar recursos en su propia cuenta AWS (IAM, Budget, VPC, SG, EC2 y servicios de su rol), y luego integrar entre cuentas.

## 2. Reparto oficial (equipo de 5)

- Alumno A (Alejandro): Windows AD + Windows cliente
- Alumno B (Nicolás): Linux LB + Linux DB
- Alumno C (Mario): Linux Web location/upstream 1
- Alumno D (Gonzalo): Linux Web location/upstream 2
- Alumno E (Jesús): Linux Web location/upstream 3

## 3. Precondiciones obligatorias por alumno

Cada alumno, en su cuenta:

1. Crear/validar usuario IAM operativo (sin root).
2. Crear/validar Budget con alertas.
3. Crear Key Pair para su cuenta.
4. Configurar perfil AWS local:
   - AlejandroA
   - NicolasB
   - MarioC
   - GonzaloD
   - JesusE
5. Validar con `aws sts get-caller-identity --profile <perfil>`.

## 4. Qué debe crear cada alumno en AWS (mínimo)

## 4.1 Alumno A (cuenta AlejandroA)

1. VPC con subred pública/privada y rutas.
2. Security Groups de AD y cliente Windows.
3. EC2 Windows AD con Elastic IP.
4. EC2 Windows Cliente con Elastic IP.
5. Configurar AD DS + DNS + DHCP + NTP + CIFS + OU + grupo + 2 usuarios + 2 GPO.
6. Unir cliente Windows al dominio con DHCP/DNS automático.

## 4.2 Alumno B (cuenta NicolasB)

1. VPC con subred pública/privada y rutas.
2. Security Groups para LB y DB.
3. EC2 Linux LB con Elastic IP.
4. EC2 Linux PostgreSQL con Elastic IP.
5. Nginx reverse proxy con locations separadas.
6. PostgreSQL con control de accesos y backup/restore.

## 4.3 Alumno C (cuenta MarioC)

1. VPC con subred pública/privada y rutas.
2. Security Group de webserver.
3. 2 EC2 Linux Web para módulo `/profesores` (upstream 1) con Elastic IP.
4. Nginx + backend módulo profesores + acceso a DB.
5. Integración S3 por IAM Role.

## 4.4 Alumno D (cuenta GonzaloD)

1. VPC con subred pública/privada y rutas.
2. Security Group de webserver.
3. 2 EC2 Linux Web para módulo `/alumnos` (upstream 2) con Elastic IP.
4. Nginx + backend módulo alumnos + acceso a DB.
5. Integración S3 por IAM Role.

## 4.5 Alumno E (cuenta JesusE)

1. VPC con subred pública/privada y rutas.
2. Security Group de webserver.
3. 2 EC2 Linux Web para módulo `/practicas` (upstream 3) con Elastic IP.
4. Nginx + backend módulo prácticas + acceso a DB.
5. Integración S3 por IAM Role.

## 5. Integración entre cuentas (obligatoria)

1. Definir plan de conectividad entre cuentas (peering/rutas/SG) para:
   - Linux -> AD (DNS/NTP)
   - LB -> Web C/D/E
   - Web C/D/E -> DB
2. Validar conectividad real y documentada con comandos y evidencias.

## 6. Orden de ejecución recomendado

1. Todos: IAM + Budget + perfiles + key pairs.
2. Todos: VPC + subredes + rutas + SG + EC2 base en su cuenta.
3. A: AD completo + cliente dominio.
4. B: DB + LB base.
5. C/D/E: webservers por módulo y upstream.
6. Integración intercuenta (conectividad/red y pruebas).
7. Despliegue aplicación y validación funcional final.
8. DRP y evidencias.

## 7. Qué puede automatizarse y qué no

Automatizable:
- Provisioning de servicios por Ansible.
- Despliegue de app y configuración Nginx/Node/PostgreSQL.

No completamente automatizado en el estado actual del repo:
- El alta inicial completa por las 5 cuentas (cada uno su stack/infra separada).
- Debe coordinarse y ejecutarse por alumno.

## 8. Evidencias mínimas por alumno

Cada alumno entrega capturas/logs de:

1. Recursos en su cuenta (VPC, SG, EC2, EIP, Budget).
2. Funcionalidad de su rol.
3. Integración con otro componente de otra cuenta.
4. Comandos de validación.

## 9. Cierre de cumplimiento

Solo se considera completo si:

1. Se demuestra despliegue por cuenta individual.
2. Se demuestra integración intercuenta funcional.
3. Se completa DRP con evidencias reales.

## 10. Implementación CloudFormation por alumno (obligatoria)

Plantillas listas en:

- `cloudformation/strict-5/stack-A-ad-client.yaml`
- `cloudformation/strict-5/stack-B-lb-db.yaml`
- `cloudformation/strict-5/stack-C-web-upstream1.yaml`
- `cloudformation/strict-5/stack-D-web-upstream2.yaml`
- `cloudformation/strict-5/stack-E-web-upstream3.yaml`

Comandos de despliegue por perfil en:

- `cloudformation/strict-5/README.md`

Regla de ejecución:

1. Cada alumno despliega su stack en su cuenta con su perfil AWS.
2. Cada alumno guarda outputs (`VpcId`, `VpcCidr`, `RouteTableId`, instancias y EIP).
3. Con esos outputs se configura la integración intercuenta (peering/rutas/SG), preferiblemente con `scripts/strict5-integrate-peerings.ps1`.
