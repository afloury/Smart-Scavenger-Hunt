# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import os
import random
import uuid
import json
import requests


app = Flask(__name__)
CORS(app)


# Todo: URL paramétrable
location_restriction_server = 'http://127.0.0.1:5002'


@app.route('/picture/', methods=['POST'])
def google_vision():
    raw_data = request.stream.read()

    print('Received post of length %d' % len(raw_data))

    # Todo: Router vers le bon container (docker, tout ça)
    response = requests.post('http://127.0.0.1:5000/picture/', data=raw_data)
    print('Transfer to game: HTTP %d' % response.status_code)

    # Sauvegarde dans un fichier pour debug
    yolo_file = open('picture.jpeg', 'wb')
    yolo_file.write(raw_data)
    yolo_file.close()

    return json_response('Ça marche pas mais j\'ai pas envie de te dire pourqoi')


@app.route('/team/', methods=['POST'])
def register_team(lrid, team_name):
    data = request.get_json(force=True)

    lrid = data['lrid']
    team_name = data['name']

    # Todo: URL paramétrable
    try:
        response = requests.get(location_restriction_server + '/is_valid/inscription_retrait/%s' % lrid)
    except requests.exceptions.ConnectionError:
        return json_error('Cannot connect to LR server to verify LRID validity.')

    if response.status_code != 200:
        return json_error('Internal server error when verifying LRID validity.')

    json_response = json.loads(response.content)
    if not json_response['is_valid']:
        return json_error('The provided LRID is invalid.')

    # Todo: Inscrire la team en BDD
    # Todo: Récupérer l'ID de la team en BDD ?
    # Todo: Générer un token correspondant à la team
    # Todo: Stocker ce token en BDD
    # Todo: Renvoyer le token en json
    # Todo: Envoyer l'ordre de création du container à l'orchestrator

    return json_data({
        'token': '89653832030e7d26daf3a43fc2ccd501'
    }, response_code=201)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
