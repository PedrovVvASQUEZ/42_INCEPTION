USER DOCUMENTATION
===================

Services Provided :

    - A public website served by WordPress through Nginx.
    - A WordPress administration panel
    - A MariaDB database storing WordPress data.

Start :

	- make

Stop and remove containers :

	- make fclean

Access the Website :
    - open a browser to http://<host>/
    - Admin panel of the website: http://<host>/wp-admin

Locate and Manage Credentials : 

    - Secrets and TLS(Transport Layer Security) certs are stored under `srcs/secrets`.
    - WordPress setup is stored in `srcs/wordpress/tools/wp_setup.sh`.
    - MariaDB setup scripts and defaults are stored in `srcs/mariadb/tools/mariadb_setup.sh`.

Important: store any real credentials securely and do not commit them to version control.

Checking That Services Are Running :

- List running containers:
    -> docker ps

- View logs to confirm healthy startup:
	-> docker compose -f srcs/docker-compose.yml logs -f

- Check web availability:

	curl -I http://localhost/
	curl -I http://localhost/wp-admin