@echo off
setlocal
title Generador de proyecto base CRUD - Node.js + Express + Sequelize + MySQL

rem =====================================================================
rem  CREAR-PROYECTO-BASE.BAT
rem  Crea, en la misma carpeta donde esta este archivo:
rem    1. "proyecto-inicial"       -> base generica lista para un CRUD
rem                                   (Express 5 + Sequelize + MySQL)
rem    2. "biblioteca-api-original"-> copia del proyecto original, solo
rem                                   codigo de referencia (sin .env, sin
rem                                   base de datos y sin npm install)
rem
rem  Uso:
rem    Doble clic                          -> crea "proyecto-inicial"
rem    crear-proyecto-base.bat mi-api      -> crea "mi-api"
rem    (nombre en minusculas, sin espacios ni tildes)
rem
rem  Para cambiar las plantillas: edita los archivos que estan al final,
rem  debajo de cada linea "::@@BASE ruta" o "::@@ORIGINAL ruta".
rem =====================================================================

set "NOMBRE=proyecto-inicial"
if not "%~1"=="" set "NOMBRE=%~1"
set "BASE_BAT=%~f0"
set "DESTINO=%~dp0%NOMBRE%"
set "ORIGINAL=%~dp0biblioteca-api-original"

echo.
echo  Proyecto : %NOMBRE%
echo  Destino  : %DESTINO%
echo.

if exist "%DESTINO%\" goto :ya_existe

echo [1/4] Creando carpetas...
mkdir "%DESTINO%"
if errorlevel 1 goto :error
mkdir "%DESTINO%\db"
mkdir "%DESTINO%\http"
mkdir "%DESTINO%\scripts"
mkdir "%DESTINO%\src"
mkdir "%DESTINO%\src\config"
mkdir "%DESTINO%\src\controllers"
mkdir "%DESTINO%\src\middlewares"
mkdir "%DESTINO%\src\models"
mkdir "%DESTINO%\src\repositories"
mkdir "%DESTINO%\src\routes"
mkdir "%DESTINO%\src\services"
mkdir "%DESTINO%\src\utils"
mkdir "%DESTINO%\src\validators"

echo [2/4] Creando archivos de la base...
set "MARCA=::@@BASE "
set "SALIDA=%DESTINO%"
call :extraer
if errorlevel 1 goto :error

echo [3/4] Copiando el proyecto original (solo referencia)...
if exist "%ORIGINAL%\" goto :original_existe
set "MARCA=::@@ORIGINAL "
set "SALIDA=%ORIGINAL%"
call :extraer
if errorlevel 1 goto :error
goto :instalar

:original_existe
echo    Ya existe "biblioteca-api-original": no se toco.

:instalar
echo [4/4] Instalando dependencias (npm install)...
where npm >nul 2>nul
if errorlevel 1 goto :sin_node
pushd "%DESTINO%"
call npm install
if errorlevel 1 echo  AVISO: npm install fallo. Entra a la carpeta y ejecutalo de nuevo.
popd
goto :listo

:sin_node
echo  AVISO: no se encontro Node.js / npm. Instalalo desde https://nodejs.org
echo         y luego ejecuta "npm install" dentro de la carpeta del proyecto.

:listo
echo.
echo  ============================================================
echo   Proyecto creado en: %DESTINO%
echo   Copia del original: %ORIGINAL%
echo  ============================================================
echo   Siguientes pasos:
echo     1. cd "%NOMBRE%"
echo     2. Revisa usuario y clave de MySQL en el archivo .env
echo     3. npm run db:crear     crea la base de datos y las tablas
echo     4. npm run dev          levanta la API en http://localhost:3000/api
echo     5. Prueba las peticiones de http\items.http
echo.
echo   Nuevo recurso:  npm run crear:recurso -- producto productos
echo.
pause
exit /b 0

:ya_existe
echo  ERROR: ya existe la carpeta "%NOMBRE%" en esta ubicacion.
echo  Borrala, renombrala o indica otro nombre:
echo     crear-proyecto-base.bat otro-nombre
echo.
pause
exit /b 1

:error
echo.
echo  ERROR: no se pudo crear el proyecto. Revisa los mensajes de arriba.
pause
exit /b 1

rem ---------------------------------------------------------------------
rem  Subrutina: escribe en %SALIDA% los archivos marcados con %MARCA%
rem ---------------------------------------------------------------------
:extraer
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $enc=New-Object Text.UTF8Encoding($false); $m=$env:MARCA; $w=$null; foreach($l in [IO.File]::ReadAllLines($env:BASE_BAT,$enc)){ if($l.StartsWith($m)){ if($w){$w.Close()}; $r=$l.Substring($m.Length).Trim(); $p=Join-Path $env:SALIDA $r; [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($p)); $w=New-Object IO.StreamWriter($p,$false,$enc); Write-Host ('   + '+$r) } elseif($l -eq '::@@FIN'){ if($w){$w.Close(); $w=$null} } elseif($w){ $w.WriteLine($l.Replace('__NOMBRE__',$env:NOMBRE)) } }; if($w){$w.Close()}"
exit /b %errorlevel%

rem =====================================================================
rem  PLANTILLAS: desde aqui cmd ya no lee nada. Cada bloque es un archivo.
rem  ::@@BASE = base generica      ::@@ORIGINAL = proyecto original
rem =====================================================================

::@@BASE package.json
{
  "name": "__NOMBRE__",
  "version": "1.0.0",
  "description": "Base reutilizable para API REST CRUD (Express + Sequelize + MySQL)",
  "main": "src/server.js",
  "type": "module",
  "scripts": {
    "start": "node src/server.js",
    "dev": "node --watch src/server.js",
    "db:probar": "node index.js",
    "db:crear": "node scripts/crear-bd.js",
    "crear:recurso": "node scripts/crear-recurso.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "cors": "^2.8.6",
    "dotenv": "^18.0.9",
    "express": "^5.3.0",
    "morgan": "^1.12.1",
    "mysql2": "^3.24.6",
    "sequelize": "^6.37.8"
  }
}
::@@FIN

::@@BASE .env
# Servidor
PORT=3000

# Base de datos (usuario con el que trabaja la API)
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=proyecto_inicial
DB_CONNECTION_LIMIT=10
# true = muestra en consola cada consulta SQL
DB_LOGGING=false

# Usuario administrador (solo lo usa "npm run db:crear" para crear la base)
DB_ROOT_USER=root
DB_ROOT_PASSWORD=
::@@FIN

::@@BASE .env.example
# Servidor
PORT=3000

# Base de datos (usuario con el que trabaja la API)
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=proyecto_inicial
DB_CONNECTION_LIMIT=10
# true = muestra en consola cada consulta SQL
DB_LOGGING=false

# Usuario administrador (solo lo usa "npm run db:crear" para crear la base)
DB_ROOT_USER=root
DB_ROOT_PASSWORD=
::@@FIN

::@@BASE .gitignore
node_modules/
.env
::@@FIN

::@@BASE README.md
# Base CRUD (Express 5 + Sequelize + MySQL)

Generado con `crear-proyecto-base.bat`. Incluye un recurso de ejemplo (`items`) con el CRUD completo.

## Puesta en marcha

1. Enciende MySQL (XAMPP u otro) y revisa usuario y contraseña en `.env`.
2. `npm run db:crear`: crea la base de datos y las tablas.
3. `npm run dev`: levanta la API en http://localhost:3000/api
4. Prueba las peticiones de `http/items.http` (extensión REST Client).

## Comandos

| Comando | Qué hace |
|---|---|
| `npm run dev` | Servidor con reinicio automático |
| `npm start` | Servidor normal |
| `npm run db:probar` | Verifica la conexión a MySQL |
| `npm run db:crear` | Crea la base y las tablas que falten |
| `npm run crear:recurso -- producto productos` | Copia el CRUD de `items` con otro nombre y lo registra |

## Rutas de cada recurso

| Método | Ruta | Acción |
|---|---|---|
| GET | `/api/items` | Listar todo |
| GET | `/api/items/buscar?q=texto` | Buscar por texto |
| GET | `/api/items/por/:campo/:valor` | Listar por el valor de una columna (ej. `/por/estado/publicado`) |
| GET | `/api/items/:id` | Obtener uno |
| POST | `/api/items` | Crear |
| PUT | `/api/items/:id` | Actualizar (solo los campos enviados) |
| DELETE | `/api/items/:id` | Eliminar |

## Capas (una petición las recorre en este orden)

`routes` → `middlewares` (validar id) → `controllers` → `services` (validan) → `repositories` → `models`

- `src/validators/validadores.js`: reglas reutilizables (texto, entero, decimal, booleano, fecha, hora, email...).
- `src/validators/items.validator.js`: esquema del recurso; define qué campos se aceptan.
- `src/models/item.model.js`: columnas; arriba tiene la tabla de tipos de datos.
- `src/utils/errores-bd.js`: convierte errores de MySQL en respuestas 400 / 409 / 503.

## Adaptar a otro caso

1. `npm run crear:recurso -- <singular> <plural>` (o renombra `items` a mano).
2. Edita los campos del modelo y del validador.
3. Ajusta `CAMPOS_BUSQUEDA` y `ORDEN` (repositorio) y `CAMPOS_FILTRO` (servicio).
4. `npm run db:crear`.
::@@FIN

::@@BASE index.js
// Prueba rápida de conexión:  npm run db:probar
import { probarConexion, cerrarConexion } from './src/config/db.js';
try {
    const info = await probarConexion();
    console.log('Conexion MYSQL exitosa');
    console.table(info);
} catch (err) {
    console.error('No se pudo conectar');
    console.error(`Error: ${err.code ?? err.original?.code ?? '-'}`);
    console.error(`Mensaje: ${err.message}`);
} finally {
    await cerrarConexion();
}
::@@FIN

::@@BASE src/config/env.js
import 'dotenv/config';

export const env = {
    port: Number(process.env.PORT ?? 3000),
    db: {
        host: process.env.DB_HOST ?? 'localhost',
        port: Number(process.env.DB_PORT ?? 3306),
        user: process.env.DB_USER ?? 'root',
        password: process.env.DB_PASSWORD ?? '',
        database: process.env.DB_NAME ?? 'proyecto_inicial',
        connectionLimit: Number(process.env.DB_CONNECTION_LIMIT ?? 10),
        logging: process.env.DB_LOGGING === 'true'
    },
    root: {
        user: process.env.DB_ROOT_USER ?? 'root',
        password: process.env.DB_ROOT_PASSWORD ?? ''
    }
};
::@@FIN

::@@BASE src/config/db.js
import { Sequelize, QueryTypes } from 'sequelize';
import { env } from './env.js';

export const sequelize = new Sequelize(
    env.db.database,
    env.db.user,
    env.db.password,
    {
        host: env.db.host,
        port: env.db.port,
        dialect: 'mysql',
        logging: env.db.logging ? (sql) => console.log(`[SQL] ${sql}`) : false,
        pool: { max: env.db.connectionLimit, min: 0, acquire: 30000, idle: 10000 },
        define: {
            freezeTableName: true,
            timestamps: false
        },
        dialectOptions: { decimalNumbers: true }
    }
);

export async function probarConexion() {
    await sequelize.authenticate();
    const [info] = await sequelize.query(' SELECT DATABASE() AS bd,' +
        ' CURRENT_USER() as usuario, VERSION() as version',
        { type: QueryTypes.SELECT });
    return info;
}

export const cerrarConexion = () => sequelize.close();
::@@FIN

::@@BASE src/app.js
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import routes from './routes/index.js';
import { rutaNoEncontrada, manejadorErrores } from './middlewares/error.middleware.js';

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('dev')); // registra: METODO /ruta estado tiempo
app.use('/api', routes);
app.use(rutaNoEncontrada);
app.use(manejadorErrores);

export default app;
::@@FIN

::@@BASE src/server.js
import app from './app.js';
import { env } from './config/env.js';
import { probarConexion } from './config/db.js';

try {
    const info = await probarConexion();
    console.log(`MySql conectado: ${info.bd} como ${info.usuario}`);
} catch (err) {
    console.error(`No se pudo conectar a MySql: ${err.message}`);
}

app.listen(env.port, () => {
    console.log(`API en http://localhost:${env.port}/api`);
});
::@@FIN

::@@BASE src/utils/http-error.js
// Error con código HTTP: lo lanzan los servicios y lo responde el manejador central
export class HttpError extends Error {
  constructor(status, message, detalles) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
    if (detalles) this.detalles = detalles;
  }
}

export const solicitudInvalida = (mensaje, detalles) => new HttpError(400, mensaje, detalles);
export const noEncontrado = (recurso) => new HttpError(404, `${recurso} no existe`);
export const conflicto = (mensaje) => new HttpError(409, mensaje);
::@@FIN

::@@BASE src/utils/errores-bd.js
// Traduce los errores de Sequelize y MySQL a errores HTTP comprensibles.
import {
  UniqueConstraintError,
  ForeignKeyConstraintError,
  ValidationError,
  DatabaseError,
  ConnectionError
} from 'sequelize';
import { HttpError } from './http-error.js';

const nombreRestriccion = (msg = '') => msg.match(/constraint\s+[`'"](\w+)[`'"]/i)?.[1];

export function traducirErrorBD(err) {
  // UNIQUE (campos únicos, p. ej. codigo) -> 409
  // Va antes que ValidationError porque UniqueConstraintError hereda de él.
  if (err instanceof UniqueConstraintError) {
    const campos = Object.keys(err.fields ?? {}).join(', ');
    return new HttpError(409, `Ya existe un registro con ese valor${campos ? ` (${campos})` : ''}`);
  }

  // FOREIGN KEY: 1451 al borrar un padre con hijos, 1452 al referenciar algo inexistente
  if (err instanceof ForeignKeyConstraintError) {
    const fk = nombreRestriccion(err.original?.sqlMessage);
    return err.original?.errno === 1451
      ? new HttpError(409, 'No se puede eliminar: existen registros relacionados', fk && [fk])
      : new HttpError(400, 'La referencia indicada no existe', fk && [fk]);
  }

  // Validadores del modelo (notEmpty, is, min, validaciones propias...) -> 400
  if (err instanceof ValidationError) {
    return new HttpError(400, 'Datos no válidos', err.errors.map((e) => e.message));
  }

  // Servidor apagado, credenciales incorrectas, base inexistente -> 503
  if (err instanceof ConnectionError) {
    return new HttpError(503, 'La base de datos no está disponible');
  }

  // CHECK: 3819 en MySQL 8, 4025 en MariaDB (XAMPP) -> 400
  if (err instanceof DatabaseError && [3819, 4025].includes(err.original?.errno)) {
    const ck = nombreRestriccion(err.original.sqlMessage) ?? err.original.sqlMessage;
    return new HttpError(400, 'Se violó una regla de la base de datos', [ck]);
  }

  return err;
}
::@@FIN

::@@BASE src/utils/plano.js
export const plano = (fila) => (fila ? fila.get({ plain: true }) : null);
::@@FIN

::@@BASE src/middlewares/error.middleware.js
import { traducirErrorBD } from '../utils/errores-bd.js';

// Ruta inexistente -> 404 en JSON
export function rutaNoEncontrada(req, res) {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
}

// Manejador central: todos los errores terminan aquí.
// Express 5 envía a este middleware los errores de funciones async.
export function manejadorErrores(err, req, res, next) {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'El cuerpo no es un JSON válido' });
  }
  const error = traducirErrorBD(err); // errores de Sequelize y MySQL
  const status = error.status ?? 500;
  if (status >= 500) console.error(err);
  res.status(status).json({
    error: status === 500 ? 'Error interno del servidor' : error.message,
    ...(error.detalles && { detalles: error.detalles })
  });
}
::@@FIN

::@@BASE src/middlewares/validar-id.middleware.js
// Rechaza ids que no sean enteros positivos antes de llegar al controlador
export function validarId(req, res, next) {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id < 1) {
    return res.status(400).json({ error: 'El id debe ser un entero positivo' });
  }
  next();
}
::@@FIN

::@@BASE src/validators/validadores.js
// Reglas de validación reutilizables para cualquier recurso.
// Cada regla recibe el valor y devuelve { error: 'mensaje' } o { valor: valorConvertido }.
import { solicitudInvalida } from '../utils/http-error.js';

const ok = (valor) => ({ valor });
const fallo = (error) => ({ error });
const aNumero = (v) => (typeof v === 'number' ? v : typeof v === 'string' && v !== '' ? Number(v) : NaN);

// ---------- Texto ----------
export const texto = ({ min = 0, max = Infinity } = {}) => (v) => {
    if (typeof v !== 'string') return fallo('debe ser un texto');
    if (v.length < min) return fallo(`debe tener al menos ${min} caracteres`);
    if (v.length > max) return fallo(`no puede superar los ${max} caracteres`);
    return ok(v);
};

export const patron = (regex, mensaje = 'no tiene el formato correcto') => (v) =>
    (typeof v === 'string' && regex.test(v) ? ok(v) : fallo(mensaje));

export const soloLetras = () => patron(/^[\p{L}\s'.-]+$/u, 'solo puede contener letras');

// Solo dígitos; longitud opcional (DNI: 8, RUC: 11, celular: 9)
export const soloDigitos = ({ longitud } = {}) => (v) => {
    const s = String(v);
    if (!/^\d+$/.test(s)) return fallo('solo puede contener dígitos');
    if (longitud && s.length !== longitud) return fallo(`debe tener ${longitud} dígitos`);
    return ok(s);
};

export const email = () => (v) =>
    (typeof v === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v)
        ? ok(v.toLowerCase())
        : fallo('no es un correo válido'));

export const telefono = () => patron(/^\+?[\d\s-]{6,15}$/, 'no es un teléfono válido');

export const url = () => (v) => {
    try {
        const u = new URL(v);
        return ['http:', 'https:'].includes(u.protocol) ? ok(v) : fallo('debe empezar con http:// o https://');
    } catch {
        return fallo('no es una URL válida');
    }
};

// ---------- Números ----------
export const entero = ({ min = -Infinity, max = Infinity } = {}) => (v) => {
    const n = aNumero(v);
    if (!Number.isInteger(n)) return fallo('debe ser un número entero');
    if (n < min) return fallo(`no puede ser menor que ${min}`);
    if (n > max) return fallo(`no puede ser mayor que ${max}`);
    return ok(n);
};

export const decimal = ({ min = -Infinity, max = Infinity, decimales = 2 } = {}) => (v) => {
    const n = aNumero(v);
    if (!Number.isFinite(n)) return fallo('debe ser un número');
    if (n < min) return fallo(`no puede ser menor que ${min}`);
    if (n > max) return fallo(`no puede ser mayor que ${max}`);
    if ((String(n).split('.')[1] ?? '').length > decimales) return fallo(`admite como máximo ${decimales} decimales`);
    return ok(n);
};

// ---------- Booleano ----------
export const booleano = () => (v) => {
    if (v === true || v === 'true' || v === 1 || v === '1') return ok(true);
    if (v === false || v === 'false' || v === 0 || v === '0') return ok(false);
    return fallo('debe ser verdadero o falso');
};

// ---------- Fechas y horas ----------
// Solo fecha: AAAA-MM-DD
export const fecha = ({ noFutura = false, noPasada = false } = {}) => (v) => {
    if (typeof v !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(v)) return fallo('debe tener el formato AAAA-MM-DD');
    const d = new Date(`${v}T00:00:00Z`);
    if (Number.isNaN(d.getTime()) || d.toISOString().slice(0, 10) !== v) return fallo('no es una fecha real');
    const hoy = new Date().toLocaleDateString('en-CA'); // AAAA-MM-DD en hora local
    if (noFutura && v > hoy) return fallo('no puede ser una fecha futura');
    if (noPasada && v < hoy) return fallo('no puede ser una fecha pasada');
    return ok(v);
};

// Fecha y hora: 2026-11-16T14:30:00 (formato ISO)
export const fechaHora = () => (v) => {
    if (typeof v !== 'string' || !/^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}/.test(v)) {
        return fallo('debe tener el formato AAAA-MM-DDTHH:mm:ss');
    }
    const d = new Date(v);
    return Number.isNaN(d.getTime()) ? fallo('no es una fecha y hora real') : ok(d);
};

// Solo hora: HH:mm o HH:mm:ss
export const hora = () => patron(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, 'debe tener el formato HH:mm');

// ---------- Listas ----------
export const enLista = (lista) => (v) =>
    (lista.includes(v) ? ok(v) : fallo(`debe ser uno de: ${lista.join(', ')}`));

// ---------- Motor ----------
// esquema = { campo: { requerido: true|false, nulo: true|false, reglas: [regla, ...] } }
//   requerido: el campo debe venir al crear.
//   nulo: false -> un campo opcional no acepta null (útil si tiene valor por defecto).
// parcial = true -> solo valida los campos enviados (al actualizar).
// Si hay errores lanza un 400 con la lista; si no, devuelve solo los campos
// del esquema, ya limpios (sin espacios sobrantes y con el tipo correcto).
export function validar(esquema, datos, parcial = false) {
    if (datos === null || typeof datos !== 'object' || Array.isArray(datos)) {
        throw solicitudInvalida('El cuerpo debe ser un objeto JSON');
    }
    const errores = [];
    const valores = {};
    for (const [campo, { requerido = false, nulo = true, reglas = [] }] of Object.entries(esquema)) {
        let valor = datos[campo];
        if (typeof valor === 'string') valor = valor.trim();

        if (valor === undefined) {
            if (requerido && !parcial) errores.push(`${campo} es obligatorio`);
            continue;
        }
        if (valor === null || valor === '') {
            if (requerido) errores.push(`${campo} es obligatorio`);
            else if (!nulo) errores.push(`${campo} no puede estar vacío`);
            else valores[campo] = null;
            continue;
        }

        let valido = true;
        for (const regla of reglas) {
            const resultado = regla(valor);
            if (resultado.error) {
                errores.push(`${campo} ${resultado.error}`);
                valido = false;
                break;
            }
            valor = resultado.valor;
        }
        if (valido) valores[campo] = valor;
    }
    if (errores.length > 0) throw solicitudInvalida('Datos no válidos', errores);
    return valores;
}
::@@FIN

::@@BASE src/validators/items.validator.js
import {
    texto, patron, entero, decimal, booleano, fecha, fechaHora, hora, email, enLista
    // también disponibles: soloLetras, soloDigitos, telefono, url
} from './validadores.js';
import { ESTADOS } from '../models/item.model.js';

// Un campo por cada dato que el cliente puede enviar.
// Lo que no esté aquí se ignora (así nadie puede enviar "id" u otros campos internos).
export const esquema = {
    codigo: {
        requerido: true,
        reglas: [texto({ min: 3, max: 20 }), patron(/^[A-Za-z0-9-]+$/, 'solo admite letras, números y guiones')]
    },
    nombre: { requerido: true, reglas: [texto({ min: 2, max: 100 })] },
    descripcion: { reglas: [texto({ max: 2000 })] },
    cantidad: { nulo: false, reglas: [entero({ min: 0 })] },
    precio: { requerido: true, reglas: [decimal({ min: 0, decimales: 2 })] },
    calificacion: { reglas: [decimal({ min: 0, max: 5, decimales: 1 })] },
    activo: { nulo: false, reglas: [booleano()] },
    estado: { nulo: false, reglas: [enLista(ESTADOS)] },
    email: { reglas: [texto({ max: 120 }), email()] },
    fecha_vencimiento: { reglas: [fecha()] }, // opciones: fecha({ noPasada: true }) o fecha({ noFutura: true })
    fecha_publicacion: { reglas: [fechaHora()] },
    hora_apertura: { reglas: [hora()] }
};
::@@FIN

::@@BASE src/models/item.model.js
import { DataTypes } from 'sequelize';
import { sequelize } from '../config/db.js';

/*
  TIPOS DE DATOS BÁSICOS (Sequelize -> MySQL)
  ------------------------------------------------------------------
  DataTypes.STRING(n)        VARCHAR(n)      texto corto (nombre, código, email)
  DataTypes.CHAR(n)          CHAR(n)         texto de largo fijo (DNI, RUC)
  DataTypes.TEXT             TEXT            texto largo (descripción)
  DataTypes.INTEGER          INT             enteros (cantidad, stock, ids)
  DataTypes.SMALLINT         SMALLINT        enteros pequeños (año, edad)
  DataTypes.BIGINT           BIGINT          enteros muy grandes
  DataTypes.DECIMAL(p, e)    DECIMAL(p,e)    dinero: exacto (precio, total)
  DataTypes.FLOAT            FLOAT           decimales aproximados (promedio)
  DataTypes.BOOLEAN          TINYINT(1)      verdadero / falso
  DataTypes.DATEONLY         DATE            solo fecha  (2026-11-16)
  DataTypes.DATE             DATETIME        fecha y hora
  DataTypes.TIME             TIME            solo hora   (08:30:00)
  DataTypes.ENUM('a', 'b')   ENUM            lista cerrada de valores
  ------------------------------------------------------------------
  Al adaptar: borra los campos que no uses y renombra los demás.
*/

export const ESTADOS = ['borrador', 'publicado', 'archivado'];

export const Item = sequelize.define(
    'Item',
    {
        // INTEGER: clave primaria autoincremental
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        // STRING único y obligatorio
        codigo: {
            type: DataTypes.STRING(20),
            allowNull: false,
            unique: true,
            validate: {
                notNull: { msg: 'el código es obligatorio' },
                notEmpty: { msg: 'el código no puede estar vacío' }
            }
        },
        // STRING obligatorio
        nombre: {
            type: DataTypes.STRING(100),
            allowNull: false,
            validate: {
                notNull: { msg: 'el nombre es obligatorio' },
                notEmpty: { msg: 'el nombre no puede estar vacío' },
                len: { args: [2, 100], msg: 'el nombre debe tener entre 2 y 100 caracteres' }
            }
        },
        // TEXT opcional
        descripcion: { type: DataTypes.TEXT, allowNull: true },
        // INTEGER con valor por defecto y mínimo
        cantidad: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 0,
            validate: {
                isInt: { msg: 'la cantidad debe ser un número entero' },
                min: { args: [0], msg: 'la cantidad no puede ser negativa' }
            }
        },
        // DECIMAL para dinero
        precio: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
            validate: {
                notNull: { msg: 'el precio es obligatorio' },
                isDecimal: { msg: 'el precio debe ser un número' },
                min: { args: [0], msg: 'el precio no puede ser negativo' }
            }
        },
        // FLOAT opcional con rango
        calificacion: {
            type: DataTypes.FLOAT,
            allowNull: true,
            validate: {
                min: { args: [0], msg: 'la calificación mínima es 0' },
                max: { args: [5], msg: 'la calificación máxima es 5' }
            }
        },
        // BOOLEAN
        activo: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true
        },
        // ENUM
        estado: {
            type: DataTypes.ENUM(...ESTADOS),
            allowNull: false,
            defaultValue: 'borrador',
            validate: {
                isIn: { args: [ESTADOS], msg: `el estado debe ser uno de: ${ESTADOS.join(', ')}` }
            }
        },
        // STRING con formato de correo
        email: {
            type: DataTypes.STRING(120),
            allowNull: true,
            validate: { isEmail: { msg: 'el email no es válido' } }
        },
        // DATEONLY: solo fecha
        fecha_vencimiento: {
            type: DataTypes.DATEONLY,
            allowNull: true,
            validate: { isDate: { msg: 'la fecha de vencimiento no es válida' } }
        },
        // DATE: fecha y hora
        fecha_publicacion: {
            type: DataTypes.DATE,
            allowNull: true,
            validate: { isDate: { msg: 'la fecha de publicación no es válida' } }
        },
        // TIME: solo hora
        hora_apertura: { type: DataTypes.TIME, allowNull: true }

        // CLAVE FORÁNEA (ejemplo): descomenta y crea la asociación en models/index.js
        // categoria_id: { type: DataTypes.INTEGER, allowNull: false }
    },
    {
        tableName: 'items',
        // Columnas automáticas de auditoría (DATETIME)
        timestamps: true,
        createdAt: 'creado_en',
        updatedAt: 'actualizado_en',
        // Validación que compara varios campos a la vez
        validate: {
            publicadoConFecha() {
                if (this.estado === 'publicado' && !this.fecha_publicacion) {
                    throw new Error('un registro publicado debe tener fecha_publicacion');
                }
            }
        }
    }
);
::@@FIN

::@@BASE src/models/index.js
import { Item } from './item.model.js';
// [modelos:import] (no borrar: aquí inserta "npm run crear:recurso")

// ASOCIACIONES (ejemplo de 1 a muchos):
// Categoria.hasMany(Item, { foreignKey: 'categoria_id', as: 'items' });
// Item.belongsTo(Categoria, { foreignKey: 'categoria_id', as: 'categoria' });

export {
    Item,
    // [modelos:export] (no borrar)
};
::@@FIN

::@@BASE src/repositories/items.repository.js
import { Op } from 'sequelize';
import { Item } from '../models/index.js';
import { plano } from '../utils/plano.js';

// Columnas de texto donde busca el método buscar
const CAMPOS_BUSQUEDA = ['codigo', 'nombre', 'descripcion'];
// Columna por la que salen ordenados los listados
const ORDEN = [['nombre', 'ASC']];

export async function listar() {
    return (await Item.findAll({ order: ORDEN })).map(plano);
}

// Lista los registros que contienen el texto q en alguna columna de CAMPOS_BUSQUEDA
export async function buscar(q) {
    const where = {
        [Op.or]: CAMPOS_BUSQUEDA.map((campo) => ({ [campo]: { [Op.like]: `%${q}%` } }))
    };
    return (await Item.findAll({ where, order: ORDEN })).map(plano);
}

// Lista los registros cuya columna "campo" es exactamente igual a "valor"
export async function listarPor(campo, valor) {
    return (await Item.findAll({ where: { [campo]: valor }, order: ORDEN })).map(plano);
}

export async function buscarPorId(id) {
    return plano(await Item.findByPk(id));
}

export async function crear(datos) {
    return plano(await Item.create(datos));
}

export async function actualizar(id, datos) {
    const item = await Item.findByPk(id);
    if (!item) return null;
    return plano(await item.update(datos));
}

export async function eliminar(id) {
    return (await Item.destroy({ where: { id } })) > 0;
}
::@@FIN

::@@BASE src/services/items.service.js
import * as repo from '../repositories/items.repository.js';
import { noEncontrado, solicitudInvalida } from '../utils/http-error.js';
import { validar } from '../validators/validadores.js';
import { esquema } from '../validators/items.validator.js';

// Columnas por las que se permite listarPor (agrega o quita según tu tabla)
const CAMPOS_FILTRO = ['codigo', 'nombre', 'estado', 'activo', 'cantidad', 'precio', 'fecha_vencimiento'];

export const listar = () => repo.listar();

export async function buscar(q) {
    if (!q?.trim()) throw solicitudInvalida('Indica el texto a buscar: ?q=texto');
    return repo.buscar(q.trim());
}

export async function listarPor(campo, valor) {
    if (!CAMPOS_FILTRO.includes(campo)) {
        throw solicitudInvalida(`No se puede listar por "${campo}"`, [`campos permitidos: ${CAMPOS_FILTRO.join(', ')}`]);
    }
    // "true" y "false" llegan como texto en la URL: se convierten para las columnas BOOLEAN
    const convertido = valor === 'true' ? true : valor === 'false' ? false : valor;
    return repo.listarPor(campo, convertido);
}

export async function obtener(id) {
    const item = await repo.buscarPorId(id);
    if (!item) throw noEncontrado('Item');
    return item;
}

export async function crear(body) {
    const datos = validar(esquema, body);
    return repo.crear(datos);
}

export async function actualizar(id, body) {
    await obtener(id);
    const datos = validar(esquema, body, true); // true = parcial: solo valida lo enviado
    return repo.actualizar(id, datos);
}

export async function eliminar(id) {
    await obtener(id);
    await repo.eliminar(id);
}
::@@FIN

::@@BASE src/controllers/items.controller.js
import * as service from '../services/items.service.js';

export async function listar(req, res) {
    res.json(await service.listar());
}

export async function buscar(req, res) {
    res.json(await service.buscar(req.query.q));
}

export async function listarPor(req, res) {
    res.json(await service.listarPor(req.params.campo, req.params.valor));
}

export async function obtener(req, res) {
    res.json(await service.obtener(Number(req.params.id)));
}

export async function crear(req, res) {
    const creado = await service.crear(req.body);
    res.status(201).location(`${req.baseUrl}/${creado.id}`).json(creado);
}

export async function actualizar(req, res) {
    res.json(await service.actualizar(Number(req.params.id), req.body));
}

export async function eliminar(req, res) {
    await service.eliminar(Number(req.params.id));
    res.status(204).end();
}
::@@FIN

::@@BASE src/routes/items.routes.js
import { Router } from 'express';
import * as controller from '../controllers/items.controller.js';
import { validarId } from '../middlewares/validar-id.middleware.js';

const router = Router();

router.get('/', controller.listar);
router.get('/buscar', controller.buscar);                // /buscar?q=texto
router.get('/por/:campo/:valor', controller.listarPor);  // /por/estado/publicado
router.get('/:id', validarId, controller.obtener);
router.post('/', controller.crear);
router.put('/:id', validarId, controller.actualizar);
router.delete('/:id', validarId, controller.eliminar);

export default router;
::@@FIN

::@@BASE src/routes/index.js
import { Router } from 'express';
import itemsRoutes from './items.routes.js';
// [rutas:import] (no borrar: aquí inserta "npm run crear:recurso")

const router = Router();
router.use('/items', itemsRoutes);
// [rutas:use] (no borrar)

export default router;
::@@FIN

::@@BASE http/items.http
# Pruebas con la extensión "REST Client" de VS Code
@api = http://localhost:3000/api

### 200 - Listar todo (ordenado)
GET {{api}}/items

### 200 - Buscar por texto (codigo, nombre o descripcion)
GET {{api}}/items/buscar?q=tecl

### 200 - Listar por el valor de una columna: /por/<campo>/<valor>
GET {{api}}/items/por/estado/borrador

### 200 - Listar por una columna booleana
GET {{api}}/items/por/activo/true

### 201 - Crear
# @name nuevo
POST {{api}}/items
Content-Type: application/json

{
    "codigo": "TEC-001",
    "nombre": "Teclado mecánico",
    "descripcion": "Teclado de prueba",
    "cantidad": 10,
    "precio": 149.90,
    "calificacion": 4.5,
    "activo": true,
    "estado": "borrador",
    "email": "contacto@ejemplo.com",
    "fecha_vencimiento": "2030-12-31",
    "hora_apertura": "08:30"
}

### 200 - Obtener el registro creado
GET {{api}}/items/{{nuevo.response.body.id}}

### 200 - Actualizar parcialmente el registro creado
PUT {{api}}/items/{{nuevo.response.body.id}}
Content-Type: application/json

{
    "nombre": "Teclado mecánico RGB",
    "precio": 179.90
}

### 400 - Datos no válidos (devuelve la lista de errores)
POST {{api}}/items
Content-Type: application/json

{
    "codigo": "x",
    "precio": -5,
    "email": "no-es-correo",
    "estado": "otro"
}

### 409 - Código duplicado
POST {{api}}/items
Content-Type: application/json

{
    "codigo": "TEC-001",
    "nombre": "Duplicado",
    "precio": 1
}

### 400 - Id no válido
GET {{api}}/items/abc

### 404 - No existe
GET {{api}}/items/999999

### 204 - Eliminar el registro creado
DELETE {{api}}/items/{{nuevo.response.body.id}}
::@@FIN

::@@BASE db/esquema.sql
-- Alternativa manual a "npm run db:crear": ejecuta este archivo en MySQL / phpMyAdmin.
-- Cambia el nombre de la base si modificaste DB_NAME en .env

CREATE DATABASE IF NOT EXISTS proyecto_inicial
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE proyecto_inicial;

CREATE TABLE IF NOT EXISTS items (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  codigo            VARCHAR(20)   NOT NULL UNIQUE,
  nombre            VARCHAR(100)  NOT NULL,
  descripcion       TEXT          NULL,
  cantidad          INT           NOT NULL DEFAULT 0,
  precio            DECIMAL(10,2) NOT NULL,
  calificacion      FLOAT         NULL,
  activo            TINYINT(1)    NOT NULL DEFAULT 1,
  estado            ENUM('borrador','publicado','archivado') NOT NULL DEFAULT 'borrador',
  email             VARCHAR(120)  NULL,
  fecha_vencimiento DATE          NULL,
  fecha_publicacion DATETIME      NULL,
  hora_apertura     TIME          NULL,
  creado_en         DATETIME      NOT NULL,
  actualizado_en    DATETIME      NOT NULL
  -- , categoria_id INT NOT NULL,
  -- CONSTRAINT fk_items_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
::@@FIN

::@@BASE scripts/crear-bd.js
// Crea la base de datos (si no existe) y las tablas a partir de los modelos.
// Uso:  npm run db:crear
import mysql from 'mysql2/promise';
import { env } from '../src/config/env.js';

try {
    const conexion = await mysql.createConnection({
        host: env.db.host,
        port: env.db.port,
        user: env.root.user,
        password: env.root.password
    });
    await conexion.query(
        `CREATE DATABASE IF NOT EXISTS \`${env.db.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    await conexion.end();
    console.log(`Base de datos lista: ${env.db.database}`);

    const { sequelize } = await import('../src/config/db.js');
    const modelos = await import('../src/models/index.js');
    await sequelize.sync(); // crea solo las tablas que falten; no modifica las existentes
    console.log(`Tablas listas: ${Object.values(modelos).map((m) => m.tableName).join(', ')}`);
    await sequelize.close();
} catch (err) {
    console.error('No se pudo crear la base de datos');
    console.error(`Error: ${err.code ?? err.original?.code ?? '-'}`);
    console.error(`Mensaje: ${err.message}`);
    process.exitCode = 1;
}
::@@FIN

::@@BASE scripts/crear-recurso.js
// Genera un recurso CRUD nuevo copiando el recurso de ejemplo "items".
// Uso:      npm run crear:recurso -- <singular> <plural>
// Ejemplo:  npm run crear:recurso -- producto productos
import { readFile, writeFile, access } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const [singular, plural] = process.argv.slice(2);
const valido = /^[a-z][a-z0-9_]*$/;

if (!singular || !plural || !valido.test(singular) || !valido.test(plural) || singular === plural) {
    console.error('Uso: npm run crear:recurso -- <singular> <plural>   (minúsculas, sin espacios ni tildes)');
    console.error('Ejemplo: npm run crear:recurso -- producto productos');
    process.exit(1);
}

const pascal = (s) => s.split('_').map((p) => p[0].toUpperCase() + p.slice(1)).join('');
const camel = (s) => pascal(s).replace(/^./, (c) => c.toLowerCase());
const Modelo = pascal(singular);
const reemplazos = { items: plural, Item: Modelo, item: singular };
const renombrar = (texto) => texto.replace(/items|Item|item/g, (m) => reemplazos[m]);

const plantillas = [
    'src/models/item.model.js',
    'src/repositories/items.repository.js',
    'src/services/items.service.js',
    'src/controllers/items.controller.js',
    'src/validators/items.validator.js',
    'src/routes/items.routes.js',
    'http/items.http'
];
const existe = (ruta) => access(ruta).then(() => true, () => false);

for (const plantilla of plantillas) {
    const destino = renombrar(plantilla);
    if (!(await existe(path.join(raiz, plantilla)))) {
        console.error(`Falta la plantilla ${plantilla}: este comando necesita el recurso de ejemplo "items".`);
        process.exit(1);
    }
    if (await existe(path.join(raiz, destino))) {
        console.error(`Ya existe ${destino}. No se modificó nada.`);
        process.exit(1);
    }
}

for (const plantilla of plantillas) {
    const destino = renombrar(plantilla);
    await writeFile(path.join(raiz, destino), renombrar(await readFile(path.join(raiz, plantilla), 'utf8')));
    console.log(`  + ${destino}`);
}

// Registra el modelo y la ruta insertando una línea antes de cada marcador
async function insertar(archivo, cambios) {
    const ruta = path.join(raiz, archivo);
    let contenido = await readFile(ruta, 'utf8');
    for (const [marcador, linea] of cambios) {
        const posicion = contenido.split('\n').find((l) => l.includes(marcador));
        if (posicion === undefined) {
            console.warn(`  ! No se encontró el marcador ${marcador} en ${archivo}: agrega a mano ->  ${linea.trim()}`);
            continue;
        }
        contenido = contenido.replace(posicion, `${linea}\n${posicion}`);
    }
    await writeFile(ruta, contenido);
    console.log(`  * ${archivo}`);
}

await insertar('src/models/index.js', [
    ['[modelos:import]', `import { ${Modelo} } from './${singular}.model.js';`],
    ['[modelos:export]', `    ${Modelo},`]
]);
await insertar('src/routes/index.js', [
    ['[rutas:import]', `import ${camel(plural)}Routes from './${plural}.routes.js';`],
    ['[rutas:use]', `router.use('/${plural}', ${camel(plural)}Routes);`]
]);

console.log(`\nRecurso "${plural}" creado. Ahora adapta los campos en:`);
console.log(`  1. src/models/${singular}.model.js        (columnas y tipos)`);
console.log(`  2. src/validators/${plural}.validator.js  (reglas de validación)`);
console.log(`  3. src/repositories/${plural}.repository.js y src/services/${plural}.service.js  (búsqueda, orden, campos de listarPor)`);
console.log('  4. Ejecuta "npm run db:crear" para crear la tabla.');
::@@FIN

::@@ORIGINAL index.js
import { probarConexion, cerrarConexion } from './src/config/db.js';
try {
    const info = await probarConexion();
    console.log('Conexion MYSQL exitosa');
    console.table(info);
} catch (err) {
    console.error('No se pudo conectar');
    console.error(`Error: ${err.code ?? '-'}`);
    console.error(`Mensaje: ${err.message}`);
}
finally{
    await cerrarConexion();
}
::@@FIN

::@@ORIGINAL package.json
{
  "name": "biblioteca-api",
  "version": "1.0.0",
  "description": "",
  "main": "src/server.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "node src/server.js",
    "dev": "node --watch src/server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "module",
  "dependencies": {
    "cors": "^2.8.6",
    "dotenv": "^18.0.9",
    "express": "^5.3.0",
    "morgan": "^1.12.1",
    "mysql2": "^3.24.6",
    "sequelize": "^6.37.8"
  }
}
::@@FIN

::@@ORIGINAL http/autores.http
@api = http://localhost:3000/api

### 200 - Listar (ordenado)
GET {{api}}/autores
### 200 - buscar por nombres o apellidos
GET {{api}}/autores?q=mart

### 200 Obtener un autor
GET {{api}}/autores/1

### 201 - Crear
# @name nuevoAutor
POST {{api}}/autores
Content-Type: : application/json
{
    "nombres":"Kent",
    "apellidos":"Romero",
    "nacionalidad":"Peruano"
}
### 200 - Actualizar parcialmente el autor creado
PUT {{api}}/autores/{{nuevoAutor.response.body.id}}
Content-Type: : application/json
{    
    "nacionalidad":"Norteamericano"
}

### 204 - Eliminar el autor creado
DELETE {{api}}/autores/{{nuevoAutor.response.body.id}}
::@@FIN

::@@ORIGINAL src/app.js
import express from 'express';
import routes from './routes/index.js';
import { rutaNoEncontrada, manejadorErrores } from './middlewares/error.middleware.js';
const app = express();
app.use(express.json());
app.use((req, res, next) => {
    res.on('finish', () => {
        console.log(`${req.method} ${req.originalUrl} ${req.statusCode}`)
        next();
    })
});
app.use('/api', routes);
app.use(rutaNoEncontrada);
app.use(manejadorErrores);
export default app;
::@@FIN

::@@ORIGINAL src/server.js
import  app  from './app.js'
import { env } from './config/env.js';
import { probarConexion } from './config/db.js';
try {
    const info = await probarConexion();
    console.log(`MySql conectado: ${info.bd} como ${info.usuario} `);
} catch(err){
    console.error(`No se pudo conectar a MySql`);
}

app.listen(env.port,()=>{
    console.log(`API biblioteca UNU EN http://localhost:${env.port}/api`)
});
::@@FIN

::@@ORIGINAL src/config/db.js
import { Sequelize, QueryTypes } from 'sequelize';
import { env } from './env.js'

export const sequelize = new Sequelize(
    env.db.database,
    env.db.user,
    env.db.password,
    {
        host: env.db.host,
        port: env.db.port,
        dialect: 'mysql',
        logging: env.db.logging ? (sql) => console.log(`[SQL] ${sql}`) : false,
        pool: { max: env.db.connectionLimit, min: 0, acquire: 30000, idle: 10000 },
        define: {
            freezeTableName: true,
            timestamps: false
        },
        dialectOptions: { decimalNumbers: true }
    }
)

export async function probarConexion() {
    await sequelize.authenticate();
    const [info] = await sequelize.query(' SELECT DATABASE() AS bd,' +
        ' CURRENT_USER() as usuario, VERSION() as version',
        { type: QueryTypes.SELECT });
    return info;
}

export const cerrarConexion = ()=> sequelize.close();
::@@FIN

::@@ORIGINAL src/config/env.js
import 'dotenv/config';

export const env ={
    port: Number(process.env.PORT?? 3000),
    db: {
        host: process.env.DB_HOST?? 'localhost',
        port: Number(process.env.DB_PORT?? 3306),
        user: process.env.DB_USER ?? 'root',
        password: process.env.DB_PASSWORD ?? '',
        database: process.env.DB_NAME ?? 'biblioteca_unu',
        connectionLimit: Number(process.env.DB_CONNECTION_LIMIT ?? 10)
    },
    root: {
        user: process.env.DB_ROOT_USER??'root',
        password: process.env.DB_ROOT_PASSWORD??''
    }
}
::@@FIN

::@@ORIGINAL src/controllers/autores.controller.js
import * as service from '../services/autores.service.js';
export async function listar(req, res) {
    res.json(await service.listar({ q: req.query.q }));
}

export async function obtener(req, res) {
    res.json(await service.obtener(Number(req.params.id)));
}

export async function crear(req, res) {
    const creado = await service.crear(req.body);
    res.status(201).location(`/api/autores/${creado.id}`).json(creado);
}

export async function actualizar(req, res) {
    res.json(await service.actualizar(Number(req.params.id), req.body));
}

export async function eliminar(req, res) {
    await service.eliminar(Number(req.params.id));
    res.status(204).end();
}
::@@FIN

::@@ORIGINAL src/middlewares/error.middleware.js
import { traducirErrorBD } from '../utils/errores-bd.js';

// Ruta inexistente -> 404 en JSON
export function rutaNoEncontrada(req, res) {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
}

// Manejador central: todos los errores terminan aquí.
// Express 5 envía a este middleware los errores de funciones async.
export function manejadorErrores(err, req, res, next) {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'El cuerpo no es un JSON válido' });
  }
  const error = traducirErrorBD(err); // errores de Sequelize y MySQL
  const status = error.status ?? 500;
  if (status >= 500) console.error(err);
  res.status(status).json({
    error: status === 500 ? 'Error interno del servidor' : error.message,
    ...(error.detalles && { detalles: error.detalles })
  });
}
::@@FIN

::@@ORIGINAL src/middlewares/validar-id.middleware.js
// Rechaza ids que no sean enteros positivos antes de llegar al controlador
export function validarId(req, res, next) {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id < 1) {
    return res.status(400).json({ error: 'El id debe ser un entero positivo' });
  }
  next();
}
::@@FIN

::@@ORIGINAL src/models/autor.model.js
import { DataTypes, TableHints } from "sequelize";
import { sequelize } from "../config/db.js";
export const Autor = sequelize.define(
    'Autor',
    {
        id:{
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        nombres:{
            type: DataTypes.STRING(80),
            allowNull: false,            
            validate: {
                notNull: { msg: 'el nombre es obligatorio' },
                notEmpty: { msg: 'el nombre no puede estar vacío' }
            }
        },
        apellidos:{
            type: DataTypes.STRING(80),
            allowNull: false,            
            validate: {
                notNull: { msg: 'el apellido es obligatorio' },
                notEmpty: { msg: 'el apellido no puede estar vacío' }
            }
        },
        nacionalidad: { type: DataTypes.STRING(255), allowNull: true }
    },
    { tableName: 'autores' }

)
::@@FIN

::@@ORIGINAL src/models/categoria.model.js
import { DataTypes } from "sequelize";
import { sequelize } from "../config/db.js";

export const Categoria = sequelize.define(
    'Categoria',
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        nombre: {
            type: DataTypes.STRING(80),
            allowNull: false,
            unique: true,
            validate: {
                notNull: { msg: 'el nombre es obligatorio' },
                notEmpty: { msg: 'el nombre no puede estar vacío' }
            }
        },
        descripcion: { type: DataTypes.STRING(255), allowNull: true }
    },
    {
        tableName: 'categorias'
    }
)
::@@FIN

::@@ORIGINAL src/models/index.js
import { Categoria } from './categoria.model.js';
import { Autor } from './autor.model.js';
import { Libro } from './libro.model.js';

export { Categoria, Autor, Libro };
::@@FIN

::@@ORIGINAL src/models/libro.model.js
import { DataTypes } from "sequelize";
import { sequelize } from "../config/db.js";

export const Libro = sequelize.define(
    'Libro',
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        isbn: {
            type: DataTypes.STRING(17),
            allowNull: false,
            unique: true,
            validate: {
                notNull: { msg: 'el isbn es obligatorio' },
            }
        },
        titulo: {
            type: DataTypes.STRING(200),
            allowNull: false,
            validate: {
                notNull: { msg: 'el título es obligatorio' },
                notEmpty: { msg: 'el título no puede estar vacío' }
            }
        },
        anio: {
            type: DataTypes.SMALLINT,
            allowNull: true,
            validate: {
                min: { args: [1450], msg: 'el año no es válido' },
                max: { args: [new Date().getFullYear()], msg: 'el año no puede ser mayor al actual' }
            }
        },
        categoria_id: {
            type: DataTypes.INTEGER, allowNull: false
        },
        stock_total: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 1,
            validate: {
                min: { args: [0], msg: 'stock_total no puede ser negativo' }
            }
        },
        stock_disponible: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 1,
            validate: {
                min: { args: [0], msg: 'stock_disponible no puede ser negativo' }
            }
        }
    },
    {
        tableName: 'libros',
        validate: {
            stockValido() {
                if(this.stock_disponible > this.stock_total){
                    throw new Error('El stock disponible no puede ser mayor que el stock total');
                }
            }
        }
    }
)
::@@FIN

::@@ORIGINAL src/repositories/autores.repository.js
import { Op } from 'sequelize';
import { Autor } from '../models/index.js';
import { plano } from '../utils/plano.js';

export async function listar({ q } = {}) {
    const where = q ? {
        [Op.or]: [
            { nombres: { [Op.like]: `%${q}%` } },
            { apellidos: { [Op.like]: `%${q}%` } },
        ]
    } : {};
    return (await Autor.findAll({ where, order: [['apellidos', 'ASC']] })).map(plano)
}

export async function buscarPorId(id) {
    return plano(await Autor.findByPk(id));
}

export async function crear(datos) {
    return plano(await Autor.create(datos));
}

export async function actualizar(id, datos) {
    const autor = await Autor.findByPk(id);
    if (!autor) return null;
    return plano(await autor.update(datos));
}

export async function eliminar(id) {
    return (await Autor.destroy({ where: { id } })) > 0;
}
::@@FIN

::@@ORIGINAL src/routes/autores.routes.js
import {Router} from 'express';
import * as controller from '../controllers/autores.controller.js';
import {validarId} from '../middlewares/validar-id.middleware.js'
const router = Router();

router.get('/', controller.listar);
router.get('/:id',validarId, controller.obtener);
router.post('/', controller.crear);
router.put('/:id',validarId, controller.actualizar);
router.delete('/:id',validarId, controller.eliminar);

export default router;
::@@FIN

::@@ORIGINAL src/routes/index.js
import {Router} from 'express';
import autoresRoutes from './autores.routes.js';

const router = Router();
router.use('/autores', autoresRoutes);

export default router;
::@@FIN

::@@ORIGINAL src/services/autores.service.js
import * as repo from '../repositories/autores.repository.js';
import { noEncontrado, solicitudInvalida } from '../utils/http-error.js';
const CAMPOS = ['nombres', 'apellidos', 'nacionalidad'];
const soloCampos = (d) => Object.fromEntries(Object.entries(d).filter(([k]) => CAMPOS.includes(k)));

function validar(d, parcial = false) {
    const errores = [];
    if ((!parcial || d.nombres !== undefined) && !d.nombres?.trim())
        errores.push("el campo nombres es obligatorio ");
    if ((!parcial || d.apellidos !== undefined) && !d.apellidos?.trim())
        errores.push("el campo apellidos es obligatorio ");
}

export const listar = (filtro) => repo.listar(filtro);


export async function obtener(id) {
    const autor = await repo.buscarPorId(id);
    if (!autor) throw noEncontrado('Autor');
    return autor;
}

export async function crear(body) {
    validar(body);
    return repo.crear(soloCampos(body));
}

export async function actualizar(id, body) {
    await obtener(id);
    validar(body, true);
    return repo.actualizar(id, soloCampos(body));
}

export async function eliminar(id){
    await obtener(id);
    await repo.eliminar(id);
}
::@@FIN

::@@ORIGINAL src/utils/errores-bd.js
// Traduce los errores de Sequelize y MySQL a errores HTTP comprensibles.
import {
  UniqueConstraintError,
  ForeignKeyConstraintError,
  ValidationError,
  DatabaseError,
  ConnectionError
} from 'sequelize';
import { HttpError } from './http-error.js';

const nombreRestriccion = (msg = '') => msg.match(/constraint\s+[`'"](\w+)[`'"]/i)?.[1];

export function traducirErrorBD(err) {
  // UNIQUE (isbn, nombre de categoría) -> 409
  // Va antes que ValidationError porque UniqueConstraintError hereda de él.
  if (err instanceof UniqueConstraintError) {
    const campos = Object.keys(err.fields ?? {}).join(', ');
    return new HttpError(409, `Ya existe un registro con ese valor${campos ? ` (${campos})` : ''}`);
  }

  // FOREIGN KEY: 1451 al borrar un padre con hijos, 1452 al referenciar algo inexistente
  if (err instanceof ForeignKeyConstraintError) {
    const fk = nombreRestriccion(err.original?.sqlMessage);
    return err.original?.errno === 1451
      ? new HttpError(409, 'No se puede eliminar: existen registros relacionados', fk && [fk])
      : new HttpError(400, 'La referencia indicada no existe', fk && [fk]);
  }

  // Validadores del modelo (notEmpty, is, min, stockValido...) -> 400
  if (err instanceof ValidationError) {
    return new HttpError(400, 'Datos no válidos', err.errors.map((e) => e.message));
  }

  // Servidor apagado, credenciales incorrectas, base inexistente -> 503
  if (err instanceof ConnectionError) {
    return new HttpError(503, 'La base de datos no está disponible');
  }

  // CHECK: 3819 en MySQL 8, 4025 en MariaDB (XAMPP) -> 400
  if (err instanceof DatabaseError && [3819, 4025].includes(err.original?.errno)) {
    const ck = nombreRestriccion(err.original.sqlMessage) ?? err.original.sqlMessage;
    return new HttpError(400, 'Se violó una regla de la base de datos', [ck]);
  }

  return err;
}
::@@FIN

::@@ORIGINAL src/utils/http-error.js
// Error con código HTTP: lo lanzan los servicios y lo responde el manejador central
export class HttpError extends Error {
  constructor(status, message, detalles) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
    if (detalles) this.detalles = detalles;
  }
}

export const solicitudInvalida = (mensaje, detalles) => new HttpError(400, mensaje, detalles);
export const noEncontrado = (recurso) => new HttpError(404, `${recurso} no existe`);
export const conflicto = (mensaje) => new HttpError(409, mensaje);
::@@FIN

::@@ORIGINAL src/utils/plano.js
export const plano = (fila) => (fila ? fila.get({ plain: true }) : null);
::@@FIN
