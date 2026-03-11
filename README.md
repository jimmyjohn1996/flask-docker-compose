# 🍽️ Saffron & Sage — Restaurant Reservation System

A full-stack restaurant reservation system built with Flask and PostgreSQL, containerized with Docker Compose and deployed on AWS with HTTPS.

---

## 🏗️ Architecture

### Local Development
```
┌─────────────────────────────────────────┐
│           Docker Compose                │
│                                         │
│  ┌──────────────────┐                  │
│  │   Flask App       │                  │
│  │   python:3.11     │◄── Browser       │
│  │   port 5001       │                  │
│  └────────┬──────────┘                  │
│           │ SQL queries                 │
│           │ DB_HOST=db                  │
│  ┌────────▼──────────┐                  │
│  │   PostgreSQL       │                  │
│  │   postgres:15      │                  │
│  │   port 5432        │                  │
│  └────────┬──────────┘                  │
│           │                             │
│  ┌────────▼──────────┐                  │
│  │   pgdata volume    │                  │
│  │   (persistent)     │                  │
│  └───────────────────┘                  │
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
                    │  │   ACM Certificate *.devopsj.com   │   │
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
                    │  │   AWS RDS (PostgreSQL 15)          │   │
                    │  │   port 5432                        │   │
                    │  │   Private access only (no public)  │   │
                    │  │   Automated backups                │   │
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
    └── SSH into EC2
            │
            └── Pull new image
                └── Restart container
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
| AWS RDS (PostgreSQL 15) | Managed database with backups |
| AWS ALB | Load balancer + HTTPS termination |
| AWS ACM | Free SSL certificate |
| AWS Route 53 | DNS — app.devopsj.com |
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

## 🌍 Production Deployment

```bash
# On EC2 — use production compose file (points to RDS)
docker-compose -f docker-compose.prod.yml up --build -d
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
├── .dockerignore            # Files to exclude from image
├── .gitignore               # Files to exclude from git
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
| DB_HOST | db | Database host (use RDS endpoint in prod) |
| DB_PORT | 5432 | Database port |
| DB_NAME | restaurant | Database name |
| DB_USER | postgres | Database user |
| DB_PASS | secret | Database password |

---

## 🔒 Security

- RDS has **no public access** — only EC2 can connect
- ALB Security Group allows only HTTP/HTTPS from internet
- EC2 Security Group allows port 5001 only from ALB
- Flask runs as **non-root user** inside container
- Secrets managed via environment variables (never hardcoded)

---

## 💰 Cost Note

Infrastructure (EC2 + RDS + ALB) is stopped when not
in use to avoid unnecessary AWS costs.
To redeploy — clone repo and follow deployment steps above.

---

## 📝 What I Learned

- Writing multi-container Docker Compose files
- Connecting Flask to PostgreSQL via environment variables
- Data persistence with Docker named volumes
- Deploying multi-container apps on AWS EC2
- Managed databases with AWS RDS (PostgreSQL 15)
- Private RDS — no public access, EC2 only
- HTTPS termination with AWS ALB
- Free SSL certificates with AWS ACM
- Custom domain with AWS Route 53
- Production vs development Docker Compose configs
- CI/CD pipeline with GitHub Actions
- AWS cost management
