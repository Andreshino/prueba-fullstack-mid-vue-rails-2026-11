# Prueba Fullstack MID — Ruby on Rails + Vue — 2026-11

Proyecto base para la **prueba Fullstack MID de Ruby on Rails + Vue (2026-11)**.

Este repositorio entrega a los candidatos un entorno funcional con Rails, PostgreSQL, Vue y Tailwind. Incluye un flujo completo de ejemplo —modelo, servicio, API y vista— que sirve como punto de partida y como referencia de la arquitectura esperada.

---

## 1. Stack

| Componente | Versión |
|---|---|
| Ruby | 3.0.7 |
| Rails | 7.0.2.4 |
| Bundler | 2.5.23 |
| PostgreSQL | 14 |
| Vue | 3.4.31 (build global, sin Node) |
| Tailwind CSS | 3.4.17 (`tailwindcss-rails` 3.3.2) |
| Slim | `slim-rails` 3.6.3 |
| Asset pipeline | Sprockets Rails 3.5.1 |
| Servidor | Puma 5.6.8 |

Las versiones de Ruby, Rails, Puma, PostgreSQL, Slim y Tailwind corresponden al proyecto de referencia de la compañía.

---

## 2. Requisitos

- **Docker Desktop** en macOS y Windows, o **Docker Engine + Compose v2** en Linux.
- **Docker Compose v2**: el comando es `docker compose`, no el antiguo `docker-compose`.
- Contenedores **Linux**. En Windows se requiere Docker Desktop con backend **WSL2**.
- Puertos libres:
  - `3000` → aplicación Rails.
  - `5433` → PostgreSQL desde el host (el contenedor usa internamente el `5432`).
- Conexión a internet la primera vez: Docker Hub, RubyGems y el archivo histórico de Debian.

No se requiere instalar Ruby, Rails, PostgreSQL, Node ni Yarn en el host.

Compatible con macOS Intel/ARM, Linux x86_64/ARM64 y Windows 10/11 con WSL2.

Verificación rápida del entorno:

```bash
docker --version
docker compose version
docker info
```

---

## 3. Cómo ejecutar el proyecto

Desde la carpeta del proyecto:

```bash
# Construir la imagen (la primera vez tarda unos minutos)
docker compose build

# Levantar la aplicación y PostgreSQL
docker compose up
```

Cuando aparezca en los logs:

```text
* Listening on http://0.0.0.0:3000
```

abre:

- **Vista de empleados:** <http://localhost:3000/sy/employees>
- **API:** <http://localhost:3000/api/v1/employees>

La raíz <http://localhost:3000/> redirige a `/sy/employees`.

### En segundo plano

```bash
docker compose up -d
docker compose logs -f web
```

Para salir de los logs sin detener los contenedores: `Ctrl + C`.

### Primera vez en una sola línea

```bash
docker compose up --build
```

El primer arranque puede tardar un par de minutos mientras Rails genera `tmp/development_secret.txt`, prepara la base y compila Tailwind.

---

## 4. Qué hace el arranque automáticamente

El servicio `web` ejecuta este flujo antes de iniciar Puma (definido en `docker-compose.yml`):

1. Espera a que PostgreSQL responda (`pg_isready`).
2. Ejecuta `rails db:prepare`:
   - crea la base si no existe,
   - aplica migraciones pendientes.
3. Ejecuta `rails db:seed` (idempotente, no duplica empleados).
4. Compila Tailwind (`rails tailwindcss:build`).
5. Elimina un `tmp/pids/server.pid` viejo si existe.
6. Levanta Rails con `rails server -b 0.0.0.0 -p 3000`.

Los datos de PostgreSQL se conservan en el volumen `postgres_data` al ejecutar `docker compose down`.

En desarrollo no se usan credenciales cifradas: Rails genera automáticamente `tmp/development_secret.txt` para el `secret_key_base`. **No necesitas crear `config/master.key` ni un archivo `.env`.**

---

## 5. Arquitectura

Flujo de la vista:

```text
GET /sy/employees
  └─ Sy::EmployeesController#index
       └─ render "sy/modules/employees/index", layout: "application_vue"
            ├─ El layout Slim carga vue.js y tailwind.css
            ├─ La vista define <div id="app"> y la app Vue inline
            └─ Vue hace fetch("/api/v1/employees")
                 └─ Api::V1::EmployeesController#index
                      └─ EmployeeService#list
                           └─ Employee.order(:name)
                 └─ JSON { employees: [...] }
            └─ Vue pinta la tabla
```

Características de la base:

- Vue se carga como **build global** desde `app/assets/builds/vue.js` con `javascript_include_tag`. No hay Vite, Webpack ni Node.
- La vista es **ERB** con la plantilla Vue inline y un `<script>` que ejecuta `createApp(...).mount("#app")`.
- El layout es **Slim** (`application_vue.html.slim`).
- Tailwind se compila con `tailwindcss-rails` y el resultado queda en `app/assets/builds/tailwind.css`.
- El controlador web solo renderiza; la lógica de listado vive en un servicio.

---

## 6. Estructura del proyecto

```text
test_ruby_vue/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitattributes
├── Gemfile
├── Gemfile.lock
├── README.md
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── api/
│   │   │   └── v1/
│   │   │       └── employees_controller.rb   # GET /api/v1/employees
│   │   └── sy/
│   │       └── employees_controller.rb       # Vista /sy/employees
│   ├── models/
│   │   └── employee.rb
│   ├── services/
│   │   └── employee_service.rb               # EmployeeService#list
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application_vue.html.slim
│   │   └── sy/
│   │       └── modules/
│   │           └── employees/
│   │               └── index.html.erb        # Tabla Vue + Tailwind
│   └── assets/
│       ├── builds/
│       │   ├── vue.js
│       │   └── tailwind.css
│       ├── config/
│       │   └── manifest.js
│       └── stylesheets/
│           ├── application.css
│           └── application.tailwind.css
├── config/
│   ├── routes.rb
│   ├── database.yml
│   ├── tailwind.config.js
│   └── initializers/
│       └── assets.rb
└── db/
    ├── migrate/
    │   └── 20261123130000_create_employees.rb
    ├── schema.rb
    └── seeds.rb
```

---

## 7. Modelo `Employee`

Tabla `employees`:

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | bigint | PK |
| `name` | string | Nombre |
| `document` | string | Documento |
| `phone_number` | string | Número de teléfono |
| `position` | string | Cargo |
| `address` | string | Dirección |
| `city` | string | Ciudad |
| `created_at` | datetime | — |
| `updated_at` | datetime | — |

Todos los campos de negocio tienen validación de presencia.

Los seeds cargan 5 empleados de ejemplo y son idempotentes (`find_or_create_by!` por `document`).

---

## 8. API

### Listar empleados

```http
GET /api/v1/employees
```

Sin autenticación. Respuesta `200 OK`:

```json
{
  "employees": [
    {
      "id": 1,
      "name": "Ana María Gómez",
      "document": "1020304050",
      "phone_number": "3001234567",
      "position": "Auxiliar contable",
      "address": "Calle 10 # 20-30",
      "city": "Bogotá"
    }
  ]
}
```

Prueba rápida:

```bash
curl http://localhost:3000/api/v1/employees
```

En caso de error inesperado responde `422`:

```json
{ "error": "mensaje" }
```

### Rutas disponibles

| Método | Ruta | Controlador#Acción |
|---|---|---|
| `GET` | `/` | Redirige a `/sy/employees` |
| `GET` | `/sy/employees` | `sy/employees#index` |
| `GET` | `/api/v1/employees` | `api/v1/employees#index` |

---

## 9. Base de datos

- Motor: PostgreSQL 14.
- Base: `test_ruby_vue_development`.
- Usuario: `dev_user`.
- Contraseña: `dev_password`.
- Desde el contenedor `web`: `postgres:5432`.
- Desde el host: `localhost:5433`.

La conexión se define en `docker-compose.yml`:

```yaml
DATABASE_URL: postgres://dev_user:dev_password@postgres:5432/test_ruby_vue_development
```

### Entrar a PostgreSQL

Desde el contenedor:

```bash
docker compose exec postgres psql -U dev_user -d test_ruby_vue_development
```

Desde el host, si tienes `psql` instalado:

```bash
psql -h localhost -p 5433 -U dev_user -d test_ruby_vue_development
```

Consultas útiles:

```sql
SELECT * FROM employees;
SELECT COUNT(*) FROM employees;
```

---

## 10. Comandos útiles

Todos los comandos de Rails se ejecutan dentro del contenedor `web`:

```bash
# Consola de Rails
docker compose exec web bin/rails console

# Ver rutas
docker compose exec web bin/rails routes

# Migraciones
docker compose exec web bin/rails db:migrate

# Estado de migraciones
docker compose exec web bin/rails db:migrate:status

# Cargar seeds (idempotente)
docker compose exec web bin/rails db:seed

# Compilar Tailwind una vez
docker compose exec web bin/rails tailwindcss:build

# Tailwind en modo watch
docker compose exec web bin/rails tailwindcss:watch

# Shell dentro del contenedor
docker compose exec web bash

# Logs del servidor
docker compose logs -f web

# Estado de los servicios
docker compose ps
```

Comandos de Docker Compose:

```bash
docker compose build            # construir / reconstruir la imagen
docker compose up               # levantar en primer plano
docker compose up -d            # levantar en segundo plano
docker compose restart web      # reiniciar solo Rails
docker compose down             # detener (los datos se conservan)
docker compose down -v          # detener y borrar la base de datos
```

---

## 11. Desarrollo

### Cambios en Ruby, ERB, Slim o rutas

El proyecto se monta como volumen (`.:/app`), así que los cambios se reflejan en el contenedor. Rails en `development` recarga el código automáticamente; normalmente no hace falta reiniciar.

Si cambias inicializadores, `Gemfile` o configuración de arranque:

```bash
docker compose restart web
```

### Cambios de clases Tailwind

Tailwind solo genera las clases que encuentra al compilar. Si agregas clases nuevas:

```bash
docker compose exec web bin/rails tailwindcss:build
```

O deja el watcher corriendo:

```bash
docker compose exec web bin/rails tailwindcss:watch
```

### Cambios en el `Gemfile`

```bash
docker compose build
docker compose up -d
```

### Crear una migración nueva

```bash
docker compose exec web bin/rails generate migration AddCampoToEmployees campo:string
docker compose exec web bin/rails db:migrate
```

Los archivos generados quedan en la carpeta local gracias al volumen.

---

## 12. Detener, reiniciar y resetear

```bash
# Detener sin borrar datos
docker compose down

# Volver a levantar conservando datos
docker compose up -d

# Reset total: borra contenedores, red y volumen de PostgreSQL
docker compose down -v
docker compose up
```

Al hacer reset total, el arranque vuelve a crear la base, ejecutar migraciones y cargar los 5 empleados de ejemplo.

---

## 13. Verificación rápida

Con los contenedores levantados:

```bash
# 1. La API responde 200 con 5 empleados
curl -s http://localhost:3000/api/v1/employees

# 2. La vista responde 200
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/sy/employees

# 3. Hay 5 registros en la base
docker compose exec web bin/rails runner 'puts Employee.count'
```

Resultado esperado: JSON con 5 empleados, `200` y `5`.

En Windows PowerShell usa `curl.exe` (o `Invoke-RestMethod`), porque `curl` es un alias de `Invoke-WebRequest`.

---

## 14. Notas de entorno

### Windows

- Usa Docker Desktop con backend **WSL2** y contenedores Linux.
- Ejecuta los comandos desde PowerShell o desde una terminal WSL2.
- Si ves errores de `bad interpreter` o `^M` en `bin/rails`, el archivo se descargó con CRLF. Vuelve a clonar (el `.gitattributes` fuerza LF) o ejecuta `dos2unix bin/* Dockerfile`.
- Para mejor rendimiento, mantén el proyecto dentro del filesystem de WSL2, no en `C:\`.

### Linux con SELinux (Fedora, RHEL, CentOS)

Si el contenedor no puede leer `/app`, levanta con la opción `:z`:

```bash
MOUNT_OPTIONS=:z docker compose up
```

En distribuciones sin SELinux no se necesita.

### Puertos ocupados

Si `3000` está ocupado, cambia el mapeo en `docker-compose.yml`:

```yaml
ports:
  - "3001:3000"
```

Si `5433` está ocupado, cambia solo el puerto del host:

```yaml
ports:
  - "5434:5432"
```

El contenedor `web` sigue usando `postgres:5432` internamente.

### Docker Compose v1

El proyecto requiere **Docker Compose v2** (`docker compose`). Actualiza Docker Desktop o instala el plugin `docker-compose-plugin`.

---

## 15. Alcance de esta base

Incluido:

- Modelo `Employee` con los 6 campos solicitados.
- Servicio de listado.
- Endpoint `GET /api/v1/employees`.
- Controlador web y vista Vue + Tailwind con tabla.
- Seeds de ejemplo.
- Docker Compose con Rails + PostgreSQL.

Intencionalmente **no incluido** en la base:

- Autenticación / autorización.
- Engines.
- Vuetify.
- Node, Yarn, Vite o Webpack.
- Tests automatizados.
- Configuración de producción.
- Credenciales cifradas / `master.key` (en desarrollo Rails genera `tmp/development_secret.txt` y no se versiona).

La prueba se desarrolla sobre esta base respetando la arquitectura y el alcance anteriores.

