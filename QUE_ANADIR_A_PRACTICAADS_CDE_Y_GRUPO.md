# Que anadir al PDF PracticaADS - Alumnos C, D y E

Este documento indica que contenido falta o conviene reforzar en `PracticaADS.pdf`, donde meterlo y que evidencias/capturas preparar. No tocar el apartado que aparece como `PARTE DE GONYO NO TOCAR LUEGO LO ORGANIZO`.

## Resumen rapido

En el PDF actual ya hay una estructura util, pero la parte Linux/web de C, D y E esta demasiado vacia o mezclada. Lo mas importante es completar:

- Pagina 8: tabla de despliegue modular por alumno.
- Pagina 29: apartado `7. Linux LB y DB`.
- Pagina 32: apartado `8. Integracion con AWS S3`.
- Pagina 39: apartado `10. Pruebas de Integracion y Validacion`.
- Pagina 41: conclusiones.

No meter contenido nuevo en la pagina 35 ni dentro del bloque reservado a Gonzalo.

## 1. Pagina 8 - Corregir despliegue modular por alumno

En el apartado `2.4. Despliegue Modular por Alumno`, la tabla debe reflejar la arquitectura real actual.

Sustituir/actualizar la tabla para C, D y E con esto:

| Alumno | Cuenta/Perfil | Plantilla CloudFormation | VPC | Modulo | Recursos principales |
|---|---|---|---|---|---|
| Alumno C - Mario | `MarioC` | `cloudformation/strict-5/stack-C-web-upstream1.yaml` | `10.30.0.0/16` | `/profesores/` | 2 EC2 Ubuntu, Nginx, Node.js, bucket S3, IAM Role |
| Alumno D - Gonzalo | `GonzaloD` | `cloudformation/strict-5/stack-D-web-upstream2.yaml` | `10.40.0.0/16` | `/alumnos/` | 2 EC2 Ubuntu, Nginx, Node.js, bucket S3, IAM Role |
| Alumno E - Jesus | `JesusE` | `cloudformation/strict-5/stack-E-web-upstream3.yaml` | `10.50.0.0/16` | `/practicas/` | 2 EC2 Ubuntu, Nginx, Node.js, bucket S3, IAM Role |

Texto para pegar debajo:

```md
Los alumnos C, D y E despliegan los modulos funcionales de la aplicacion en cuentas AWS independientes. Cada alumno dispone de su propia VPC, subred publica, tabla de rutas, Security Group, bucket S3 versionado, rol IAM asociado a EC2 y dos instancias Ubuntu. Esta separacion permite aislar responsabilidades y simular un entorno distribuido real entre equipos.

El trafico HTTP de los servidores web no se expone de forma indiscriminada, sino que se permite desde la VPC del Load Balancer del alumno B (`10.20.0.0/16`). El acceso administrativo SSH queda limitado por Security Group mediante la IP publica de administracion correspondiente.
```

## 2. Pagina 29 - Completar apartado 7 Linux LB y DB

El apartado `7. Linux LB y DB` debe convertirse en el apartado principal de los servicios Linux. Propuesta de estructura:

```md
7. Linux, Load Balancer, Base de Datos y Web Servers
7.1 Load Balancer y PostgreSQL - Alumno B
7.2 Modulo Profesores - Alumno C
7.3 Modulo Alumnos - Alumno D
7.4 Modulo Practicas - Alumno E
7.5 Integracion entre modulos mediante Nginx
7.6 Conexion con PostgreSQL
7.7 Variables de entorno y usuarios de base de datos
```

### 7.2 Modulo Profesores - Alumno C

Texto para pegar:

```md
El alumno C implementa el modulo `/profesores/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.30.0.0/16`. El modulo esta servido por Nginx local y una aplicacion Node.js que consulta la base de datos PostgreSQL central del alumno B.

Instancias del modulo:
- Web01-C: `10.30.1.48`
- Web02-C: `10.30.1.121`

La aplicacion consume la tabla `profesores` de la base `DB_UFV`, mostrando datos reales como nombre, correo, departamento, especialidad y fecha de alta. La ruta publica se expone a traves del Load Balancer de B:

`http://www.corp.ufv.local/profesores/`

Endpoints de validacion:
- `/profesores/resumen`
- `/profesores/lista`
- `/health`
```

Evidencias recomendadas:

- Captura de `http://www.corp.ufv.local/profesores/`.
- Captura de `curl http://www.corp.ufv.local/profesores/lista`.
- Captura de `curl http://www.corp.ufv.local/profesores/resumen`.
- Captura de `systemctl status ufvNodeService` en una instancia C.
- Captura de `sudo systemctl status nginx`.

### 7.3 Modulo Alumnos - Alumno D

Texto para pegar:

```md
El alumno D implementa el modulo `/alumnos/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.40.0.0/16`. El modulo queda integrado con el Load Balancer de B y consulta la base de datos PostgreSQL central para obtener informacion de alumnos.

Instancias del modulo:
- Web01-D: `10.40.1.102`
- Web02-D: `10.40.1.100`

El modulo trabaja con la tabla `alumnos` de `DB_UFV`, mostrando informacion academica como nombre, apellido, email, carrera, curso y fecha de registro. Se valida mediante:

`http://www.corp.ufv.local/alumnos/`

Endpoints de validacion:
- `/alumnos/lista`
- `/health` si esta disponible en el modulo
```

Evidencias recomendadas:

- Captura de `http://www.corp.ufv.local/alumnos/`.
- Captura de `curl http://www.corp.ufv.local/alumnos/lista`.
- Captura de Nginx/servicio Node activo.

### 7.4 Modulo Practicas - Alumno E

Texto para pegar:

```md
El alumno E implementa el modulo `/practicas/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.50.0.0/16`. El modulo esta servido por Nginx local y una aplicacion Node.js que consulta PostgreSQL y tambien se integra con S3 mediante IAM Role.

Instancias del modulo:
- Web01-E: `10.50.1.175`
- Web02-E: `10.50.1.58`

La aplicacion consume la base `DB_UFV` del alumno B. Para cumplir la funcionalidad del modulo de practicas se usan las tablas:

- `practicas`: descripcion, alumno asociado, profesor, fecha de entrega, calificacion y estado.
- `entregas`: registro de entregas asociadas a practicas y alumnos.

La web permite consultar practicas, consultar entregas y crear nuevas entregas desde el frontend. Tambien incluye una comprobacion de integracion con S3 para almacenar evidencias del modulo sin utilizar claves estaticas, aprovechando el rol IAM asociado a la instancia EC2.

Ruta publica:

`http://www.corp.ufv.local/practicas/`

Endpoints de validacion:
- `/practicas/resumen`
- `/practicas/lista`
- `/practicas/entregas`
- `/practicas/s3/status`
- `/practicas/evidencias`
- `/health`
```

Evidencias recomendadas:

- Captura de `http://www.corp.ufv.local/practicas/`.
- Captura de la tabla de practicas cargada.
- Captura de la tabla de entregas cargada.
- Captura creando una entrega desde el formulario.
- Captura de `curl http://www.corp.ufv.local/practicas/entregas`.
- Captura de `curl http://www.corp.ufv.local/practicas/s3/status`.
- Captura del objeto creado en S3.

## 3. Pagina 29 - Anadir integracion del Load Balancer

En el apartado `7.5 Integracion entre modulos mediante Nginx`, meter:

```md
El alumno B actua como punto de entrada comun mediante un Nginx Load Balancer. Desde una unica IP publica y desde el dominio interno `www.corp.ufv.local`, el trafico se enruta hacia los modulos de los alumnos C, D y E:

- `/profesores/` -> upstream del alumno C (`10.30.1.48`, `10.30.1.121`)
- `/alumnos/` -> upstream del alumno D (`10.40.1.102`, `10.40.1.100`)
- `/practicas/` -> upstream del alumno E (`10.50.1.175`, `10.50.1.58`)

La configuracion del balanceador conserva el path original en el `proxy_pass`, permitiendo que tanto las paginas HTML como los endpoints JSON de cada modulo funcionen correctamente. Esto evita que rutas como `/profesores/lista`, `/alumnos/lista` o `/practicas/entregas` sean reescritas incorrectamente.
```

Evidencia:

```bash
curl http://www.corp.ufv.local/profesores/lista
curl http://www.corp.ufv.local/alumnos/lista
curl http://www.corp.ufv.local/practicas/lista
curl http://www.corp.ufv.local/practicas/entregas
```

## 4. Pagina 29 - Anadir conexion PostgreSQL y usuarios

En `7.6 Conexion con PostgreSQL`, meter:

```md
La base de datos central se encuentra en la VPC del alumno B y es accesible desde los modulos web mediante peering privado. Los datos de conexion son:

- Host: `10.20.1.221`
- Puerto: `5432`
- Base de datos: `DB_UFV`
- Usuario de lectura: `backend_read`
- Usuario de escritura: `backend_write`

Cada modulo usa el usuario adecuado en funcion de su responsabilidad. Las consultas de lectura se realizan con `backend_read`, mientras que las operaciones que modifican datos, como la creacion de entregas en el modulo de practicas, utilizan `backend_write`.
```

En `7.7 Variables de entorno`, meter:

```md
La configuracion de acceso a base de datos se externaliza mediante variables de entorno para evitar modificar el codigo al cambiar host, puerto o credenciales:

DB_HOST=10.20.1.221
DB_PORT=5432
DB_NAME=DB_UFV
DB_USER_READ=backend_read
DB_PASSWORD_READ=PassRead1!
DB_USER_WRITE=backend_write
DB_PASSWORD_WRITE=PassWrite1!
```

## 5. Pagina 32 - Apartado 8 Integracion con AWS S3

Anadir una subseccion para C, D y E:

```md
Los Web Servers de los alumnos C, D y E disponen de buckets S3 propios creados desde CloudFormation y asociados a las instancias EC2 mediante IAM Role. De esta forma, las aplicaciones pueden leer o escribir objetos en S3 sin almacenar claves de acceso en el codigo fuente.

En el modulo `/practicas/`, el alumno E ha implementado una prueba funcional de S3 mediante los endpoints:

- `/practicas/s3/status`: comprueba acceso al bucket.
- `/practicas/evidencias`: crea una evidencia JSON en S3.

La evidencia creada queda almacenada bajo el prefijo:

`practicas/evidencias/`

Esto demuestra el uso de S3 desde la aplicacion web y el funcionamiento del rol IAM asociado a la instancia.
```

Evidencias:

- Captura del bucket S3 de E.
- Captura del endpoint `/practicas/s3/status`.
- Captura de un objeto en `practicas/evidencias/`.
- Captura del IAM Role asociado a la instancia EC2.

## 6. Pagina 39 - Apartado 10 Pruebas de Integracion y Validacion

Este apartado esta practicamente vacio y debe ser uno de los mas importantes.

Propuesta de estructura:

```md
10.1 Validacion DNS corporativo
10.2 Validacion VPC Peering
10.3 Validacion del Load Balancer
10.4 Validacion del modulo Profesores
10.5 Validacion del modulo Alumnos
10.6 Validacion del modulo Practicas
10.7 Validacion PostgreSQL
10.8 Validacion S3
10.9 Incidencias encontradas y solucionadas
```

### 10.1 Validacion DNS corporativo

Texto:

```md
Desde el cliente Windows unido al dominio se valida que el registro `www.corp.ufv.local` resuelve a la IP privada del Load Balancer del alumno B. Esto permite acceder a la aplicacion mediante nombre DNS corporativo en lugar de IP.
```

Comandos:

```powershell
nslookup www.corp.ufv.local
Test-NetConnection www.corp.ufv.local -Port 80
```

### 10.2 Validacion VPC Peering

Texto:

```md
La integracion entre cuentas se realiza mediante VPC Peering. Se validan las conexiones entre A-B, B-C, B-D, B-E y las necesarias para la comunicacion con AD/DNS. Durante las pruebas se detecto que algunos peerings habian quedado eliminados, por lo que se recrearon mediante los scripts distribuidos del repositorio.
```

Evidencias:

- Captura de `VPC Peering Connections` en estado `Active`.
- Captura de route tables con rutas:
  - `10.20.0.0/16 -> peering A-B`
  - `10.30.0.0/16 -> peering B-C`
  - `10.40.0.0/16 -> peering B-D`
  - `10.50.0.0/16 -> peering B-E`

### 10.3 Validacion Load Balancer

Comandos:

```bash
curl http://localhost/profesores/lista
curl http://localhost/alumnos/lista
curl http://localhost/practicas/lista
```

Desde cliente Windows:

```powershell
curl http://www.corp.ufv.local/profesores/lista
curl http://www.corp.ufv.local/alumnos/lista
curl http://www.corp.ufv.local/practicas/lista
```

### 10.4 Validacion modulo Profesores

Comandos:

```powershell
curl http://www.corp.ufv.local/profesores/resumen
curl http://www.corp.ufv.local/profesores/lista
```

Resultado esperado:

- HTTP 200.
- JSON con profesores reales desde PostgreSQL.
- La web `/profesores/` muestra la tabla cargada.

### 10.5 Validacion modulo Alumnos

Comandos:

```powershell
curl http://www.corp.ufv.local/alumnos/lista
```

Resultado esperado:

- HTTP 200.
- JSON con alumnos reales desde PostgreSQL.
- La web `/alumnos/` muestra datos reales.

### 10.6 Validacion modulo Practicas

Comandos:

```powershell
curl http://www.corp.ufv.local/practicas/resumen
curl http://www.corp.ufv.local/practicas/lista
curl http://www.corp.ufv.local/practicas/entregas
```

Resultado esperado:

- HTTP 200.
- Practicas reales cargadas desde PostgreSQL.
- Entregas reales cargadas desde PostgreSQL.
- Posibilidad de crear una entrega desde la web.

### 10.8 Validacion S3

Comandos:

```powershell
curl http://www.corp.ufv.local/practicas/s3/status
```

Resultado esperado:

- `status: ok`
- Bucket correcto.
- Listado de objetos bajo `practicas/evidencias/`.

### 10.9 Incidencias encontradas y solucionadas

Meter un bloque como este:

```md
Durante la integracion se detectaron varias incidencias reales:

1. El registro DNS `www.corp.ufv.local` resolvia correctamente, pero el cliente Windows no alcanzaba el LB porque el peering A-B habia sido eliminado. Se recreo el peering y se actualizaron rutas.
2. Algunos modulos cargaban la pagina HTML pero no los datos porque Nginx reescribia incorrectamente las rutas API. Se corrigio el `proxy_pass` para mantener el path original.
3. El modulo `/profesores/` inicialmente servia datos estaticos. Se adapto el servicio Node.js en las instancias C para consultar la tabla `profesores` de `DB_UFV`.
4. El modulo `/practicas/` inicialmente solo mostraba practicas. Se amplio para incluir la tabla `entregas`, creacion de entregas y evidencia S3.
5. Internet Explorer del cliente Windows no ejecutaba correctamente parte del JavaScript moderno, por lo que se instalo Microsoft Edge para validar la interfaz web actual.
```

## 7. Cosas comunes que deberia anadir todo el grupo

Estas partes no son solo de C/D/E; deberian aparecer en la memoria general.

### 7.1 Tabla final de roles

```md
| Alumno | Responsabilidad |
|---|---|
| A | Active Directory, DNS, DHCP, NTP, GPO, cliente Windows |
| B | Load Balancer Nginx, PostgreSQL, usuarios DB, backups |
| C | Web module `/profesores/` |
| D | Web module `/alumnos/` |
| E | Web module `/practicas/`, entregas y S3 |
```

### 7.2 Diagrama final

Anadir un diagrama con:

```text
Cliente Windows A -> DNS AD -> www.corp.ufv.local -> LB B
LB B -> /profesores -> C
LB B -> /alumnos -> D
LB B -> /practicas -> E
C/D/E -> PostgreSQL B
E -> S3 E
```

### 7.3 Tabla de IPs privadas finales

```md
| Componente | IP privada |
|---|---|
| Cliente Windows A | `10.10.1.139` |
| LB B | `10.20.1.189` |
| PostgreSQL B | `10.20.1.221` |
| Web01 C | `10.30.1.48` |
| Web02 C | `10.30.1.121` |
| Web01 D | `10.40.1.102` |
| Web02 D | `10.40.1.100` |
| Web01 E | `10.50.1.175` |
| Web02 E | `10.50.1.58` |
```

### 7.4 Tabla de endpoints finales

```md
| Ruta | Modulo | Funcion |
|---|---|---|
| `/profesores/` | C | Interfaz profesores |
| `/profesores/lista` | C | JSON profesores |
| `/profesores/resumen` | C | Resumen profesores |
| `/alumnos/` | D | Interfaz alumnos |
| `/alumnos/lista` | D | JSON alumnos |
| `/practicas/` | E | Interfaz practicas |
| `/practicas/lista` | E | JSON practicas |
| `/practicas/entregas` | E | Consulta/creacion de entregas |
| `/practicas/s3/status` | E | Validacion S3 |
```

### 7.5 Evidencias minimas por bloque de rubrica

Infraestructura AWS:

- IAM user sin root.
- Budget creado.
- CloudFormation stack creado.
- VPC, subnets, route tables y SG.

Windows AD:

- AD DS funcionando.
- DNS `corp.ufv.local`.
- DHCP scope.
- NTP.
- GPO aplicada.
- Cliente unido al dominio.

Linux:

- Nginx LB activo.
- Nginx/Node en C/D/E activos.
- PostgreSQL activo.
- Endpoints JSON funcionando.
- S3 funcionando.

Integracion:

- DNS `www.corp.ufv.local`.
- Peering activo.
- Route tables.
- Acceso desde cliente Windows a los tres modulos.

DRP:

- Snapshot/backup AD.
- Backup PostgreSQL.
- Backup S3.
- Procedimiento de restauracion.

### 7.6 Conclusiones tecnicas a anadir

Texto posible:

```md
La practica demuestra una integracion real entre multiples cuentas AWS, combinando servicios Windows y Linux. La solucion final permite que un cliente Windows unido al dominio acceda mediante DNS corporativo a un Load Balancer Linux que distribuye trafico hacia modulos web desplegados en otras cuentas. Los modulos consumen una base PostgreSQL central y utilizan S3 mediante roles IAM, evitando credenciales estaticas.

Las principales dificultades estuvieron relacionadas con la coordinacion entre cuentas: peerings eliminados, rutas incompletas, Security Groups restrictivos y diferencias entre IPs publicas y privadas. La resolucion de estas incidencias permitio validar de forma real conceptos de red, seguridad, DNS, balanceo, backend y persistencia.
```

## 8. Checklist final antes de entregar

- [ ] Actualizar tabla de alumnos/roles en pagina 8.
- [ ] Completar apartado 7 con B, C, D y E.
- [ ] Meter capturas de C, D y E funcionando por `www.corp.ufv.local`.
- [ ] Meter capturas de endpoints JSON.
- [ ] Meter capturas de S3 del modulo E.
- [ ] Meter capturas de peerings activos.
- [ ] Meter captura de DNS `nslookup www.corp.ufv.local`.
- [ ] Meter captura de `Test-NetConnection www.corp.ufv.local -Port 80`.
- [ ] Anadir incidencias y soluciones.
- [ ] Revisar que el bloque `PARTE DE GONYO NO TOCAR` no se modifica accidentalmente.
