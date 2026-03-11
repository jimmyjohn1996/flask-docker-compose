# 🚀 Deployment Guide — Saffron & Sage

Complete step-by-step guide to deploy this application from scratch.

---

## 📋 Prerequisites

| Tool | Version | Install |
|---|---|---|
| Docker | 29.x+ | [docker.com](https://docker.com) |
| Docker Compose | 5.x+ | included with Docker Desktop |
| Git | any | [git-scm.com](https://git-scm.com) |
| AWS Account | - | [aws.amazon.com](https://aws.amazon.com) |
| Python | 3.9+ | [python.org](https://python.org) |

---

## 1️⃣ Local Development

### Clone the repo
```bash
git clone https://github.com/jimmyjohn1996/flask-docker-compose.git
cd flask-docker-compose
```

### Start all containers
```bash
docker-compose up --build
```

### Open in browser
```
http://localhost:5001
```

### Useful commands
```bash
# Run in background
docker-compose up -d

# Check running containers
docker-compose ps

# Check logs
docker-compose logs -f

# Check logs for specific service
docker-compose logs -f web

# Stop containers
docker-compose down

# Stop and delete all data
docker-compose down -v
```

---

## 2️⃣ AWS EC2 Setup

### Launch EC2 Instance
```
AMI:           Amazon Linux 2023
Instance type: t2.micro (free tier)
Key pair:      Create new → download .pem file
Security Group inbound rules:
  SSH   port 22   → Your IP
  HTTP  port 80   → 0.0.0.0/0
  HTTPS port 443  → 0.0.0.0/0
  TCP   port 5001 → ALB Security Group
```

### Connect to EC2
```bash
ssh -i ~/Downloads/docker.pem ec2-user@YOUR_EC2_IP
```

### Install Docker on EC2
```bash
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
# Log out and back in!
```

### Install Docker Compose on EC2
```bash
mkdir -p ~/.docker/cli-plugins

curl -SL https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx

chmod +x ~/.docker/cli-plugins/docker-buildx

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### Copy project to EC2
```bash
# On your Mac
scp -i ~/Downloads/docker.pem -r flask-docker-compose/ ec2-user@YOUR_EC2_IP:~/flask-docker-compose/
```

---

## 3️⃣ AWS RDS Setup

### Create RDS Instance
```
Engine:        PostgreSQL 15
Template:      Free tier
Identifier:    restaurant-db
Username:      postgres
Password:      YOUR_STRONG_PASSWORD
Instance:      db.t3.micro
Storage:       20 GB
Public access: No  ← important!
VPC:           default (same as EC2)
Security Group: Create new → rds-sg
  Inbound: PostgreSQL 5432 → EC2 Security Group
Additional config:
  Database name: restaurant  ← important!
```

### Get RDS Endpoint
```
AWS Console → RDS → Databases → restaurant-db
→ Connectivity & security → Endpoint
Looks like: restaurant-db.xxxxxxxxxx.us-east-1.rds.amazonaws.com
```

### Verify EC2 can reach RDS
```bash
# On EC2
telnet YOUR_RDS_ENDPOINT 5432
# Should show: Connected!
```

### Install psql on EC2
```bash
sudo dnf install -y postgresql15
```

### Create database on RDS
```bash
psql -h YOUR_RDS_ENDPOINT \
     -U postgres \
     -p 5432 \
     -c "CREATE DATABASE restaurant;"
```

---

## 4️⃣ Production Deployment

### Update docker-compose.prod.yml with RDS endpoint
```yaml
services:
  web:
    build: .
    container_name: flask_app
    ports:
      - "5001:5000"
    environment:
      DB_HOST: YOUR_RDS_ENDPOINT
      DB_PORT: 5432
      DB_NAME: restaurant
      DB_USER: postgres
      DB_PASS: "YOUR_RDS_PASSWORD"
    restart: always
```

### Deploy on EC2
```bash
cd ~/flask-docker-compose

# Start with production config
docker-compose -f docker-compose.prod.yml up --build -d

# Verify
docker-compose -f docker-compose.prod.yml ps
```

Should show:
```
flask_app   Up (healthy)   0.0.0.0:5001->5000/tcp
```

---

## 5️⃣ HTTPS with ALB

### Create Target Group
```
Target type:  Instances
Name:         flask-tg
Protocol:     HTTP
Port:         5001
Health check path: /health
Success codes: 200

Register targets:
  Select EC2 instance
  Port: 5001
```

### Create ALB Security Group
```
Name: alb-sg
Inbound:
  HTTP  80  → 0.0.0.0/0
  HTTPS 443 → 0.0.0.0/0
```

### Create Application Load Balancer
```
Name:    flask-alb
Scheme:  Internet-facing
VPC:     default
Zones:   select all

Security Group: alb-sg

Listeners:
  HTTPS 443 → Forward to flask-tg
              Certificate: *.devopsj.com (ACM)
  HTTP  80  → Redirect to HTTPS
```

### Request SSL Certificate (ACM)
```
AWS Console → Certificate Manager
→ Request public certificate
→ Domain: *.devopsj.com
→ Validation: DNS
→ Create records in Route 53 (auto)
```

### Create Route 53 Record
```
Hosted zone: devopsj.com
Record name: app
Type:        A
Alias:       Yes
Target:      ALB DNS name
```

### Update EC2 Security Group
```
Add inbound rule:
  TCP  5001  → alb-sg (ALB security group only!)
```

### Test
```
https://app.devopsj.com  → should load app ✅
http://app.devopsj.com   → should redirect to HTTPS ✅
```

---

## 6️⃣ CI/CD Pipeline

### GitHub Secrets Required
```
DOCKERHUB_USERNAME  → your Docker Hub username
DOCKERHUB_TOKEN     → Docker Hub access token
EC2_HOST            → EC2 public IP
EC2_KEY             → contents of .pem file
```

### How to get Docker Hub Token
```
hub.docker.com → Account Settings
→ Security → New Access Token
→ Copy token
```

### Workflow location
```
.github/workflows/deploy.yml
```

### How it works
```
git push → GitHub Actions triggers
         → Builds Docker image
         → Pushes to Docker Hub
         → SSHs into EC2
         → Pulls new image
         → Restarts container
         → Live in ~2 minutes!
```

---

## 🔒 Security Checklist

- [x] RDS has no public access
- [x] EC2 only accepts port 5001 from ALB
- [x] ALB handles HTTPS/SSL
- [x] Flask runs as non-root user
- [x] Passwords stored in environment variables
- [x] No secrets in GitHub repo
- [x] .gitignore prevents accidental commits

---

## 💰 Cost Management

| Service | Cost |
|---|---|
| EC2 t2.micro | Free tier / ~$8/month |
| RDS db.t3.micro | Free tier / ~$15/month |
| ALB | ~$16/month |
| Route 53 | ~$0.50/month |

**Stop services when not in use to avoid charges!**

```bash
# Stop EC2 → AWS Console → EC2 → Stop instance
# Stop RDS → AWS Console → RDS → Stop temporarily
# Delete ALB when not needed
```

---

## 🐛 Troubleshooting

### Container keeps restarting
```bash
docker-compose -f docker-compose.prod.yml logs
# Look for error message
```

### Can't connect to RDS
```bash
# Test connection from EC2
telnet YOUR_RDS_ENDPOINT 5432

# Check RDS security group allows EC2
# Check EC2 and RDS are in same VPC
```

### Port already in use
```bash
# Find what's using the port
lsof -i :5001

# Kill the process or change port in docker-compose.yml
```

### GitHub Actions SSH fails
```bash
# Check EC2_KEY secret contains full .pem contents
# Including -----BEGIN RSA PRIVATE KEY-----
# And -----END RSA PRIVATE KEY-----
```
