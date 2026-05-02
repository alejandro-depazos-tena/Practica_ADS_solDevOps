# Guia definitiva para completar `PracticaADS.pdf`

Archivo revisado con el PDF actual del `02/05/2026`.

Importante:

- La tabla del punto `2.4 Despliegue Modular por Alumno` ya esta hecha. No hay que volver a meterla.
- Este archivo se queda en la raiz de `Practica_ADS_solDevOps`. No mover.
- No tocar el bloque del PDF que pone `PARTE DE GONYO NO TOCAR LUEGO LO ORGANIZO`.
- Los modulos C, D y E deben ir en el punto `8. Web Servers`, no dentro del punto 7.

## 1. Donde va cada cosa

| Apartado del PDF | Que debe contener |
|---|---|
| `7. Linux Load Balancer y Base de Datos - Alumno B` | Load Balancer Nginx de B, upstreams, PostgreSQL, usuarios BBDD y pruebas desde B |
| `8. Web Servers` | Introduccion comun a los tres modulos web |
| `8.1 Modulo Profesores - Alumno C` | Servidores C, rutas `/profesores/`, backend Node, conexion PostgreSQL |
| `8.2 Modulo Alumnos - Alumno D` | Servidores D, rutas `/alumnos/`, backend Node, conexion PostgreSQL |
| `8.3 Modulo Practicas - Alumno E` | Servidores E, rutas `/practicas/`, entregas, PostgreSQL y S3 |
| `9. Integracion de Servicios: DNS, PostgreSQL y S3` | Integracion entre modulos, DNS corporativo, PostgreSQL, variables de entorno y S3 |
| `11. Pruebas de Integracion y Validacion` | Capturas y comandos demostrando que todo funciona |
| `12. Conclusiones y Lecciones Aprendidas` | Problemas reales encontrados y aprendizaje tecnico |

## 2. Punto 7 - Linux Load Balancer y Base de Datos - Alumno B

Este punto es principalmente del alumno B. Aqui no se explican en detalle los modulos C, D y E; solo se explica que B centraliza la entrada HTTP y la base de datos.

Estructura recomendada:

```md
7. Linux Load Balancer y Base de Datos - Alumno B
7.1 Servidor Load Balancer Nginx
7.2 Configuracion de upstreams
7.3 Servidor PostgreSQL
7.4 Usuarios y permisos de base de datos
7.5 Pruebas locales desde el LB
```

Texto base:

```md
El alumno B actua como punto central de entrada a la aplicacion mediante un servidor Nginx configurado como Load Balancer. Este servidor recibe peticiones HTTP desde Internet y desde el dominio interno `www.corp.ufv.local`, y las distribuye hacia los modulos web desplegados en las cuentas de los alumnos C, D y E.

Ademas, B aloja la base de datos PostgreSQL central `DB_UFV`, accesible desde los Web Servers mediante comunicacion privada entre VPCs. La base de datos contiene las tablas utilizadas por los modulos de profesores, alumnos, practicas y entregas.
```

Upstreams que debe documentar B:

```md
- `/profesores/` -> Web C: `10.30.1.48`, `10.30.1.121`
- `/alumnos/` -> Web D: `10.40.1.102`, `10.40.1.100`
- `/practicas/` -> Web E: `10.50.1.175`, `10.50.1.58`
```

Pruebas para capturar desde el LB:

```bash
curl http://localhost/profesores/lista
curl http://localhost/alumnos/lista
curl http://localhost/practicas/lista
curl http://localhost/practicas/entregas
sudo systemctl status nginx
sudo systemctl status postgresql
sudo ss -ltnp | grep 5432
```

## 3. Punto 8 - Web Servers

Texto introductorio para abrir el punto 8:

```md
Los alumnos C, D y E despliegan modulos web independientes sobre instancias Ubuntu. Cada modulo queda publicado a traves del Load Balancer Nginx del alumno B y se comunica con la base de datos PostgreSQL central mediante la red privada creada entre VPCs.

La separacion por modulos permite mantener responsabilidades independientes: profesores, alumnos y practicas. Cada servicio dispone de su propio backend, su interfaz web y sus endpoints de validacion.
```

## 3.1 Punto 8.1 - Modulo Profesores - Alumno C

Texto para pegar:

```md
El alumno C implementa el modulo `/profesores/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.30.0.0/16`. Cada instancia ejecuta Nginx y un servicio Node.js encargado de consultar la base de datos PostgreSQL central del alumno B.

Instancias del modulo:
- Web01-C: `10.30.1.48`
- Web02-C: `10.30.1.121`

El modulo consume la tabla `profesores` de la base `DB_UFV`, mostrando informacion real de cada profesor: nombre, email, departamento, especialidad y fecha de alta.

Rutas principales:
- `/profesores/`: interfaz web del modulo.
- `/profesores/lista`: listado JSON de profesores.
- `/profesores/resumen`: resumen del modulo.
- `/health`: comprobacion de salud del servicio.

Ruta de acceso desde el cliente Windows:

`http://www.corp.ufv.local/profesores/`
```

Evidencias de C:

```powershell
curl http://www.corp.ufv.local/profesores/resumen
curl http://www.corp.ufv.local/profesores/lista
```

Capturas que debe aportar C:

- Pagina `/profesores/` cargada desde el cliente Windows.
- JSON de `/profesores/lista` con profesores reales.
- JSON de `/profesores/resumen`.
- Servicio Node activo.
- Nginx activo.

## 3.2 Punto 8.2 - Modulo Alumnos - Alumno D

Texto para pegar:

```md
El alumno D implementa el modulo `/alumnos/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.40.0.0/16`. El modulo queda integrado con el Load Balancer del alumno B y consulta la base de datos PostgreSQL central para obtener informacion academica de los alumnos.

Instancias del modulo:
- Web01-D: `10.40.1.102`
- Web02-D: `10.40.1.100`

El modulo trabaja con la tabla `alumnos` de la base `DB_UFV`, mostrando informacion como nombre, apellido, email, carrera, curso y fecha de registro.

Rutas principales:
- `/alumnos/`: interfaz web del modulo.
- `/alumnos/lista`: listado JSON de alumnos.

Ruta de acceso desde el cliente Windows:

`http://www.corp.ufv.local/alumnos/`
```

Evidencias de D:

```powershell
curl http://www.corp.ufv.local/alumnos/lista
```

Capturas que debe aportar D:

- Pagina `/alumnos/` cargada desde el cliente Windows.
- JSON de `/alumnos/lista`.
- Servicio web activo.
- Nginx activo.

## 3.3 Punto 8.3 - Modulo Practicas - Alumno E

Texto para pegar:

```md
El alumno E implementa el modulo `/practicas/`, desplegado sobre dos instancias Ubuntu dentro de la VPC `10.50.0.0/16`. Cada instancia ejecuta Nginx y un servicio Node.js que consulta PostgreSQL y se integra con Amazon S3 mediante IAM Role.

Instancias del modulo:
- Web01-E: `10.50.1.175`
- Web02-E: `10.50.1.58`

El modulo consume la base `DB_UFV` del alumno B. Para cumplir la funcionalidad de practicas se utilizan las tablas:

- `practicas`: descripcion de practicas, alumno asociado, profesor, fecha de entrega, calificacion y estado.
- `entregas`: registro de entregas asociadas a practicas y alumnos.

La web permite consultar practicas, consultar entregas y crear nuevas entregas desde el frontend. Tambien incorpora una comprobacion de integracion con S3, creando evidencias en el bucket del alumno E sin utilizar claves estaticas, gracias al IAM Role asociado a las instancias EC2.

Rutas principales:
- `/practicas/`: interfaz web del modulo.
- `/practicas/resumen`: resumen de practicas.
- `/practicas/lista`: listado JSON de practicas.
- `/practicas/entregas`: consulta y creacion de entregas.
- `/practicas/s3/status`: validacion de acceso al bucket S3.
- `/practicas/evidencias`: creacion de evidencias en S3.

Ruta de acceso desde el cliente Windows:

`http://www.corp.ufv.local/practicas/`
```

Evidencias de E:

```powershell
curl http://www.corp.ufv.local/practicas/resumen
curl http://www.corp.ufv.local/practicas/lista
curl http://www.corp.ufv.local/practicas/entregas
curl http://www.corp.ufv.local/practicas/s3/status
```

Capturas que debe aportar E:

- Pagina `/practicas/` cargada desde el cliente Windows.
- Tabla de practicas cargada desde PostgreSQL.
- Tabla de entregas cargada desde PostgreSQL.
- Creacion de una entrega desde el formulario.
- Endpoint `/practicas/s3/status`.
- Objeto creado en S3 bajo `practicas/evidencias/`.

## 4. Punto 9 - Integracion de Servicios: DNS, PostgreSQL y S3

Recomendacion: cambiar el titulo actual `9. Integracion con AWS S3` por:

```md
9. Integracion de Servicios: DNS, PostgreSQL y S3
```

Motivo: el punto no trata solo de S3. Tambien recoge la integracion entre modulos mediante el Load Balancer, la resolucion DNS corporativa, la conexion a PostgreSQL y el uso de variables de entorno. Con el titulo actual parece que todo el apartado va solo de almacenamiento S3, y eso se queda corto para lo que realmente habeis implementado.

Subapartados recomendados:

```md
9. Integracion de Servicios: DNS, PostgreSQL y S3
9.1 Resolucion DNS corporativa
9.2 Integracion entre modulos mediante Load Balancer
9.3 Conexion de Web Servers con PostgreSQL
9.4 Variables de entorno y usuarios de BBDD
9.5 Integracion real con Amazon S3
```

## 4.1 Punto 9.1 - Resolucion DNS corporativa

Texto para pegar:

```md
El acceso interno se realiza mediante el dominio corporativo `www.corp.ufv.local`, resuelto desde el servidor DNS del entorno Windows del alumno A. El registro DNS apunta a la IP privada del Load Balancer del alumno B, permitiendo que el cliente Windows acceda a todos los modulos mediante una URL corporativa comun.

La resolucion DNS se valida desde el cliente Windows con `nslookup`, y la conectividad HTTP se comprueba con `Test-NetConnection` hacia el puerto 80.
```

Pruebas:

```powershell
nslookup www.corp.ufv.local
Test-NetConnection www.corp.ufv.local -Port 80
```

## 4.2 Punto 9.2 - Integracion entre modulos mediante Load Balancer

Texto para pegar:

```md
La integracion entre modulos se realiza mediante el Load Balancer Nginx del alumno B. El balanceador recibe las peticiones HTTP y enruta cada prefijo de URL al upstream correspondiente.

Rutas configuradas:
- `/profesores/` -> servidores del alumno C (`10.30.1.48`, `10.30.1.121`)
- `/alumnos/` -> servidores del alumno D (`10.40.1.102`, `10.40.1.100`)
- `/practicas/` -> servidores del alumno E (`10.50.1.175`, `10.50.1.58`)

La configuracion del `proxy_pass` conserva el path original para que tanto las paginas HTML como los endpoints JSON de cada modulo funcionen correctamente. Esto permite que rutas internas como `/profesores/lista`, `/alumnos/lista`, `/practicas/lista` o `/practicas/entregas` lleguen al backend correcto.
```

## 4.3 Punto 9.3 - Conexion de Web Servers con PostgreSQL

Texto para pegar:

```md
La base de datos central se encuentra en la VPC del alumno B y es accesible desde los modulos web mediante VPC Peering. La comunicacion se realiza por la red privada de AWS, evitando exponer PostgreSQL directamente a Internet.

Datos de conexion:
- Host: `10.20.1.221`
- Puerto: `5432`
- Base de datos: `DB_UFV`

Tablas principales:
- `profesores`: consumida por el modulo `/profesores/`.
- `alumnos`: consumida por el modulo `/alumnos/`.
- `practicas`: consumida por el modulo `/practicas/`.
- `entregas`: usada por `/practicas/` para registrar entregas.
```

Pruebas:

```bash
psql -h 10.20.1.221 -U backend_read -d DB_UFV
SELECT * FROM profesores;
SELECT * FROM alumnos;
SELECT * FROM practicas;
SELECT * FROM entregas;
```

## 4.4 Punto 9.4 - Variables de entorno y usuarios de BBDD

Texto para pegar:

```md
La configuracion de acceso a la base de datos se externaliza mediante variables de entorno. Esto permite modificar host, puerto, base de datos o credenciales sin alterar el codigo fuente de la aplicacion.

Variables utilizadas:

DB_HOST=10.20.1.221
DB_PORT=5432
DB_NAME=DB_UFV
DB_USER_READ=backend_read
DB_PASSWORD_READ=PassRead1!
DB_USER_WRITE=backend_write
DB_PASSWORD_WRITE=PassWrite1!

Se separan permisos de lectura y escritura. El usuario `backend_read` se usa para consultas `SELECT`, mientras que `backend_write` se reserva para operaciones que modifican datos, como la creacion de entregas en el modulo `/practicas/`.
```

## 4.5 Punto 9.5 - Integracion real con Amazon S3

Texto para pegar:

```md
Los Web Servers disponen de buckets S3 propios creados desde CloudFormation y asociados a las instancias EC2 mediante IAM Role. De esta forma, las aplicaciones pueden acceder a S3 sin almacenar claves de acceso en el codigo fuente.

En el modulo `/practicas/`, el alumno E implementa una prueba funcional de S3 mediante:

- `/practicas/s3/status`: comprueba el acceso al bucket.
- `/practicas/evidencias`: crea una evidencia JSON en S3.

Las evidencias quedan almacenadas bajo el prefijo:

`practicas/evidencias/`

Esto demuestra el uso de S3 desde la aplicacion web y valida que el rol IAM asociado a la instancia EC2 funciona correctamente.
```

## 5. Punto 11 - Pruebas de Integracion y Validacion

Este punto debe llevar capturas. Es donde se demuestra que todo lo anterior no es solo teoria.

Estructura recomendada:

```md
11. Pruebas de Integracion y Validacion
11.1 Validacion DNS corporativo
11.2 Validacion VPC Peering
11.3 Validacion del Load Balancer
11.4 Validacion modulo Profesores
11.5 Validacion modulo Alumnos
11.6 Validacion modulo Practicas
11.7 Validacion PostgreSQL
11.8 Validacion S3
11.9 Incidencias encontradas y solucionadas
```

Comandos de validacion global:

```powershell
curl http://www.corp.ufv.local/profesores/lista
curl http://www.corp.ufv.local/alumnos/lista
curl http://www.corp.ufv.local/practicas/lista
curl http://www.corp.ufv.local/practicas/entregas
curl http://www.corp.ufv.local/practicas/s3/status
```

Resultado esperado:

- HTTP 200 en todos los endpoints.
- JSON real procedente de PostgreSQL.
- Webs cargadas desde `www.corp.ufv.local`.
- Practicas con integracion S3 operativa.

Texto para incidencias:

```md
Durante la integracion se detectaron varias incidencias reales:

1. El registro DNS `www.corp.ufv.local` resolvia correctamente, pero el cliente Windows no alcanzaba el Load Balancer porque algunos peerings habian sido eliminados. Se recrearon los peerings y se validaron las rutas.
2. Algunos modulos cargaban la pagina HTML pero no los datos porque Nginx no reenviaba correctamente las rutas API. Se corrigio el `proxy_pass` para conservar el path original.
3. El modulo `/profesores/` inicialmente servia datos estaticos. Se adapto el servicio para consultar la tabla `profesores` de `DB_UFV`.
4. El modulo `/practicas/` se amplio para incluir `entregas`, creacion de entregas y validacion de S3.
5. Internet Explorer del cliente Windows no ejecutaba correctamente parte del JavaScript moderno, por lo que se instalo Microsoft Edge para validar la interfaz web.
```

## 6. Punto 12 - Conclusiones y Lecciones Aprendidas

Texto posible:

```md
La practica demuestra una integracion real entre multiples cuentas AWS, combinando servicios Windows y Linux. La solucion final permite que un cliente Windows unido al dominio acceda mediante DNS corporativo a un Load Balancer Linux que distribuye trafico hacia modulos web desplegados en otras cuentas. Los modulos consumen una base PostgreSQL central y utilizan S3 mediante roles IAM, evitando credenciales estaticas.

Las principales dificultades estuvieron relacionadas con la coordinacion entre cuentas: peerings eliminados, rutas incompletas, Security Groups restrictivos, configuraciones de Nginx y diferencias entre IPs publicas y privadas. La resolucion de estas incidencias permitio validar de forma real conceptos de red, seguridad, DNS, balanceo, backend y persistencia.
```

## 7. Tablas de apoyo para la documentacion

Estas tablas no sustituyen la tabla `2.4`; son solo anexos utiles para los apartados 8, 9 u 11.

### 7.1 IPs privadas finales

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

### 7.2 Endpoints finales

| Ruta | Modulo | Funcion |
|---|---|---|
| `/profesores/` | C | Interfaz profesores |
| `/profesores/lista` | C | JSON profesores |
| `/profesores/resumen` | C | Resumen profesores |
| `/alumnos/` | D | Interfaz alumnos |
| `/alumnos/lista` | D | JSON alumnos |
| `/practicas/` | E | Interfaz practicas |
| `/practicas/lista` | E | JSON practicas |
| `/practicas/entregas` | E | Consulta y creacion de entregas |
| `/practicas/s3/status` | E | Validacion S3 |

## 8. Checklist final

- [ ] Completar punto 7 con LB y DB de B.
- [ ] Completar punto 8 con introduccion de Web Servers.
- [ ] Completar punto 8.1 con modulo C.
- [ ] Completar punto 8.2 con modulo D.
- [ ] Completar punto 8.3 con modulo E.
- [ ] Cambiar el titulo del punto 9 a `Integracion de Servicios: DNS, PostgreSQL y S3`.
- [ ] Completar punto 9 con DNS, integracion, PostgreSQL, variables y S3.
- [ ] Completar punto 11 con pruebas reales.
- [ ] Completar punto 12 con conclusiones tecnicas.
- [ ] Meter capturas de C, D y E funcionando por `www.corp.ufv.local`.
- [ ] Meter capturas de endpoints JSON.
- [ ] Meter capturas de S3 del modulo E.
- [ ] Meter capturas de peerings activos.
- [ ] Meter captura de `nslookup www.corp.ufv.local`.
- [ ] Meter captura de `Test-NetConnection www.corp.ufv.local -Port 80`.
- [ ] Anadir incidencias y soluciones.
- [ ] No modificar la tabla `2.4`.
- [ ] No modificar el bloque `PARTE DE GONYO NO TOCAR LUEGO LO ORGANIZO`.
