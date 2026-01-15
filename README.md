*This project has been created as part of the 42 curriculum by <pgrellie>*

_INCEPTION_

Description:



Intructions:



Resources:

	- To learn Docker	-> "https://dyma.fr/developer/list/chapters/core": complete formation
						-> "https://www.youtube.com/watch?v=J27puPcFFQo": very useful Youtube video

	- To exercise yourself at using Docker -> "https://labex.io/fr/exercises/docker"



C'est quoi une image docker ?

Une image Docker est un modèle immuable qui contient tout le nécessaire pour exécuter une application :

Code source de l'application
Dépendances (librairies, packages)
Système d'exploitation léger (Linux le plus souvent)
Configuration et variables d'environnement
Analogie : Une image Docker est comme un "snapshot" ou un modèle d'une machine virtuelle préconfiguré et prêt à l'emploi.

Points clés :

Réutilisable : Une image crée plusieurs conteneurs (instances en cours d'exécution)
Portable : Fonctionne partout où Docker est installé (dev, test, production)
Léger : Beaucoup plus rapide et petit qu'une VM complète
Créée avec un Dockerfile : Fichier contenant les instructions pour construire l'image
Relation :

Dockerfile = recette pour créer l'image
Image = résultat construit (template)
Conteneur = instance en exécution de l'image (comme une classe vs instance en POO)
Dans votre projet, vous avez des Dockerfiles pour nginx, WordPress et MariaDB qui vont créer 3 images différentes, chacune lancée comme conteneur via le docker-compose.yml.


Commandes utiles:

- docker ps -a				*voir tous les containers en cours d'execution sur mon system*
- docker top MyContainer	*voir les processus en cours d'execution dans un container*
- docker stats				*voir toutes les infos sur un container*
- docker stop MyContainer	*arreter proprement un container*
- docker kill MyContainer	*arret force d'un container*
- docker run -p				*mapper les ports entre hote et container*
- docker


Pour commencer j'ai besoin de savoir a qui sert chaque fichier du projet. Le docker-compose, les docker files les script.sh etc et comment ils sont relier entre avec leurs rôles