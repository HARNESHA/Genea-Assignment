# Full-Stack FastAPI + React (Vite) Template

This repository contains a **full-stack web application template** built with:

* **Backend**: FastAPI (Python), SQLAlchemy/SQLModel, Alembic migrations
* **Frontend**: React + TypeScript (Vite)
* **Containerization**: Docker & Docker Compose
* **Reverse Proxy**: Nginx (frontend)

The setup is designed to be **developer-friendly**, **production-ready**, and easy to run locally using Docker.

---

## 📁 Project Structure

```text
application/
├── backend
│   ├── Dockerfile              # Backend Docker image definition
│   ├── README.md               # Backend-specific documentation
│   ├── alembic.ini             # Alembic migration configuration
│   ├── app/                    # FastAPI application source code
│   ├── example.env             # Example environment variables for backend
│   ├── poetry.lock             # Locked Python dependencies
│   ├── prestart.sh             # Pre-start script (migrations, checks, etc.)
│   └── pyproject.toml          # Python project & dependency configuration
│
├── frontend
│   ├── Dockerfile              # Frontend Docker image definition
│   ├── README.md               # Frontend-specific documentation
│   ├── biome.json              # Linting/formatting configuration
│   ├── example.env             # Example environment variables for frontend
│   ├── index.html              # HTML entry point
│   ├── modify-openapi-operationids.js # OpenAPI helper script
│   ├── nginx.conf              # Nginx configuration for serving frontend
│   ├── package.json            # Node.js dependencies
│   ├── package-lock.json       # Locked Node.js dependencies
│   ├── public/                 # Static assets
│   ├── src/                    # React source code
│   ├── tsconfig.json           # TypeScript configuration
│   ├── tsconfig.node.json      # Node-specific TS config
│   └── vite.config.ts          # Vite build configuration
│
└── docker-compose.yml          # Orchestrates backend & frontend services
```

---

## ⚙️ Prerequisites

Make sure the following are installed on your local machine:

* **Docker** (v20+)
* **Docker Compose** (v2+)
* **Git**

> No need to install Python or Node.js locally if you are using Docker.

---

## 🔐 Environment Configuration (IMPORTANT)

This project uses **separate environment files** for backend and frontend.

### 1️⃣ Backend Environment Variables

```bash
cd backend
cp example.env .env
```

Edit `backend/.env` and configure values such as:

```env
DATABASE_URL=postgresql://user:password@db:5432/appdb
SECRET_KEY=your-secret-key
ENV=local
```

---

### 2️⃣ Frontend Environment Variables

```bash
cd frontend
cp example.env .env
```

Edit `frontend/.env` and configure:

```env
VITE_API_BASE_URL=http://localhost:8000
```

⚠️ **Both `.env` files must be updated before running the application.**

---

## ▶️ Running the Application Locally

From the **root directory** (`application/`):

```bash
docker-compose up --build
```

This will:

* Build backend and frontend Docker images
* Start all required services
* Apply backend startup scripts (migrations, checks)

---

## 🌐 Access the Application

| Service            | URL                                                        |
| ------------------ | ---------------------------------------------------------- |
| Frontend           | [http://localhost:3000](http://localhost:3000)             |
| Backend API        | [http://localhost:8000](http://localhost:8000)             |
| API Docs (Swagger) | [http://localhost:8000/docs](http://localhost:8000/docs)   |
| API Docs (ReDoc)   | [http://localhost:8000/redoc](http://localhost:8000/redoc) |

---

## 🔄 Stopping the Application

```bash
docker-compose down
```

To remove volumes as well:

```bash
docker-compose down -v
```
