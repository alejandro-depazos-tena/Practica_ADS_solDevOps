# Preparacion para la defensa - Practica ADS

## Idea general del sistema

La practica consiste en montar una infraestructura distribuida en AWS entre varios alumnos. Cada alumno tiene una parte independiente, pero todas se integran para formar un sistema completo.

El flujo general es:

- Un cliente Windows accede a la aplicacion usando el dominio corporativo `www.corp.ufv.local`.
- Ese dominio lo resuelve el DNS del Windows Server del Alumno A.
- El dominio apunta al Load Balancer Linux del Alumno B.
- El Load Balancer recibe la peticion HTTP.
- Segun la ruta, Nginx envia la peticion al modulo correspondiente:
  - `/profesores/` -> Alumno C.
  - `/alumnos/` -> Alumno D.
  - `/practicas/` -> Alumno E.
- Cada modulo tiene sus propios servidores web en su propia VPC.
- Los modulos consultan una base de datos PostgreSQL central desplegada por el Alumno B.
- Los modulos pueden usar S3 mediante IAM Role, sin guardar claves en el codigo.

La idea importante para defender es que no es una web aislada, sino una arquitectura distribuida multi-cuenta integrada con red privada, DNS, balanceo, base de datos y almacenamiento S3.

## Partes del sistema

## Alumno A - Windows Server

El Alumno A monta la parte Windows:

- Windows Server con Active Directory.
- Dominio `corp.ufv.local`.
- DNS corporativo.
- DHCP para el cliente Windows.
- Cliente Windows unido al dominio.
- GPOs, usuarios y recursos compartidos.
- Registro DNS para que `www.corp.ufv.local` apunte al Load Balancer.

Su parte permite que el usuario final no tenga que acceder por IP, sino usando un nombre corporativo.

## Alumno B - Load Balancer y PostgreSQL

El Alumno B monta la parte central Linux:

- Load Balancer con Nginx.
- Servidor PostgreSQL.
- Base de datos `DB_UFV`.
- Rutas del balanceador hacia los modulos C, D y E.

La base de datos contiene tablas como:

- `profesores`
- `alumnos`
- `practicas`
- `entregas`

El Load Balancer tiene configuradas rutas:

- `/profesores/` hacia el Alumno C.
- `/alumnos/` hacia el Alumno D.
- `/practicas/` hacia el Alumno E.

## Alumno C - Modulo Profesores

El Alumno C monta el modulo de profesores:

- Dos servidores web Linux.
- Backend Node.js.
- Frontend web.
- Conexion con PostgreSQL.
- Consulta de la tabla `profesores`.

Ruta principal:

- `http://www.corp.ufv.local/profesores/`

## Alumno D - Modulo Alumnos

El Alumno D monta el modulo de alumnos:

- Dos servidores web Linux.
- Backend Node.js.
- Frontend web.
- Conexion con PostgreSQL.
- Consulta de la tabla `alumnos`.
- Funcionalidades propias del modulo de alumnos.

Ruta principal:

- `http://www.corp.ufv.local/alumnos/`

## Alumno E - Modulo Practicas

El Alumno E monta el modulo de practicas:

- Dos servidores web Linux:
  - `DT-E-Web01`
  - `DT-E-Web02`
- Backend Node.js.
- Frontend web.
- Ruta `/practicas/`.
- Conexion con PostgreSQL.
- Consulta de practicas.
- Gestion de entregas.
- Integracion con S3.
- Bucket S3 propio con versionado habilitado.

Ruta principal:

- `http://www.corp.ufv.local/practicas/`

## Como funciona una peticion

Ejemplo:

`http://www.corp.ufv.local/practicas/`

Flujo:

1. El cliente Windows pregunta al DNS quien es `www.corp.ufv.local`.
2. El DNS del Windows Server responde con la IP privada del Load Balancer del Alumno B.
3. El navegador envia la peticion HTTP al Load Balancer.
4. Nginx en el Load Balancer detecta que la ruta empieza por `/practicas/`.
5. El Load Balancer reenvia la peticion a los servidores del Alumno E usando IPs privadas:
   - `10.50.1.175`
   - `10.50.1.58`
6. Nginx en la instancia del Alumno E recibe la peticion.
7. El backend Node.js procesa la solicitud.
8. Si necesita datos, Node.js consulta PostgreSQL en el servidor del Alumno B:
   - `10.20.1.221:5432`
9. PostgreSQL devuelve las practicas o entregas.
10. Node.js devuelve HTML o JSON.
11. El navegador muestra la pagina de practicas.

Frase corta para explicar:

El cliente entra por DNS corporativo, llega al Load Balancer, Nginx enruta por path y mi backend de practicas consulta PostgreSQL o S3 segun lo que necesite.

## Por que hace falta VPC Peering

Cada alumno tiene una VPC distinta:

- Alumno A: `10.10.0.0/16`
- Alumno B: `10.20.0.0/16`
- Alumno C: `10.30.0.0/16`
- Alumno D: `10.40.0.0/16`
- Alumno E: `10.50.0.0/16`

Por defecto, las VPCs estan aisladas y no pueden comunicarse entre ellas usando IPs privadas.

Para permitir esa comunicacion se configura VPC Peering. El peering permite conectar VPCs de forma privada dentro de AWS.

Ademas del peering, hay que actualizar las tablas de rutas para que el trafico sepa por donde ir.

Ejemplos:

- A necesita llegar a B para acceder al Load Balancer desde el cliente Windows.
- B necesita llegar a C, D y E para enviar trafico a los modulos.
- C, D y E necesitan llegar a B para consultar PostgreSQL.

Ventaja:

El trafico no sale a Internet. Se mueve por la red privada de AWS.

## Mi parte como Alumno E

## Infraestructura

Mi infraestructura se desplego con CloudFormation usando la plantilla:

`stack-E-web-upstream3.yaml`

La stack se llama:

`dt-e-web-u3`

Recursos principales creados:

- VPC `10.50.0.0/16`.
- Subred publica `10.50.1.0/24`.
- Subred privada `10.50.11.0/24`.
- Internet Gateway.
- Tablas de rutas.
- Security Group.
- Dos instancias EC2 Ubuntu.
- Dos Elastic IPs.
- Bucket S3 con versionado.
- IAM Role para acceso a S3.

## Servidores

Servidores del Alumno E:

- Web01-E:
  - IP privada: `10.50.1.175`
  - IP publica: `15.217.55.202`
- Web02-E:
  - IP privada: `10.50.1.58`
  - IP publica: `15.217.157.115`

## Seguridad de red

El Security Group permite:

- SSH puerto `22` desde mi IP de administracion.
- HTTP puerto `80` desde la VPC del Load Balancer del Alumno B:
  - `10.20.0.0/16`

Esto significa que el acceso normal al modulo debe venir desde el Load Balancer, no desde cualquier origen.

## Aplicacion de practicas

La aplicacion esta desplegada en:

`/opt/ufv-practicas`

Componentes:

- Nginx como servidor web y proxy inverso.
- Node.js como backend.
- Servicio systemd `ufv-practicas.service`.
- Conexion a PostgreSQL.
- Integracion con S3.

Endpoints principales:

- `/practicas/`
- `/practicas/resumen`
- `/practicas/lista`
- `/practicas/entregas`
- `/practicas/s3/status`
- `/practicas/evidencias`

## PostgreSQL

La base de datos esta en el servidor del Alumno B:

- Host: `10.20.1.221`
- Puerto: `5432`
- Base de datos: `DB_UFV`

Usuarios:

- `backend_read`: para lecturas.
- `backend_write`: para escrituras.

Mi modulo usa principalmente:

- Tabla `practicas`.
- Tabla `entregas`.

La tabla `practicas` contiene las practicas academicas.

La tabla `entregas` contiene entregas asociadas a practicas y alumnos.

Pregunta posible:

Los datos no son estaticos. El HTML solo tiene la interfaz. Los datos se cargan dinamicamente desde PostgreSQL mediante endpoints del backend Node.js.

## Gestion de entregas

El modulo de practicas no solo consulta datos, tambien permite crear entregas.

Flujo:

1. El usuario entra en `/practicas/`.
2. Rellena el formulario de nueva entrega.
3. El frontend envia una peticion POST a `/practicas/entregas`.
4. El backend Node.js valida los datos.
5. El backend inserta la entrega en PostgreSQL.
6. La web actualiza el listado de entregas.

Esto demuestra que el modulo no es una pagina estatica, sino una aplicacion con lectura y escritura en base de datos.

## S3

Bucket del Alumno E:

`dt-e-web-storage-906985802888-eu-south-2`

Caracteristicas:

- Creado con CloudFormation.
- Versionado habilitado.
- Acceso mediante IAM Role.
- No se usan claves AWS hardcodeadas.

Endpoints relacionados:

- `/practicas/s3/status`
- `/practicas/evidencias`

Funcion:

- `/practicas/s3/status` comprueba que el backend puede acceder al bucket.
- `/practicas/evidencias` crea un objeto JSON de evidencia en S3.

Pregunta posible:

Por que usar IAM Role?

Respuesta:

Porque evita guardar Access Keys en el codigo o en archivos locales. AWS proporciona credenciales temporales a la instancia y se aplica el principio de minimo privilegio.

## CloudFormation

CloudFormation se usa para desplegar infraestructura como codigo.

Ventajas:

- Repetible.
- Documentado.
- Reduce errores manuales.
- Permite recrear la infraestructura si falla.
- Cada alumno tiene su stack independiente.

Mi stack:

- Nombre: `dt-e-web-u3`
- Estado: `CREATE_COMPLETE`

Si el profesor pregunta si al volver a ejecutarlo cambia algo:

Si se ejecuta con la misma plantilla y los mismos parametros, CloudFormation detecta que no hay cambios y no modifica la infraestructura. Solo cambia algo si cambia la plantilla, los parametros o si algun recurso fue modificado manualmente.

## Que demuestra la practica

La practica demuestra integracion real de:

- Windows Server.
- Active Directory.
- DNS corporativo.
- Cliente Windows unido al dominio.
- Linux.
- Nginx.
- Load Balancing.
- PostgreSQL.
- Aplicaciones web con backend.
- S3.
- IAM Roles.
- VPC Peering.
- Security Groups.
- CloudFormation.
- Pruebas de integracion.

## Preguntas tipicas del profesor

## Que pasa cuando escribes `www.corp.ufv.local/practicas/`?

El cliente resuelve el dominio mediante el DNS corporativo, llega al Load Balancer del Alumno B, Nginx detecta la ruta `/practicas/` y reenvia la peticion a mis servidores del Alumno E por IP privada. Mi backend Node.js consulta PostgreSQL si necesita datos y devuelve la respuesta a la web.

## Por que usais Load Balancer?

Para tener un unico punto de entrada a la aplicacion y distribuir el trafico hacia los distintos modulos. Tambien permite organizar la aplicacion por rutas y ocultar las IPs internas de los servidores web.

## Por que hay dos instancias por modulo?

Para mejorar disponibilidad y permitir balanceo. Si una instancia falla, la otra puede seguir respondiendo.

## Por que VPC Peering?

Porque cada alumno tiene una VPC distinta. El peering permite comunicacion privada entre VPCs sin exponer servicios internos a Internet.

## Por que PostgreSQL esta en B?

Porque B actua como capa central de persistencia. Los modulos C, D y E consumen una base comun para trabajar con datos integrados.

## Que hiciste tu exactamente?

Desplegue la infraestructura del Alumno E con CloudFormation, configure dos servidores web Ubuntu, monte el modulo `/practicas/`, conecte el backend Node.js con PostgreSQL, añadi gestion de entregas y valide la integracion con S3 mediante IAM Role.

## Que papel tiene S3 en tu modulo?

Se usa como almacenamiento de evidencias. El backend puede comprobar el acceso al bucket y crear objetos dentro de S3. El bucket tiene versionado activo.

## Los datos son estaticos?

No. La web carga datos reales desde PostgreSQL mediante endpoints del backend Node.js. El HTML solo contiene la interfaz.

## Que medidas de seguridad teneis?

- Security Groups restrictivos.
- PostgreSQL no expuesto publicamente.
- Comunicacion privada por VPC Peering.
- Usuarios separados de base de datos.
- IAM Role para S3.
- Acceso SSH limitado por IP.

## Por que es mejor IAM Role que Access Keys?

Porque no hay que guardar credenciales estaticas en el codigo. AWS entrega credenciales temporales a la instancia EC2 y se reducen riesgos de exposicion.

## Que pasa si falla una instancia de tu modulo?

Como hay dos instancias, el Load Balancer puede seguir enviando trafico a la otra instancia disponible. Eso mejora la disponibilidad del modulo.

## Como validaste que PostgreSQL funcionaba?

Con pruebas directas usando `psql` desde la instancia y con endpoints como:

- `/practicas/lista`
- `/practicas/entregas`

Estos endpoints devolvian datos reales desde la base `DB_UFV`.

## Como validaste S3?

Con el endpoint:

`/practicas/s3/status`

Y creando evidencias mediante:

`/practicas/evidencias`

Despues se comprobo que el objeto aparecia en el bucket S3.

## Frase corta para defender mi parte

Mi parte es el modulo de practicas. Esta desplegado en dos instancias EC2 dentro de la VPC del Alumno E. El acceso llega desde el Load Balancer del Alumno B mediante la ruta `/practicas/`. El backend esta hecho en Node.js, consulta PostgreSQL para obtener practicas y entregas, permite crear entregas y utiliza S3 mediante IAM Role para generar evidencias sin usar claves estaticas.

## Comandos utiles para la defensa

Esta seccion sirve como chuleta por si el profesor pide comprobar algo en directo.

## Conectar por SSH a las instancias del Alumno E

La clave privada del Alumno E esta en:

```powershell
"C:\Users\jdean\Desktop\dt-e-key.pem"
```

Web01-E:

- IP publica: `15.217.55.202`
- IP privada: `10.50.1.175`

```powershell
ssh -i "C:\Users\jdean\Desktop\dt-e-key.pem" ubuntu@15.217.55.202
```

Web02-E:

- IP publica: `15.217.157.115`
- IP privada: `10.50.1.58`

```powershell
ssh -i "C:\Users\jdean\Desktop\dt-e-key.pem" ubuntu@15.217.157.115
```

Si Windows da error de permisos con la clave:

```powershell
icacls "C:\Users\jdean\Desktop\dt-e-key.pem" /inheritance:r
icacls "C:\Users\jdean\Desktop\dt-e-key.pem" /grant:r "$env:USERNAME:R"
```

## Comprobar en que instancia estoy

Dentro de la instancia:

```bash
hostname
hostname -I
whoami
pwd
```

Esperado:

- Usuario: `ubuntu`.
- Web01-E deberia mostrar `10.50.1.175`.
- Web02-E deberia mostrar `10.50.1.58`.

## Comprobar Nginx

Ver estado del servicio:

```bash
sudo systemctl status nginx
```

Reiniciar Nginx:

```bash
sudo systemctl restart nginx
```

Validar sintaxis de configuracion:

```bash
sudo nginx -t
```

Ver configuracion activa:

```bash
sudo cat /etc/nginx/sites-available/default
```

Ver si esta escuchando en el puerto 80:

```bash
sudo ss -ltnp | grep ':80'
```

## Comprobar el backend Node.js de practicas

Ver estado del servicio:

```bash
sudo systemctl status ufv-practicas
```

Reiniciar el servicio:

```bash
sudo systemctl restart ufv-practicas
```

Ver definicion del servicio:

```bash
sudo systemctl cat ufv-practicas
```

Ver logs recientes:

```bash
sudo journalctl -u ufv-practicas -n 50 --no-pager
```

Ver si Node escucha en el puerto interno:

```bash
sudo ss -ltnp | grep node
```

## Probar el modulo desde dentro de la instancia

Desde Web01-E o Web02-E:

```bash
curl http://localhost/practicas/
curl http://localhost/practicas/resumen
curl http://localhost/practicas/lista
curl http://localhost/practicas/entregas
curl http://localhost/practicas/s3/status
```

Si se quiere probar directamente contra Node, primero mirar el puerto:

```bash
sudo systemctl cat ufv-practicas
```

Normalmente el servicio usa `PORT=3001`, por lo que se puede probar:

```bash
curl http://localhost:3001/practicas/resumen
```

## Probar desde el Load Balancer o desde el cliente

Con IP publica del Load Balancer:

```powershell
curl http://51.48.226.94/profesores/lista
curl http://51.48.226.94/alumnos/lista
curl http://51.48.226.94/practicas/lista
curl http://51.48.226.94/practicas/entregas
curl http://51.48.226.94/practicas/s3/status
```

Con dominio corporativo desde el cliente Windows:

```powershell
curl http://www.corp.ufv.local/profesores/lista
curl http://www.corp.ufv.local/alumnos/lista
curl http://www.corp.ufv.local/practicas/lista
curl http://www.corp.ufv.local/practicas/entregas
curl http://www.corp.ufv.local/practicas/s3/status
```

## Comprobar DNS corporativo desde cliente Windows

```powershell
nslookup www.corp.ufv.local
```

```powershell
Test-NetConnection www.corp.ufv.local -Port 80
```

Resultado esperado:

- El dominio resuelve hacia la IP privada del Load Balancer.
- `TcpTestSucceeded: True`.

## Comprobar PostgreSQL desde una instancia E

Probar conectividad al puerto:

```bash
nc -vz 10.20.1.221 5432
```

Si no esta instalado `nc`:

```bash
telnet 10.20.1.221 5432
```

Conectar con `psql`:

```bash
psql -h 10.20.1.221 -U backend_read -d DB_UFV
```

Consultas utiles dentro de `psql`:

```sql
\dt
SELECT id, titulo, fecha_entrega, calificacion, estado FROM practicas;
SELECT * FROM entregas;
\q
```

Si la salida entra en modo paginador y aparece `(END)`, salir con:

```text
q
```

Para desactivar el paginador dentro de `psql`:

```sql
\pset pager off
```

## Comprobar S3 desde la aplicacion

Endpoint de estado:

```powershell
curl http://51.48.226.94/practicas/s3/status
```

Desde dominio corporativo:

```powershell
curl http://www.corp.ufv.local/practicas/s3/status
```

Si se esta dentro de la instancia:

```bash
curl http://localhost/practicas/s3/status
```

Bucket del Alumno E:

```text
dt-e-web-storage-906985802888-eu-south-2
```

## Comprobar CloudFormation del Alumno E

Ver estado de la stack:

```powershell
aws cloudformation describe-stacks `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3
```

Ver recursos de la stack:

```powershell
aws cloudformation list-stack-resources `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3
```

Ver outputs:

```powershell
aws cloudformation describe-stacks `
  --profile JesusE `
  --region eu-south-2 `
  --stack-name dt-e-web-u3 `
  --query "Stacks[0].Outputs"
```

## Comando de despliegue CloudFormation del Alumno E

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

Si no hay cambios, CloudFormation indicara que la stack esta actualizada o que no hay cambios que desplegar.

## Comandos de peering distribuido

Carpeta:

```powershell
cd .\grupo-dt-CloudFormation\scripts\peering-distribuido
```

Exportar datos de red del Alumno E:

```powershell
powershell -ExecutionPolicy Bypass -File .\strict5-export-local-network-info.ps1 `
  -AccountKey E `
  -Profile JesusE `
  -Stack dt-e-web-u3 `
  -Region eu-south-2
```

Fusionar exports de todos:

```powershell
powershell -ExecutionPolicy Bypass -File .\strict5-merge-exports-into-topology.ps1
```

Ejecutar peering del Alumno E:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology.json
```

Simular antes de aplicar:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-E-peering.ps1 -TopologyFile .\strict5-team-topology.json -WhatIfOnly
```

## Comprobar Security Groups y rutas en AWS CLI

Ver instancias E:

```powershell
aws ec2 describe-instances `
  --profile JesusE `
  --region eu-south-2 `
  --filters "Name=tag:Name,Values=DT-E-Web*" `
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0],PrivateIpAddress,PublicIpAddress,State.Name]" `
  --output table
```

Ver peerings:

```powershell
aws ec2 describe-vpc-peering-connections `
  --profile JesusE `
  --region eu-south-2 `
  --query "VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code,RequesterVpcInfo.CidrBlock,AccepterVpcInfo.CidrBlock]" `
  --output table
```

## Comandos de emergencia suaves

Reiniciar Nginx:

```bash
sudo systemctl restart nginx
```

Reiniciar backend:

```bash
sudo systemctl restart ufv-practicas
```

Ver ultimos errores del backend:

```bash
sudo journalctl -u ufv-practicas -n 80 --no-pager
```

Ver ultimos errores de Nginx:

```bash
sudo tail -n 80 /var/log/nginx/error.log
```
