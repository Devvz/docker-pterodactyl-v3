# Pterodactyl Docker Containers

**V3**

This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- Web Server (NGINX)
- Pterodactyl (PHP)  
- MySQL (MariaDB)  

These containers were built with CentOS 7.1 using PHP7.

**V4**

For the next version, I'd liek to reconfigure PHP to be on a completely separate server than Pterodactyl so that we can continue adding PHP servers to scale as necessary. It would also be beneficial to configure a Memcached server for additional caching.

## Overview

**docker-compose.yml (creates containers for all services)**

**Dockerfile (configures the applications within the container)**

## Deploy

- Move repository to a local directory on the host and ensure docker-compose.yml is at the root
- Apply permissions to the entrypoint.sh file in the local repository
`chmod a+x files/php/bin/entrypoint.sh`
- Deploy the containers  
`docker-compose up` This reads the docker-compose.yml file which pulls the image from wherever specified in the docker-compose.yml file, creates the containers based on the specifications in the yml (including volumes, hostname, container name, etc.), and then performs the remaining operations contained within the Dockerfile (installation of applications, configuration of applications, etc.).










## Overview (OLD)

**Dockerfile (configures Pterodactyl/PHP image)**
- Installs PHP on image (this is actually a shared volume with the PHP and NGINX container)
- ~~Run the following commands during the PHP installation (Dockerfile):~~  
~~`ln -s /usr/bin/php70 /usr/bin/php`  
`ln -s /usr/bin/php70-phar /usr/bin/php-phar`  
*Log: 2016/12/22 - These symlinks are required to allow the `php` command to function, as it references `/usr/bin/php`. I have added them to the Dockerfile.*~~  
- Uploads the `/files` directory from GitHub to host (contains `/etc/supervisor/conf.d/pterodactyl-worker.conf/` for queue listeners and `/var/www/html/entrypoint.sh` for `php artisan` settings)
- Changes directory to extraction destination (`/apps/pterodactyl/`)
- Extracts Pterodactyl files to current directory on image (for panel installation)
- Installs Composer on image
- ~~Perform the `composer setup` command (Dockerfile)  
*Log: 2016/12/22 - We are already doing this using the `composer install --ansi --no-dev` command. This is the same command executed in a different way.*~~  
- `ENTRYPOINT` specifies location to `php artisan` environment configuration settings  
~~`php artisan pterodactyl:env`  
`php artisan pterodactyl:mail`  
`php artisan migrate`  
`php artisan db:seed`  
`php artisan pterodactyl:user`  
*Log: 2016/12/22 - Created entrypoint.sh and added this to the Dockerfile to configure the `php artisan` settings.*~~  

**docker-compose.yml (creates containers for all services)**
- Creates web container using NGINX
- Configures NGINX by copying configuration file from host (`/etc/nginx/sites-available/pterodactyl.conf`) (this file is modified to point to the php service on port 9000 instead of locally)
- Creates Pterodactyl container by pulling image we created in the Dockerfile from Quay.io (for the panel and PHP)
- Configures Pterodactyl container environment variables (db_env) and copies configuration file from host (`/etc/supervisor/conf.d/pterodactyl-worker.conf)
- ~~3) Queue listeners (Configuration File):  
`pterodactyl-worker.conf` in `/etc/supervisor/conf.d` directory  
`[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/html/artisan queue:work database --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/html/storage/logs/queue-worker.log`  
*Log: 2016/12/22 - Added `- ./files/etc/supervisor/conf.d/pterodactyl-worker.conf/:/etc/supervisor/conf.d/pterodactyl-worker.conf` to docker-composer.yml*~~  
- Creates database container using MariaDB
- Configures database container environment variables (MYSQL_env)

**Missing Steps**

- Run the following commands during the Pterodactyl installation (docker-compose.yml):  
`chmod -R 777 storage/* bootstrap/cache`  
`chown -R www-data:www-data *`  
- 1) Queue listeners (Crontab):  
`crontab -e`  
`* * * * * php /var/www/pterodactyl/html/artisan schedule:run >> /dev/null 2>&1`  
- 2) Queue listeners (Supervisor):  
`apt-get install supervisor`  
`service supervisor start`  
- 4) Queue listeners (Update Supervisor):  
`supervisorctl reread`  
`supervisorctl update`  
- 5) Queue listeners (Start Worker Queue):  
`supervisorctl start pterodactyl-worker:*`  
`systemctl enable supervisor`  
- Run the following to symlink the new configuration file into the sites-enabled folder  
`ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`  
`systemctl restart nginx`  
*Log: This can be done via a symlink (somehow) or, alternatively, by simply copying the file into both directories in the `docker-compose.yml`*

## Questions

- Copying over the files is beginning to become confusing since we're copying the `./files/` directory to the host but we're also now installing Pterodactyl to a shared volume.
- How are we supposed to copy over the required files for the NGINX container? Right now we're using them in the `./files`/ directory but this really should just be for PHP.
- The volume specified in the `docker-compose.yml` for MariaDB `- ./dbdata:/var/lib/mysql`, what is this source and destination?
- Right now everything is using the shared volume at the top level. Can we make folders in the shared volume to separate the data?
