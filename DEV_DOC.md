DEV DOCUMENTATION
=================

Prerequisites:

    - Install Docker and Docker-compose.
    - Install Make
    - Useful installs
            -> curl
            -> passwd

Build and Lauch project:

    - Use `make` command. It will execute docker-compose commands and build the entire project.

Relevant commands:

    - To inspect the volumes    -> `docker volume ls`
                                -> `docker volume inspect <volume_name>`
    - To remove volumes         -> `docker volume rm <volume_name>`
    - To inspect containers `docker ps -a`
    - Acces container           -> `docker exec -it <container_name> sh`
    - View logs                 -> `docker logs <container_name>`