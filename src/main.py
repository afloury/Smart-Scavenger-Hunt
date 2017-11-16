# coding=utf-8
from flask import Flask, request, make_response
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import json
import redis
import requests

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)

copied_headers = ['X-SmartScavengerHunt-LRID', 'Content-Type', 'X-SmartScavengerHunt-lat', 'X-SmartScavengerHunt-long']


def routing_to_game(method, route, team_token=None):
    if team_token is None:
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
    headers = {}
    for copied_header in copied_headers:
        if copied_header in response.headers:
            headers[copied_header] = response.headers[copied_header]

    return response.content, response.status_code, headers


@app.route('/score/', methods=['GET'])
def create_container():
    raw_teams = r.get('teams')
    if raw_teams is None:
        return json_data([])

    scores = []
    for team_uuid in json.loads(raw_teams.decode('utf-8')):
        team_data = json.loads(r.get('team-' + team_uuid).decode('utf-8'))
        scores += [{
            'uuid': team_uuid,
            'name': team_data['name'],
            'score': team_data['score']
        }]

    # Trier du plus grand au plus petit
    scores.sort(key=lambda x: x['score'], reverse=True)

    return json_data(scores)


@app.route('/team/', methods=['GET'])
def get_teams():
    raw_teams = r.get('teams')
    if raw_teams is None:
        return json_data([])

    teams = []
    for team_uuid in json.loads(raw_teams.decode('utf-8')):
        team_data = json.loads(r.get('team-' + team_uuid).decode('utf-8'))
        teams += [{
            'uuid': team_uuid,
            'name': team_data['name']
        }]

    return json_data(teams)


@app.route('/team/<team_uuid>/picture/', methods=['GET'])
def get_team_pictures(team_uuid):
    return routing_to_game('get', '/picture/', team_uuid)


@app.route('/team/<team_uuid>/picture/<picture_uuid>/', methods=['GET'])
def get_team_picture_from_uuid(team_uuid, picture_uuid):
    return routing_to_game('get', '/picture/%s/' % picture_uuid, team_uuid)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
