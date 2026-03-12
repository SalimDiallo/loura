# 🚀 Loura Stack - Django + Next.js

Application complète avec Django (backend) + Next.js (frontend) conteneurisée avec Docker.

## 📦 Stack Technique

**Backend:**
- Django 5.2 + DRF
- PostgreSQL 16
- Redis 7
- Celery (Worker + Beat)
- Django Channels (WebSocket)

**Frontend:**
- Next.js 16 (React 19)
- TypeScript
- Tailwind CSS

**Infrastructure:**
- Docker + Docker Compose
- Nginx (production)
- Certbot/Let's Encrypt (SSL)

---

## ⚡ Démarrage Rapide

### Développement Local

```bash
# 1. Cloner et naviguer dans le projet
cd /path/to/loura/stack

# 2. Configurer l'environnement backend
cp backend/.env.example backend/.env
# Éditer backend/.env avec vos valeurs

# 3. Démarrer tous les services
docker compose up -d

# 4. Créer un superuser
docker compose exec backend python manage.py createsuperuser

# 5. Accéder à l'application
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# Admin: http://localhost:8000/admin
```

### Production (VPS)

```bash
# 1. Sur votre serveur, installer Docker
curl -fsSL https://get.docker.com | sh

# 2. Cloner le projet
git clone <your-repo> && cd loura/stack

# 3. Configurer l'environnement
cp .env.production.example .env.production
nano .env.production  # Modifier avec vos vraies valeurs

# 4. Lancer le déploiement
chmod +x deploy.sh
./deploy.sh
# Choisir l'option 1 (Déploiement initial)

# 5. Configurer SSL (après configuration DNS)
./deploy.sh
# Choisir l'option 5 (Obtenir certificat SSL)
```

---

## 📚 Documentation

Pour des instructions détaillées de déploiement, voir **[DEPLOYMENT.md](./DEPLOYMENT.md)**

## 🛠️ Commandes Utiles

```bash
# Voir les logs
docker compose logs -f

# Redémarrer un service
docker compose restart backend

# Migrations Django
docker compose exec backend python manage.py makemigrations
docker compose exec backend python manage.py migrate

# Shell Django
docker compose exec backend python manage.py shell

# Rebuild complet
docker compose down
docker compose build --no-cache
docker compose up -d
```

## 🌐 URLs

**Développement:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000/api/
- Django Admin: http://localhost:8000/admin/
- WebSocket: ws://localhost:8000/ws/

**Production (avec nginx):**
- Application: https://yourdomain.com
- API: https://yourdomain.com/api/
- Admin: https://yourdomain.com/admin/
- WebSocket: wss://yourdomain.com/ws/

## 🔧 Variables d'Environnement Importantes

**Backend (`.env`):**
```env
DB_ENGINE=django.db.backends.postgresql
DB_NAME=loura_db
DB_USER=loura_user
DB_PASSWORD=your-password
REDIS_HOST=redis
CELERY_BROKER_URL=redis://redis:6379/0
```

**Production (`.env.production`):**
```env
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
CORS_ALLOWED_ORIGINS=https://yourdomain.com
CSRF_TRUSTED_ORIGINS=https://yourdomain.com
```

## 📁 Structure

```
loura/stack/
├── backend/               # Django application
│   ├── app/              # Code Django
│   ├── Dockerfile        # Image Docker backend
│   └── docker-entrypoint.sh
├── frontend/
│   └── lourafrontend/    # Next.js application
│       └── Dockerfile    # Image Docker frontend
├── nginx/                # Configuration Nginx (prod)
│   ├── Dockerfile
│   ├── nginx.conf
│   └── conf.d/
├── docker-compose.yml    # Développement
├── docker-compose.prod.yml  # Production
├── deploy.sh             # Script de déploiement
└── DEPLOYMENT.md         # Guide complet
```

## 🐛 Problèmes Courants

**Le backend ne démarre pas:**
```bash
docker compose logs backend
docker compose exec backend python manage.py migrate
```

**Erreur de connexion PostgreSQL:**
```bash
docker compose ps db
docker compose exec backend nc -zv db 5432
```

**Problème de permissions:**
```bash
docker compose exec backend chown -R django:django /app
```

## 📞 Support

- Voir [DEPLOYMENT.md](./DEPLOYMENT.md) pour le guide complet
- Consulter les logs: `docker compose logs -f`
- Documentation Django: https://docs.djangoproject.com/
- Documentation Next.js: https://nextjs.org/docs

---

**Fait avec ❤️ par l'équipe Loura**
