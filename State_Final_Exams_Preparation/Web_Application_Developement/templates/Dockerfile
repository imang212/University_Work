FROM php:8.2-apache
# instalace PDO rozšíření pro komunikaci s MySQL/MariaDB
RUN docker-php-ext-install pdo pdo_mysql
# Povolení mod_rewrite (často se hodí pro hezké URL adresy v API)
RUN a2enmod rewrite
# docker compose up -d