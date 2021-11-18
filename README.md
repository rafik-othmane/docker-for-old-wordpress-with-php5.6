# Docker PHP 5.6 pour un vieux wordpress
Cette image docker embarque une debian stech avec PHP 5.6 et Mariadb mais avec la commande command: --sql_mode=""
dans le docker-compose pour simuler une verison version de mysql aussi.

## Guide d'installation

1) Créer le fichier .env et le docker-compose.override.yml (voir les exemples fournis)
2) Dans mcd/01-create-database.db.sql définir le nom de la bdd et le charset si besoin
3) Lancer les images docker :
   ```bash
   docker-compose up -d --force-recreate --build;
   ```
4) Importer la base de donnée
   ```bash
   mysql -P 0000 -u root -p database < backup.sql
   ```
5) Se connecter en bash à l'image docker de l'application
   ```bash
   docker-compose exec webappserver /bin/bash;
   ```
6) Si changement de domaine appliquer le sed -i du domaine sur les fichiers
   ```bash
   find . -name '*.php' -exec sed -ri 's#www.ancien-domaine.com#www.nouveau-domaine.com#g' {} \;
   ```
   Note : Chercher aussi des occurences tel que www\.ancien\-domaine\.com (issue de regex)
7) Si changement de domaine appliquer le PHP wp-cli.phar search-replace domaine-avant.com domaine-apres.com
  ```bash
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar;
  chmod +x wp-cli.phar;
  php wp-cli.phar search-replace "www.ancien-domaine.com" "www.nouveau-domaine.com" --dry-run --allow-root; 
  ```
8) Le site est accessible au port définie dans le docker-compose.override.yml


[Astuce pour le HTTPS]

Pour le https (utilistation de proxy sur les deux vshots 80 et 443)

```
SSLEngine on
ProxyPass / http://localhost:6969/
ProxyPassReverse / http://localhost:6969/
ProxyPreserveHost On <- *** Important sinon redirections à la con ***
```

et dans le `wp-config.php` on force avec
```php
$_SERVER['HTTPS'] = 'on';
```

