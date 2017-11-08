
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
- Hébergement d'un iBeacon sur Raspberry Pi
- Transmission d'un major/minor arbitraire depuis iBeacon sur Raspberry Pi
- Récupération du major/minor dans iBeacon iOS
- Inscription et tests de communication Google Cloud Vision API
- Code de base pour le routeur
- Transfert dépôts séparés vers branches
