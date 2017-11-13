# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import json
import requests
import uuid
import redis


app = Flask(__name__)
CORS(app)

# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)

# Todo: URL paramétrable depuis ENV ?
location_restriction_server = 'http://location-restriction'
orchestrator_server = 'http://orchestrator'
copied_headers = ['X-SmartScavengerHunt-LRID', 'Content-Type']


def routing_to_container(method, route):
    # Obtention des infos de l'équipe
    if 'Authentication' not in request.headers:
        return json_error('HTTP header Authentication should be set to access this route.')

    team_token = request.headers['Authentication']

    if r.get('teams') is None or team_token not in json.loads(r.get('teams').decode('utf-8')):
        return json_error('Unknown team token!', 404)

    team_data = json.loads(r.get('team-%s' % team_token).decode('utf-8'))
    container_url = 'http://' + team_data['container']

    # Requête routeur => game
    request_headers = {}
    for copied_header in copied_headers:
        if copied_header in request.headers:
            request_headers[copied_header] = request.headers[copied_header]

    try:
        response = requests.request(
            method=method,
            url=container_url + route,
            data=request.stream.read(),
            headers=request_headers
        )
    except requests.exceptions.ConnectionError:
        return json_error('Impossible de contacter le container de jeu.')

    # Réponse routeur => iOS
    response_headers = {}
    for copied_header in ['X-SmartScavengerHunt-LRID', 'Content-Type']:
        if copied_header in response.headers:
            response_headers[copied_header] = response.headers[copied_header]

    return response.content, response.status_code, response_headers


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
    # Lecture JSON et headers HTTP
    data = request.get_json(force=True)

    lrid = request.headers.get('X-SmartScavengerHunt-LRID')
    team_name = data['name']

    # Vérification du LRID (jeton éphémère)
    try:
        lrid_check_response = requests.get(location_restriction_server + '/is_valid/inscription_retrait/%s' % lrid)
    except requests.exceptions.ConnectionError:
        return json_error('Cannot connect to LR server to verify LRID validity.')

    if lrid_check_response.status_code != 200:
        return json_error('Internal server error when verifying LRID validity.')

    json_response = json.loads(lrid_check_response.content)
    if not json_response['is_valid']:
        return json_error('Vous avez mis trop de temps à entrer le nom de votre équipe.\nVeuillez ré-essayer')

    # Génération de l'équipe
    team_uuid = str(uuid.uuid4())

    try:
        create_response = requests.post(orchestrator_server + '/create/', json={
            'team_uuid': team_uuid
        })
    except requests.exceptions.ConnectionError:
        return json_error('Impossible de contacter l\'orchestrateur.')

    if create_response.status_code != 201:
        return json_error('Erreur lors de la création du conteneur Docker du jeu.')

    create_response_data = json.loads(create_response.content)

    r.set('team-' + team_uuid, json.dumps({
        'name': team_name,
        'container': create_response_data['container_name']
    }).encode('utf-8'))

    # Inscription de l'équipe avec lock au cas-où
    lock_teams = r.lock('lock_teams')
    lock_teams.acquire(True)

    if r.get('teams') is None:
        teams = [team_uuid]
    else:
        teams = json.loads(r.get('teams').decode('utf-8'))
        teams += [team_uuid]

    r.set('teams', json.dumps(teams).encode('utf-8'))

    lock_teams.release()

    return json_data({
        'token': team_uuid
    }, response_code=201)


@app.route('/mission/', methods=['GET'])
def get_mission():
    return routing_to_container('get', '/mission/')


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
