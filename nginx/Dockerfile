FROM nginx:alpine

# Copier la configuration nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d

# Créer les répertoires pour les certificats SSL et static/media
RUN mkdir -p /var/www/certbot /app/staticfiles /app/media

# Exposer les ports HTTP et HTTPS
EXPOSE 80 443

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
