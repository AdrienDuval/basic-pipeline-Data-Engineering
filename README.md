## Data Engineering Pipeline (Airflow + Postgres + dbt)

This repository contains a beginner-friendly end-to-end data engineering stack:

- Airflow 2.9 (webserver + scheduler) connected to a Postgres metadata DB
- Source and Destination Postgres databases (for ETL/ELT demos)
- A dbt (Postgres) project with example models
- Docker Compose to orchestrate local services

Everything runs locally via Docker on Windows using PowerShell.

---

### Table of contents

- Overview
- Architecture
- Repository structure
- Prerequisites
- Quick start
- Detailed setup
- Airflow usage
- dbt usage
- Docker Compose services reference
- Security and secrets
- Troubleshooting
- Common tasks

---

### Overview

The goal is to provide a repeatable local environment for learning and practicing data engineering concepts: orchestrating jobs in Airflow, transforming data with dbt, and moving data between Postgres instances.

---

### Architecture

High-level components and data flow:

- Source Postgres → staging/ELT → Destination Postgres
- Airflow orchestrates tasks (e.g., load → transform → validate)
- dbt builds models in Postgres (transform layer)

---

### Repository structure

```
Data_engineering/
  .gitignore
  README.md
  logs/
  etl/
    Dockerfile
    script.py
  Pipeline/
    docker-compose.yaml
    Dockerfile
    airflow/
      aiflow.cfg
      dags/
        etl_dag.py
    dbt/
      profiles.yml              # Real credentials (ignored by Git)
      profiles.example.yml      # Template for local setup
    dbt_postgres_dev/           # dbt project
      dbt_project.yml
      models/
        example/
          actors.sql
          film_actors.sql
          film_ratings.sql
          films.sql
          schema.yml
      macros/
        film_ratings_macro.sql
      target/                   # dbt artifacts (ignored by Git)
    source_db_init/
      init.sql                  # Initializes source Postgres
```

---

### Prerequisites

- Windows 10/11 with PowerShell
- Docker Desktop installed and running
- Git installed

Optional:

- Python and a virtual environment (only if you want to run dbt/clients outside containers)

---

### Quick start

1. Clone or open the folder, then start services:

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline"
docker compose up -d --build
```

2. Access Airflow UI:

```text
http://localhost:8080
```

Default credentials (dev only): username `airflow`, password `password`.

3. Stop services when done:

```powershell
docker compose down
```

---

### Detailed setup

1. Create your local dbt profile from the template:

```powershell
Copy-Item "Pipeline/dbt/profiles.example.yml" "Pipeline/dbt/profiles.yml"
```

Then adjust values in `Pipeline/dbt/profiles.yml` if needed.

2. Start the stack:

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline"
docker compose up -d --build
```

3. Verify containers are healthy:

```powershell
docker compose ps
```

---

### Airflow usage

- Web UI: `http://localhost:8080`
- DAGs location: `Pipeline/airflow/dags`
- To develop DAGs: edit files in `dags/` and the scheduler will pick up changes (containers mount the folder).

Example: add tasks to `etl_dag.py` to orchestrate Postgres to Postgres copy, then transformations.

---

### dbt usage

- Project location: `Pipeline/dbt_postgres_dev`
- Profiles location (inside repo for convenience): `Pipeline/dbt/profiles.yml` (ignored by Git). An example is provided at `Pipeline/dbt/profiles.example.yml`.

Run dbt inside the Airflow container or locally:

Option A: Run dbt locally (requires dbt installed locally):

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline\dbt_postgres_dev"
dbt deps
dbt debug --profiles-dir ..\dbt
dbt run   --profiles-dir ..\dbt --full-refresh
dbt test  --profiles-dir ..\dbt
```

Option B: Add a dbt container to Docker Compose by uncommenting the block below in `Pipeline/docker-compose.yaml` (or copy it):

```yaml
# dbt:
#   image: ghcr.io/dbt-labs/dbt-postgres:1.9.0
#   command:
#     [
#       "run",
#       "--profiles-dir",
#       "/root",
#       "--project-dir",
#       "/dbt",
#       "--full-refresh"
#     ]
#   networks:
#     - etl_network
#   volumes:
#     - ./dbt_postgres_dev:/dbt
#     - ~/.dbt:/root
#   depends_on:
#     - etl_script
#   environment:
#     DBT_PROFILE: default
#     DBT_TARGET: dev
#   restart: "on-failure"
```

Notes:

- The above block is commented out by default. Uncomment to run dbt as a service.
- You can adjust the command to `debug`, `test`, or `build` depending on your workflow.
- When using a dedicated dbt container, consider storing dbt profiles in a mounted volume or use env vars/secrets (see Security section).

---

### Docker Compose services reference

Defined in `Pipeline/docker-compose.yaml`:

- source_postgres: Example source DB (port 5432 on host). Initializes with `source_db_init/init.sql`.
- destination_postgres: Example destination DB (port 5433 on host).
- postgres: Postgres service used by Airflow as its metadata DB.
- init-airflow: One-off container to initialize Airflow DB and create an admin user.
- webserver: Airflow webserver (exposes 8080).
- scheduler: Airflow scheduler.
- dbt (commented): Optional dbt runner service (see dbt usage section).

---

### Security and secrets

This repository is for local learning. Values like passwords and fernet keys are development-only.

Already ignored by Git:

- `Pipeline/dbt/profiles.yml`
- `logs/`, dbt `target/`, `dbt_packages/`
- Virtual environments: `env/`, `venv/`, `.venv/`
- `.env` files

Recommendations:

- Never commit real credentials. Keep them in `profiles.yml` (ignored) or environment variables.
- For production-like setups, use Docker secrets or a vault.

---

### Generate a new Airflow Fernet key

You need a Fernet key for Airflow to encrypt connections and variables.

- Using Docker (no local Python needed):

```powershell
docker run --rm python:3 python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

- Using local Python:

```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

Then place the generated value in `Pipeline/.env`:

```env
AIRFLOW__CORE__FERNET_KEY=your_generated_key_here
```

Restart Airflow to apply:

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline"
docker compose restart webserver scheduler
```

If you are rotating from an old key, temporarily set both keys as a comma-separated list (new first), run `airflow rotate-fernet-key` inside the webserver, then keep only the new key. See remediation steps in this README.

---

### Troubleshooting

- Airflow webserver not reachable on 8080:

  - Ensure Docker Desktop is running
  - `docker compose ps` and check `webserver` is healthy
  - Check port conflicts on your machine

- dbt cannot connect to Postgres:

  - Verify `Pipeline/dbt/profiles.yml` values
  - Ensure containers are up and ports open
  - `dbt debug --profiles-dir Pipeline/dbt`

- Windows path and OneDrive tips:
  - Avoid long paths in scripts, prefer relative paths inside `Pipeline/`
  - If OneDrive locks files, pause sync during heavy dev, or move the repository outside OneDrive

---

### Common tasks

- Start services:

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline"
docker compose up -d --build
```

- Stop and clean up:

```powershell
docker compose down -v
```

- View logs of a service:

```powershell
docker compose logs -f webserver
```

- Run dbt locally:

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering\Pipeline\dbt_postgres_dev"
dbt run --profiles-dir ..\dbt --full-refresh
```

---

### Versioning and Git (quick reference)

```powershell
cd "D:\Users\91798\OneDrive\Desktop\Docs\Data-engineering project\Data_engineering"
git init
git add .
git commit -m "Initial commit: Airflow + Postgres + dbt"
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

---

Happy building! If you want, you can enable the dbt service and wire it into Airflow DAGs to run models as part of your pipeline.
