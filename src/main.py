# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import google_things
import requests
import redis
import os
import json
from json_responses import json_data, json_error, json_response
from google.cloud import vision
from google.cloud.vision import types


# Initialisation Google API Vision
client = vision.ImageAnnotatorClient()

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Configuration jeu
points_won = 5
points_lost = -1
points_giveup = -2



# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)

# Todo: URL paramétrable depuis ENV ?
router_server = 'http://router'


nb_items_per_mission = 5  # Todo: rendre ça configurable via variable d'environnement ?
current_mission = None


def get_or_create_mission():
    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))

    if 'mission' not in team_data:
        team_data['mission'] = google_things.gen_mission(nb_items_per_mission)
        r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

    return team_data['mission']


@app.route('/picture/', methods=['POST'])
def google_vision():
    raw_data = request.stream.read()
    image = types.Image(content=raw_data)

    response = client.label_detection(image=image)
    labels = response.label_annotations

    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))
    current_mission = get_or_create_mission()

    winning_label = None
    for label in labels:
        for item in current_mission:
            if label.score > 0.82 and item.lower() in label.description.lower():
                winning_label = label.description

                current_mission.remove(item)  # Todo: Après avoir réussi un item de la mission, remove ou reset ?
                google_things.remove_item(item)  # Supprimer l'item pour ne plus l'avoir lors des prochains tirages
                print('WIN WITH %s' % label.description)

                team_data['mission'] = current_mission
                r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

                break

    new_score = set_score(points_lost if winning_label is None else points_won, True)
    response = requests.post(router_server + '/rpi-notification/', json={
        'team': team_data['name'],
        'message': 'You lost.' if winning_label is None else ('You won with : \'%s\'' % winning_label),
        'has_won': winning_label is not None,
        'points': new_score
    })

    if response.status_code != 200:
        return json_error('Le routeur erreur lors de contact de la route /rpi-notification/ pour callback retour visuel.')

    return json_response('Photo reçue avec succès.')


@app.route('/mission/', methods=['GET'])
def get_mission():
    return json_data(get_or_create_mission())


def set_score(score, apply_delta=False):
    lock_current_team = r.lock('team-' + os.environ['TEAM_UUID'] + '_lock')
    lock_current_team.acquire(True)

    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))
    if 'score' not in team_data:
        team_data['score'] = 0
    team_data['score'] = (team_data['score'] + score) if apply_delta else score
    r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

    lock_current_team.release()

    return team_data['score']

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
