# 🍽️ Saffron & Sage — Restaurant Reservation System

A full-stack restaurant reservation system built with Flask and PostgreSQL, containerized with Docker Compose and deployed on AWS.

---

## 🏗️ Architecture

### Local Development
```
┌─────────────────────────────────────────┐
│           Docker Compose                │
│                                         │
│  ┌─────────────────┐                   │
│  │   Flask App      │                   │
│  │   python:3.11    │◄── Browser        │
│  │   port 5001      │                   │
│  └────────┬─────────┘                   │
│           │ SQL queries                 │
│           │ DB_HOST=db                  │
│  ┌────────▼─────────┐                   │
│  │   PostgreSQL      │                   │
│  │   postgres:15     │                   │
│  │   port 5432       │                   │
│  └────────┬─────────┘                   │
│           │                             │
│  ┌────────▼─────────┐                   │
│  │   pgdata volume   │                   │
│  │   (persistent)    │                   │
│  └──────────────────┘                   │
└─────────────────────────────────────────┘
```

### Production (AWS)
```
                    ┌──────────────────────────────────────────┐
                    │                AWS Cloud                  │
                    │                                           │
User                │  ┌──────────────────────────────────┐   │
 │                  │  │   AWS ALB                         │   │
 │──── HTTPS ──────►│  │   port 443 (SSL Termination)      │   │
                    │  │   port 80  (redirect to HTTPS)    │   │
                    │  │   Health Check: /health            │   │
                    │  └───────────────┬──────────────────┘   │
                    │                  │ HTTP                   │
                    │  ┌───────────────▼──────────────────┐   │
                    │  │   AWS EC2                         │   │
                    │  │   ┌───────────────────────────┐  │   │
                    │  │   │     Docker Compose         │  │   │
                    │  │   │   ┌─────────────────────┐  │  │   │
                    │  │   │   │    Flask App         │  │  │   │
                    │  │   │   │    port 5000         │  │  │   │
                    │  │   │   └──────────┬───────────┘  │  │   │
                    │  │   └─────────────┼───────────────┘  │   │
                    │  └────────────────┼──────────────────┘   │
                    │                   │ DB_HOST=RDS endpoint  │
                    │  ┌────────────────▼─────────────────┐   │
                    │  │   AWS RDS (PostgreSQL)             │   │
                    │  │   port 5432                        │   │
                    │  │   Multi-AZ, automated backups      │   │
                    │  └───────────────────────────────────┘   │
                    └──────────────────────────────────────────┘
```

### CI/CD Pipeline
```
Developer
    │
    │  git push
    ▼
GitHub (main branch)
    │
    │  triggers automatically
    ▼
GitHub Actions
    │
    ├── Build Docker image
    ├── Push to Docker Hub
    └── Deploy to EC2
            │
            ▼
        Live on AWS! 🎉
```

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Python Flask | Web framework |
| PostgreSQL | Database |
| Docker | Containerization |
| Docker Compose | Multi-container orchestration |
| AWS EC2 | Cloud hosting |
| AWS RDS | Managed database |
| AWS ALB | Load balancer + HTTPS |
| GitHub Actions | CI/CD pipeline |

---

## 🚀 Run Locally

```bash
# Clone the repo
git clone https://github.com/jimmyjohn1996/flask-docker-compose.git
cd flask-docker-compose

# Start all containers
docker-compose up --build

# Open in browser
http://localhost:5001
```

---

## 📁 Project Structure

```
flask-docker-compose/
├── app.py                   # Flask application
├── requirements.txt         # Python dependencies
├── Dockerfile               # Container configuration
├── docker-compose.yml       # Multi-container setup (local)
├── docker-compose.prod.yml  # Production config (RDS)
├── .dockerignore            # Files to exclude
└── templates/
    └── index.html           # Reservation form UI
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | / | Reservation form |
| GET | /reservations | Get all reservations |
| POST | /reserve | Create reservation |
| GET | /health | Health check (ALB) |

---

## ⚙️ Environment Variables

| Variable | Default | Description |
|---|---|---|
| DB_HOST | db | Database host |
| DB_PORT | 5432 | Database port |
| DB_NAME | restaurant | Database name |
| DB_USER | postgres | Database user |
| DB_PASS | secret | Database password |

---

## 🌍 Deployment

### Local (Docker Compose)
```bash
docker-compose up --build
```

### Production (AWS EC2 + RDS)
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📝 What I Learned

- Writing multi-container Docker Compose files
- Connecting Flask to PostgreSQL via environment variables
- Data persistence with Docker named volumes
- Deploying multi-container apps on AWS EC2
- Managed databases with AWS RDS
- HTTPS termination with AWS ALB
- Production vs development Docker Compose configs
- CI/CD pipeline with GitHub Actions
