# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import os
import random
import uuid
import requests


app = Flask(__name__)
CORS(app)


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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
