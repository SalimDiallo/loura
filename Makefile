.PHONY: help dev prod up down logs restart clean migrate shell collectstatic build

# Variables
COMPOSE_DEV = docker compose
COMPOSE_PROD = docker compose -f docker-compose.prod.yml
BACKEND_EXEC = $(COMPOSE_DEV) exec backend

help: ## Afficher cette aide
	@echo "Commandes disponibles :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# DÉVELOPPEMENT
# ==============================================================================

dev: ## Démarrer l'environnement de développement
	$(COMPOSE_DEV) up -d
	@echo "✅ Environnement de développement démarré"
	@echo "Frontend: http://localhost:3000"
	@echo "Backend: http://localhost:8000"
	@echo "Admin: http://localhost:8000/admin"

build: ## Construire les images Docker
	$(COMPOSE_DEV) build --no-cache

up: ## Démarrer tous les services (détaché)
	$(COMPOSE_DEV) up -d

down: ## Arrêter tous les services
	$(COMPOSE_DEV) down

restart: ## Redémarrer tous les services
	$(COMPOSE_DEV) restart

logs: ## Voir les logs de tous les services
	$(COMPOSE_DEV) logs -f

logs-backend: ## Voir les logs du backend
	$(COMPOSE_DEV) logs -f backend

logs-frontend: ## Voir les logs du frontend
	$(COMPOSE_DEV) logs -f frontend

logs-celery: ## Voir les logs de Celery
	$(COMPOSE_DEV) logs -f celery_worker celery_beat

ps: ## Voir l'état des conteneurs
	$(COMPOSE_DEV) ps

# ==============================================================================
# BACKEND / DJANGO
# ==============================================================================

shell: ## Ouvrir un shell Django
	$(BACKEND_EXEC) python manage.py shell

dbshell: ## Ouvrir un shell PostgreSQL
	$(COMPOSE_DEV) exec db psql -U loura_user -d loura_db

migrate: ## Appliquer les migrations
	$(BACKEND_EXEC) python manage.py migrate

makemigrations: ## Créer des migrations
	$(BACKEND_EXEC) python manage.py makemigrations

collectstatic: ## Collecter les fichiers statiques
	$(BACKEND_EXEC) python manage.py collectstatic --noinput

createsuperuser: ## Créer un superuser Django
	$(BACKEND_EXEC) python manage.py createsuperuser

test: ## Lancer les tests backend
	$(BACKEND_EXEC) python manage.py test

# ==============================================================================
# PRODUCTION
# ==============================================================================

prod-build: ## Construire les images pour la production
	$(COMPOSE_PROD) build --no-cache

prod-up: ## Démarrer l'environnement de production
	$(COMPOSE_PROD) up -d

prod-down: ## Arrêter l'environnement de production
	$(COMPOSE_PROD) down

prod-logs: ## Voir les logs de production
	$(COMPOSE_PROD) logs -f

prod-restart: ## Redémarrer les services de production
	$(COMPOSE_PROD) restart

# ==============================================================================
# NETTOYAGE
# ==============================================================================

clean: ## Arrêter et supprimer tous les conteneurs
	$(COMPOSE_DEV) down -v
	@echo "⚠️  Tous les conteneurs et volumes ont été supprimés"

clean-prod: ## Nettoyer l'environnement de production
	$(COMPOSE_PROD) down -v
	@echo "⚠️  Environnement de production nettoyé"

prune: ## Nettoyer Docker complètement (images, volumes, etc.)
	docker system prune -a --volumes
	@echo "⚠️  Docker a été complètement nettoyé"

# ==============================================================================
# BACKUP & RESTORE
# ==============================================================================

backup-db: ## Sauvegarder la base de données
	@mkdir -p backups
	$(COMPOSE_DEV) exec -T db pg_dump -U loura_user loura_db > backups/db_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Base de données sauvegardée dans backups/"

restore-db: ## Restaurer la base de données (BACKUP_FILE=path/to/backup.sql make restore-db)
	@if [ -z "$(BACKUP_FILE)" ]; then echo "❌ Erreur: Spécifiez BACKUP_FILE=path/to/backup.sql"; exit 1; fi
	cat $(BACKUP_FILE) | $(COMPOSE_DEV) exec -T db psql -U loura_user loura_db
	@echo "✅ Base de données restaurée"

# ==============================================================================
# UTILITAIRES
# ==============================================================================

install: ## Installation initiale (première fois)
	@echo "🚀 Installation de Loura..."
	cp backend/.env.example backend/.env || true
	cp .env.production.example .env.production || true
	@echo "📝 Éditez backend/.env avec vos configurations"
	@echo "Ensuite, lancez 'make dev' pour démarrer"

deps: ## Installer les dépendances Python (si besoin de tester localement)
	pip install -r backend/requirements.txt

format: ## Formater le code Python (si black est installé)
	@command -v black >/dev/null 2>&1 && black backend/app || echo "⚠️  Black n'est pas installé"

lint: ## Linter le code Python (si flake8 est installé)
	@command -v flake8 >/dev/null 2>&1 && flake8 backend/app || echo "⚠️  Flake8 n'est pas installé"
