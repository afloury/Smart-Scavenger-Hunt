
## Jour 1 (2017-11-06)

- Prise de connaissance du sujet
- Réflexion sur la mise en place de l'architecture
![alt text](https://github.com/afloury/Smart-Scavenger-Hunt/blob/master/doc/2017-11-06/schema.png "Architecture projet")
- Études des services de reconnaissances visuelles Google Cloud Vision et Watson Visual Recognition (choix du service d'IBM car pas besoin de CB)
- Création d'un projet Watson Visual Recognition pour utiliser l'API d'IBM
- Analyse des priorités de développement
    - Pour le moment, le stockage des données n'est pas prioritaire
    - Études et formations sur les outils inconnus
- [Ébauche de user stories](../blob/master/doc/2017-11-06/USER_STORIES.MD)

________

## Jour 2 (2017-11-07)

- Établissement des routes nécessaires aux différentes API
  - Analyse des différentes routes à réaliser
  - Réflexion sur les cas particuliers (cas réel)
  - Réflexion sur l'aspect sécurité du jeu (éviter la triche)
- [Documentation des routes pour le Router](https://github.com/afloury/Smart-Scavenger-Hunt-Router)
- [Documentation des routes pour le jeu (container)](https://github.com/afloury/Smart-Scavenger-Hunt-Game)
- Mise en place des différents dépôts Git
- Planification des développements
  - planification des tâches à réaliser
  - gestion du projet dans Trello

________

## Jour 3 (2017-11-08)

- Ajout preview dans scan qr-code appli iOS
- Menu de navigation (tab bar iOS)
- Écran de prise de photo app iOS
- Hébergement d'un iBeacon sur Raspberry Pi
- Transmission d'un major/minor arbitraire depuis iBeacon sur Raspberry Pi
- Récupération du major/minor dans iBeacon iOS
- Inscription et tests de communication Google Cloud Vision API
- Code de base pour le routeur
- Transfert dépôts séparés vers branches

________

## Jour 4 (2017-11-09)

- Initialisation du serveur location-restriction
- Route pour récupérer UUID beacon dans location-restriction
- Récupération de l'UUID des beacons dans l'appli iOS depuis route du location-restriction
- Route pour récupérer LRID (token major/minor utilisé pour qr-code et iBeacon)
- Génération des QR-Code sur une page web depuis la route du location-restriction
- Transmission photo iOS => Routeur
- Transmission photo Routeur => Game (sans docker pour l'instant)
- Route inscription dans le routeur (pas encore testée avec iOS pour l'instant)
- Calibration proximité pour détection iBeacon proche sur Raspberry Pi
- Rédaction liste d'objets reconnus par google (pour choisir aléatoirement ceux donnés aux équipes)

________

## Jour 5 (2017-11-10)

- Route création d'équipe
- Route mission (game/router)
- création de conteneurs docker pour:
  - le jeu
  - location-restriction
  - router
  - orchestrator
- Création conteneur lrid-generator
- Récupération des fonctionalités génération UUID et LRID du conteneur location-restriction
- Fichier docker-compose pour tests
- Utilisation de gunicorn dans les conteneurs docker pour performances, scalabilité et requêtes concurrentes
- Ajout redis pour éviter conflits mémoire global dans lrid-generator et location-restriction
- Amélioration de l'interface de scan (iOS) gestion des actions en fonction du point
- Page de settings avec deconnexion d'équipe
- Amélioration page d'accueil avec tableView (iOS)
- Création d'équipe (iOS)

________

## Jour 6 (2017-11-13)

- Déconnection de l'équipe dans l'application iOS
- Connexion entre le routeur et l'orchestrateur, pour créer le conteneur de jeu à l'inscription
- Le Routeur redirige la route /mission/ vers le conteneur de jeu (game)
- Utilisation du token d'équipe dans requêtes alamofire sur l'application iOS
- L'orchestrateur créé bien les conteneurs à la volée
- Utilisation redis dans container game
- Amélioration de l'expérience utilisateur (interface app iOS)

________

## Jour 7 (2017-11-14)

- Suppression de l'item gagné pour empêcher un retirage de celui-ci
- Retour visuel du raspberry pi sur une page web
- Afficher le bon nom du mode du qr_code en tête de page
- Amélioration du code iOS
  - Structure du projet
  - Utilisation des alertes simplifiées
  - Centraliser les appels à l'API
  - Expérience utilisateur
- Settings de l'app pour configurer:
  - L'adresse du routeur
  - l'adresse de l'API Location restriction
- Afficher la liste des éléments en page d'accueil (si liste) dans l'app iOS
- Réaction identique beacon/QRCode dans l'application mobile
- Calcul des points dans conteneur game (penser à utiliser redis)
- Empêcher retirage d'un objet déjà pris en photo avant
- Affichage des points sur retour visuel
