# Codigo de modulos web

Esta carpeta contiene el codigo de referencia de los modulos web usados en la solucion final:

- `profesores.js` y `profesores.html`: modulo `/profesores/` del Alumno C.
- `alumnos.js`: modulo `/alumnos/` del Alumno D.
- `practicas.js` y `practicas.html`: modulo `/practicas/` del Alumno E.
- `package.json`: dependencias Node.js comunes.

En la practica, estos ficheros se desplegaron en las instancias EC2 correspondientes y se sirvieron mediante Nginx y servicios Node.js.

El modulo del Alumno E incluye:

- Consulta de practicas desde PostgreSQL.
- Consulta y creacion de entregas.
- Validacion de acceso a S3.
- Creacion de evidencias en S3.

