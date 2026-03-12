#!/bin/bash

# ===================================
# Script de déploiement Loura
# ===================================

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Démarrage du déploiement Loura...${NC}"

# Vérifier que Docker et Docker Compose sont installés
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé. Veuillez l'installer d'abord.${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord.${NC}"
    exit 1
fi

# Vérifier que le fichier .env.production existe
if [ ! -f .env.production ]; then
    echo -e "${YELLOW}⚠️  Le fichier .env.production n'existe pas.${NC}"
    echo -e "${YELLOW}📝 Copie de .env.production.example vers .env.production...${NC}"
    cp .env.production.example .env.production
    echo -e "${RED}❌ IMPORTANT: Éditez .env.production avec vos vraies valeurs avant de continuer!${NC}"
    exit 1
fi

# Menu de choix
echo ""
echo "Que voulez-vous faire ?"
echo "1) Déploiement initial (première installation)"
echo "2) Mise à jour (redéploiement)"
echo "3) Arrêter les services"
echo "4) Voir les logs"
echo "5) Obtenir un certificat SSL avec Certbot"
echo "6) Nettoyer (supprimer tous les conteneurs et volumes)"
read -p "Votre choix [1-6]: " choice

case $choice in
    1)
        echo -e "${GREEN}📦 Déploiement initial...${NC}"

        # Créer les dossiers nécessaires
        echo -e "${YELLOW}📁 Création des dossiers...${NC}"
        mkdir -p certbot/conf certbot/www

        # Charger les variables d'environnement
        export $(cat .env.production | grep -v '^#' | xargs)

        # Build et démarrage des conteneurs
        echo -e "${YELLOW}🔨 Construction des images Docker...${NC}"
        docker compose -f docker-compose.prod.yml build

        echo -e "${YELLOW}🚀 Démarrage des services...${NC}"
        docker compose -f docker-compose.prod.yml up -d

        echo -e "${GREEN}✅ Déploiement terminé !${NC}"
        echo ""
        echo -e "${YELLOW}📋 Prochaines étapes :${NC}"
        echo "1. Configurez vos DNS pour pointer vers ce serveur"
        echo "2. Exécutez './deploy.sh' et choisissez l'option 5 pour obtenir un certificat SSL"
        echo "3. Décommentez la configuration HTTPS dans nginx/conf.d/default.conf"
        echo "4. Redémarrez nginx: docker compose -f docker-compose.prod.yml restart nginx"
        ;;

    2)
        echo -e "${GREEN}🔄 Mise à jour de l'application...${NC}"

        # Charger les variables d'environnement
        export $(cat .env.production | grep -v '^#' | xargs)

        # Rebuild et redémarrage
        echo -e "${YELLOW}🔨 Reconstruction des images...${NC}"
        docker compose -f docker-compose.prod.yml build

        echo -e "${YELLOW}🔄 Redémarrage des services...${NC}"
        docker compose -f docker-compose.prod.yml up -d

        echo -e "${GREEN}✅ Mise à jour terminée !${NC}"
        ;;

    3)
        echo -e "${YELLOW}⏸️  Arrêt des services...${NC}"
        docker compose -f docker-compose.prod.yml down
        echo -e "${GREEN}✅ Services arrêtés${NC}"
        ;;

    4)
        echo -e "${YELLOW}📋 Affichage des logs...${NC}"
        echo "Quel service voulez-vous voir ?"
        echo "1) Tous"
        echo "2) Backend"
        echo "3) Frontend"
        echo "4) Nginx"
        echo "5) Celery Worker"
        echo "6) Celery Beat"
        read -p "Votre choix [1-6]: " log_choice

        case $log_choice in
            1) docker compose -f docker-compose.prod.yml logs -f ;;
            2) docker compose -f docker-compose.prod.yml logs -f backend ;;
            3) docker compose -f docker-compose.prod.yml logs -f frontend ;;
            4) docker compose -f docker-compose.prod.yml logs -f nginx ;;
            5) docker compose -f docker-compose.prod.yml logs -f celery_worker ;;
            6) docker compose -f docker-compose.prod.yml logs -f celery_beat ;;
            *) echo -e "${RED}❌ Choix invalide${NC}" ;;
        esac
        ;;

    5)
        echo -e "${GREEN}🔐 Configuration SSL avec Let's Encrypt...${NC}"

        # Charger les variables d'environnement
        export $(cat .env.production | grep -v '^#' | xargs)

        # Extraire le domaine principal
        DOMAIN=$(echo $ALLOWED_HOSTS | cut -d',' -f1)

        read -p "Entrez votre domaine (exemple: yourdomain.com): " USER_DOMAIN
        read -p "Entrez votre email pour Let's Encrypt: " EMAIL

        echo -e "${YELLOW}🔐 Obtention du certificat SSL pour $USER_DOMAIN...${NC}"

        docker compose -f docker-compose.prod.yml run --rm certbot certonly \
            --webroot \
            --webroot-path=/var/www/certbot \
            --email $EMAIL \
            --agree-tos \
            --no-eff-email \
            -d $USER_DOMAIN \
            -d www.$USER_DOMAIN

        echo -e "${GREEN}✅ Certificat SSL obtenu !${NC}"
        echo -e "${YELLOW}📝 N'oubliez pas de :${NC}"
        echo "1. Décommenter la configuration HTTPS dans nginx/conf.d/default.conf"
        echo "2. Remplacer 'yourdomain.com' par '$USER_DOMAIN'"
        echo "3. Redémarrer nginx: docker compose -f docker-compose.prod.yml restart nginx"
        ;;

    6)
        echo -e "${RED}⚠️  ATTENTION: Cela va supprimer tous les conteneurs et volumes !${NC}"
        read -p "Êtes-vous sûr ? (oui/non): " confirm

        if [ "$confirm" = "oui" ]; then
            echo -e "${YELLOW}🧹 Nettoyage...${NC}"
            docker compose -f docker-compose.prod.yml down -v
            echo -e "${GREEN}✅ Nettoyage terminé${NC}"
        else
            echo -e "${YELLOW}❌ Opération annulée${NC}"
        fi
        ;;

    *)
        echo -e "${RED}❌ Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✨ Terminé !${NC}"
