# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import google_things
import requests
import redis
import os
import json
import uuid
from json_responses import json_data, json_error, json_response
from google.cloud import vision
from google.cloud.vision import types


# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Configuration jeu
points_won = 3
points_lost = -2
points_giveup = -3


# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)

# Todo: URL paramétrable depuis ENV ?
location_restriction_server = 'http://location-restriction'
router_server = 'http://router'


nb_items_per_mission = 5  # Todo: rendre ça configurable via variable d'environnement ?
current_mission = None


def get_or_create_mission(force=False, force_nb_items=None):
    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))

    if force or 'mission' not in team_data:
        team_data['mission'] = google_things.gen_mission(nb_items_per_mission if force_nb_items is None else force_nb_items)
        r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

    return team_data['mission']


@app.route('/picture/', methods=['GET'])
def get_pictures():
    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))
    return json_data(team_data['pictures'])


@app.route('/picture/<picture_uuid>/', methods=['GET'])
def get_picture_from_uuid(picture_uuid):
    picture_path = 'pictures/%s.jpg' % picture_uuid

    if not os.path.isfile(picture_path):
        return json_error('Unknown file', 404)

    with open(picture_path, 'rb') as picture_file:
        file_content = picture_file.read()

    return file_content, 200, {
        'Content-Type': 'image/jpeg'
    }


@app.route('/picture/', methods=['POST'])
def google_vision():
    # Préparation des données
    raw_data = request.stream.read()
    image = types.Image(content=raw_data)

    client = vision.ImageAnnotatorClient()
    response = client.label_detection(image=image)
    labels = response.label_annotations

    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))
    current_mission = get_or_create_mission()

    # Vérification du LRID (token éphémère)
    lrid = request.headers.get('X-SmartScavengerHunt-LRID')
    lrid_trolol_detected = lrid == 'trolol'
    if not lrid_trolol_detected:
        try:
            lrid_check_response = requests.get(location_restriction_server + '/is_valid/depot/%s' % lrid)
        except requests.exceptions.ConnectionError:
            return json_error('Cannot connect to LR server to verify LRID validity.')

        if lrid_check_response.status_code != 200:
            return json_error('Internal server error when verifying LRID validity.')

        lrid_check_response = json.loads(lrid_check_response.content)
        if not lrid_check_response['is_valid']:
            return json_error('Erreur de token éphémère, veuillez re-essayer.')

    # Vérification photo gagnante
    winning_label = None
    normalized_labels = []
    for label in labels:
        normalized_labels += [{
            'label': label.description,
            'score': label.score
        }]

        for item in current_mission:
            if label.score > 0.66 and item.lower() in label.description.lower():
                winning_label = label.description

                # Todo: Après avoir réussi un item de la mission, remove ou reset ?
                google_things.remove_item(item)  # Supprimer l'item pour ne plus l'avoir lors des prochains tirages
                print('WIN WITH %s' % label.description)

                team_data['mission'] = google_things.gen_mission(nb_items_per_mission)
                r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

                break

    # Enregistrement données photo dans redis
    picture_uuid = str(uuid.uuid4().hex)
    team_data['pictures'] += [{
        'picture_uuid': picture_uuid,
        'labels': normalized_labels,
        'position': {
            'lat': request.headers.get('X-SmartScavengerHunt-lat'),
            'long': request.headers.get('X-SmartScavengerHunt-long')
        },
        'winning_label': winning_label
    }]
    r.set('team-' + os.environ['TEAM_UUID'], json.dumps(team_data).encode('utf-8'))

    # Écriture photo sur le disque
    picture_file = open('pictures/%s.jpg' % picture_uuid, 'wb')
    picture_file.write(raw_data)
    picture_file.close()

    # Prévenir router pour retour visuel raspberry pi
    new_score = set_score(points_lost if winning_label is None else points_won, True)
    response = requests.post(router_server + '/rpi-notification/', json={
        'team': team_data['name'],
        'message': 'You lost.' if winning_label is None else ('You won with : \'%s\'' % winning_label),
        'has_won': winning_label is not None,
        'score': new_score
    })

    if response.status_code != 200:
        return json_error('Le routeur erreur lors de contact de la route /rpi-notification/ pour callback retour visuel.')

    return json_response('TROLOL HEHE' if lrid_trolol_detected else 'Photo reçue avec succès.')


@app.route('/mission/', methods=['GET'])
def get_mission():
    return json_data(get_or_create_mission())


@app.route('/mission/', methods=['DELETE'])
def delete_mission():
    team_data = json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8'))

    get_or_create_mission(True, len(team_data['mission']))

    new_score = set_score(points_giveup, True)

    response = requests.post(router_server + '/rpi-notification/', json={
        'team': team_data['name'],
        'message': 'You gave up the mission.',
        'has_won': False,
        'score': new_score
    })

    if response.status_code != 200:
        return json_error('Le routeur erreur lors de contact de la route /rpi-notification/ pour callback retour visuel.')

    return '', 204


@app.route('/get_team_data/', methods=['GET'])
def get_team_data():
    return json_data(json.loads(r.get('team-' + os.environ['TEAM_UUID']).decode('utf-8')))


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
