# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import google_things
import requests
from json_responses import json_data, json_error, json_response
from google.cloud import vision
from google.cloud.vision import types


# Initialisation Google API Vision
client = vision.ImageAnnotatorClient()

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Todo: URL paramétrable
router_server = 'http://127.0.0.1:5001'

# Todo: récupérer token équipe depuis ENV lors du démarrage du container
token_equipe = '89653832030e7d26daf3a43fc2ccd501'
nom_equipe = 'Équipe des gens cools'


nb_items_per_mission = 5  # Todo: rendre ça configurable via variable d'environnement ?
current_mission = ['chair', 'apple']  # google_things.gen_mission(nb_items_per_mission)
print(current_mission)


@app.route('/picture/', methods=['POST'])
def google_vision():
    raw_data = request.stream.read()
    image = types.Image(content=raw_data)

    response = client.label_detection(image=image)
    labels = response.label_annotations

    for label in labels:
        print(label.description)
        print(label.score)
        print('')

        for item in current_mission:
            if label.score > 0.82 and item.lower() in label.description.lower():
                current_mission.remove(item)
                print('WIN WITH %s' % label.description)

                #response = requests.post(router_server + '/rpi-notification/', json={
                #    'team': nom_equipe,
                #    'item': label.description
                #})

                print(response.status_code)
                print(response.content)

                return 'ok'

    return 'fail'


@app.route('/mission/', methods=['GET'])
def get_mission():
    return json_data(current_mission)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
