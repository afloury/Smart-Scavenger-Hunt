# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import json
import requests


app = Flask(__name__)
CORS(app)


# Todo: URL paramétrable depuis ENV ?
location_restriction_server = 'http://location-restriction'


@app.route('/picture/', methods=['POST'])
def google_vision():
    raw_data = request.stream.read()

    print('Received post of length %d' % len(raw_data))

    # Todo: Router vers le bon container (docker, tout ça)
    response = requests.post('http://game/picture/', data=raw_data)
    print('Transfer to game: HTTP %d' % response.status_code)

    response_message = response.json()['message']

    # Sauvegarde dans un fichier pour debug
    yolo_file = open('picture.jpeg', 'wb')
    yolo_file.write(raw_data)
    yolo_file.close()

    return json_response(response_message)


@app.route('/team/', methods=['POST'])
def register_team():
    data = request.get_json(force=True)

    lrid = request.headers.get('X-SmartScavengerHunt-LRID')
    team_name = data['name']

    try:
        response = requests.get(location_restriction_server + '/is_valid/inscription_retrait/%s' % lrid)
    except requests.exceptions.ConnectionError:
        return json_error('Cannot connect to LR server to verify LRID validity.')

    if response.status_code != 200:
        return json_error('Internal server error when verifying LRID validity.')

    json_response = json.loads(response.content)
    if not json_response['is_valid']:
        return json_error('Vous avez mis trop de temps à entrer le nom de votre équipe.\nVeuillez ré-essayer')

    # Todo: Inscrire la team en BDD
    # Todo: Récupérer l'ID de la team en BDD ?
    # Todo: Générer un token correspondant à la team
    # Todo: Stocker ce token en BDD
    # Todo: Renvoyer le token en json
    # Todo: Envoyer l'ordre de création du container à l'orchestrator

    return json_data({
        'token': '89653832030e7d26daf3a43fc2ccd501'
    }, response_code=201)


@app.route('/mission/', methods=['GET'])
def get_mission():
    try:
        response = requests.get(location_restriction_server + '/mission/')
    except requests.exceptions.ConnectionError:
        return json_error('Cannot connect to LR server to verify LRID validity.')

    if response.status_code != 200:
        return json_error('Internal server error when verifying LRID validity.')

    json_response = json.loads(response.content)
    if not json_response['is_valid']:
        return json_error('The provided LRID is invalid.')


@app.route('/rpi-notification/', methods=['POST'])
def post_rpi_notification():
    data = request.get_json(force=True)

    print('Received win notification')
    print('    => Team: ' + data['team'])
    print('    => Item: ' + data['item'])
    print('')

    return json_response('good boy')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
