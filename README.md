# MedResearchVault (MRV)

**Medical Research Data Management & Analytics System**

> Academic Research Data Management System — Not for Clinical Diagnosis.

MedResearchVault is an academic DBMS-focused full-stack project with a PostgreSQL-centered architecture. It includes a Flask API backend, React + Vite frontend, deterministic fictional seed data, and SQL artifacts for schema, analytics views, functions, procedures, triggers, and queries.

## Tech Stack

- **Frontend:** React, Vite, Tailwind CSS, React Router, Axios, Recharts, Lucide React
- **Backend:** Flask, Flask-SQLAlchemy, Flask-JWT-Extended, Flask-CORS, psycopg2-binary, python-dotenv, Werkzeug hashing
- **Database:** PostgreSQL
- **Containers:** Docker + Docker Compose

## Repository Structure

- `/frontend` – React web application
- `/backend` – Flask REST API
- `/database` – SQL schema/seed/views/functions/procedures/triggers/indexes/queries
- `/docs` – ER diagram, relational schema, normalization, DBMS features

## Local Setup

### 1) Environment

Copy and edit environment variables:

```bash
cp .env.example .env
```

### 2) Database Initialization

Create PostgreSQL DB (default name: `medresearchvault`) and run:

```bash
psql -U mrv_user -d medresearchvault -f database/schema.sql
psql -U mrv_user -d medresearchvault -f database/indexes.sql
psql -U mrv_user -d medresearchvault -f database/views.sql
psql -U mrv_user -d medresearchvault -f database/functions.sql
psql -U mrv_user -d medresearchvault -f database/procedures.sql
psql -U mrv_user -d medresearchvault -f database/triggers.sql
psql -U mrv_user -d medresearchvault -f database/seed.sql
```

### 3) Run Backend

```bash
cd backend
pip install -r requirements.txt
python run.py
```

Backend runs on `http://localhost:5000`.

### 4) Run Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on `http://localhost:5173`.

## Docker Setup

```bash
docker compose up --build
```

This starts PostgreSQL, backend, and frontend.

## Authentication & Seed Credentials

- Username: `admin`
- Password: `MRV@1234`

Seed data is fictional and deterministic (no real patient data).

## API Summary

- `POST /api/auth/login`
- `GET /api/dashboard` (protected)
- CRUD/list/detail:
  - `/api/studies`
  - `/api/researchers`
  - `/api/participants`
  - `/api/diseases`
  - `/api/samples`
  - `/api/experiments`
  - `/api/biomarkers`
  - `/api/results`
  - `/api/publications`
- Analytics:
  - `/api/analytics/dashboard`
  - `/api/analytics/studies-by-status`
  - `/api/analytics/participants-by-disease`
  - `/api/analytics/experiments-by-type`
  - `/api/analytics/top-biomarkers`
- `GET /api/audit-logs`
- `GET /api/search?q=<text>`
- `GET /api/reports/export/<resource>.csv`
- Safe DBMS operations:
  - `GET /api/dbms/operations`
  - `GET /api/dbms/operations/<operation_name>`

## Demo Workflow

1. Login with admin credentials.
2. Open dashboard for KPI and chart summaries from live DB data.
3. Navigate research/lab/publication modules for table-driven records.
4. Use DBMS Operations for predefined analytical views.
5. Use CSV export endpoints for reporting.

## Testing / Validation Commands

Backend smoke test:

```bash
cd backend
pytest -q
```

Frontend production build check:

```bash
cd frontend
npm run build
```

## Viva Guidance

- Explain 3NF normalization and bridge tables.
- Walk through role-based access control and JWT flow.
- Demonstrate stored functions/procedures/triggers and audit logging.
- Show that all important entities persist in PostgreSQL.
- Execute sample analytical SQL queries from `database/queries.sql`.
