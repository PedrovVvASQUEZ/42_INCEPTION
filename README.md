*This project has been created as part of the 42 curriculum by <pgrellie>*

_INCEPTION #42_


Description:

	Inception is a 42 project. The goal is to create a small and secure web infrastructure using Docker, Docker Compose, a Makefile and with persistent data volumes.


Intructions:

	In order to launch Inception you'll first need to create or to copy a saved ".env" file at the root of the project.
	It contains Values that will be injected into the containers with compose and will be used by the scripts in order to auto configure MariaDB and Wordpress.

	Then enter make in the terminal.
	Once it's done you can acces WordPress by typing "https://pgrellie.42.fr" in your favorite browser.


Resources:

	- To learn Docker	-> "https://dyma.fr/developer/list/chapters/core": complete formation
						-> "https://www.youtube.com/watch?v=J27puPcFFQo": cool Youtube video to get started

	- To exercise yourself at using Docker -> "https://labex.io/fr/exercises/docker"
	(I've not checked it yet but it looks very interesting)

	- nginx official doc	-> "https://nginx.org/en/docs/"

	- Some tutorials and useful sites	-> "https://tuto.grademe.fr/inception/img/	docker-compose.png"
										-> "https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671"

										-> "https://medium.com/@ssterdev/inception-42-project-part-ii-19a06962cf3b"

										-> "https://medium.com/@imyzf/inception-3979046d90a0"

	AI was used to help with the data and simplifying documentation as well for debugging.


Project Description:

	3 homemade Docker Images for each nginx, mariadb and wordpress. Containers are created with Docker Compose and all can be orchestrated with the Makefile.
	The Docker files create the Docker Images. Scripts are used to auto configure the isolated services. The site is HTTPS(443) only. Security Certificates (TLS) are generated and auto-signed.

	A Virtual Machine is a complete OS. It takes space and can be slow.
	Docker isolate needed processes only. Images are light and quick to lauch.

	Secrets are managed by Docker. 
	Env variables are visible in the environnement but less secure.

	Docker network use "bridges". Internal isolated network DNS(Domain Name System) between services. No port conflicts
	The Host Network shares the host's network stack. So no isolation of services and possible conflicts.

	Docker Volumes are managed by Docker using "docker volume etc", are portable so easy to install, to configure and less related to the host PATH.
	Bind mounts are explicit PATHS. They are dependant on the local structure.

 
Useful commands:

- docker ps -a				*Show all running containers*
- docker top MyContainer	*Show processes running inside a container*
- docker stats				*Show stats about a container*
									ou
- docker stats --no-stream
- docker stop MyContainer	*Cleanely stop a container*
- docker kill MyContainer	*Forces a container to stop running*
- docker run -p				*For port mapping*
- docker volume ls			*Show named volumes (if nothing appearse it could be bind mounts)*
- docker network ls			*Show the networks*

#Hope this was readable !