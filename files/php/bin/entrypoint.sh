#!/bin/bash
set -e

if [ "$1" = 'supervisord' ]; then

echo "Getting ready to start. Waiting 15 seconds for mariadb to start if you are using docker compose"

sleep 15

    if [ ! -e .env ]; then #Didn't find the .env file
        echo "env not found. Copying from example"
        cp .env.example .env
        echo "  Generating application key"
        php artisan key:generate
        echo "  Setting up db and email settings"
        php artisan pterodactyl:env --dbhost=$db_host --dbport=$db_port --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --url=$panel_url --timezone=$timezone

        case "$email_driver" in
            mail)
            echo "PHP Mail was chosen"
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email
            ;;

            mandrill)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user
            echo "Mandrill was chosen"
            ;;

            postmark)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user
            echo "Postmark was chosen"
            ;;

            mailgun)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user --host=$email_domain
            echo "Mailgun was chosen"
            echo "$email_driver $panel_email $email_username $email_domain"
            ;;

            smtp)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user --password=$email_pass --host=$email_domain --port=$email_port
            echo "smtp was chosen"
            echo "$email_driver $panel_email $email_user $email_pass $email_domain $email_port"
            ;;

            *)
            echo "There was an error and you need to run the container again with the email information"
         esac
            echo "Migrating Database"
            php artisan migrate --force
            echo "Seeding Database"
            php artisan db:seed --force
            echo "Setting up user"
            php artisan pterodactyl:user --email=$admin_email --password=$admin_pass --admin=$admin_stat
    elif [ ! -s .env ]; then #found an empty .env file
        echo "      env empty"
        echo "      Generating new .env file"
        echo "      Generating application key"
        php artisan key:generate
        echo "      Setting up db and email settings"
        php artisan pterodactyl:env --dbhost=$db_host --dbport=$db_port --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --url=$panel_url --timezone=$timezone

        case "$email_driver" in
            mail)
            echo "      PHP Mail was chosen"
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email
            ;;

            mandrill)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user
            echo "      Mandrill was chosen"
            ;;

            postmark)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user
            echo "      Postmark was chosen"
            ;;

            mailgun)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user --host=$email_domain
            echo "      Mailgun was chosen"
            echo "$email_driver $panel_email $email_username $email_domain"
            ;;

            smtp)
            php artisan pterodactyl:mail --driver=$email_driver --email=$panel_email --username=$email_user --password=$email_pass --host=$email_domain --port=$email_port
            echo "      smtp was chosen"
            echo "$email_driver $panel_email $email_user $email_pass $email_domain $email_port"            ;;

            *)
            echo "      There was an error and you need to run the container again with the email information"
         esac
            echo "      Migrating Database"
            php artisan migrate --force
            echo "      Seeding Database"
            php artisan db:seed --force
            echo "      Setting up user"
            php artisan pterodactyl:user --email=$admin_email --password=$admin_pass --admin=$admin_stat
    else # Found an env file and testing for panel version
        echo "      Found env file found. continuing start"
      ##
      ##   This is for future refference and panel upgrades
      ##
      #  if [ $(grep version:0.5.0-pre.[1-3] .env) ]; then ## Matched previous build
      #      echo "      Previous version in this release found. Attempting upgrade"
      #      env=$(cat .env)
      #      printf "version:0.5.0-rc.2\n$env" > .env
      #      echo "      Migrating Database"
      #      php artisan migrate --force
      #      env=$(cat .env)
      #      printf "        version:0.5.0-pre.3\n$env" > .env
      #  elif [ ! $(grep version .env) ]; then ## No version found 
      #      echo "      No version found at head of env file. Setting version and attempting upgrade"
      #      env=$(cat .env)
      #      printf "version:0.5.0-rc.2\n$env" > .env
      #      echo "      Migrating Database"
      #      php artisan migrate --force
      #  elif [ $(grep version:0.5.0-rc.1 .env) ]; then ## Fund matching version
      #      echo '      The env file is for the current version the panel "should" work'
      #  else ## If all else fails assume it works...
      #      echo "      There was an error but I assume the env file is actually working"
      #  fi
    fi
fi

exec "$@"
