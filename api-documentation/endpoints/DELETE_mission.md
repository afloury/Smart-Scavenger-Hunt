# Mission

    DELETE /mission

## Description
Abandon de la mission en cours.

***

## Todo: authentication
**Token QR-Code ?**

***

## Format des données retournées
**HTTP 204 NO CONTENT**

***

## Erreurs
- **403 Forbidden** — Erreur d'authentification via le tocken QR-Code.

***

## Exemple
**Request**

    DELETE /mission

**Return**
**HTTP 204 NO CONTENT**
