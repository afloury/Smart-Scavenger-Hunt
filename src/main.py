# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import os
import random
import uuid
import requests
from json_responses import json_data, json_error, json_response
from token_generator import TokenGenerator
import copy

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Génération des UUIDs
uuids = {
    'inscription_retrait': None,
    'depot': None
}

token_generators = copy.copy(uuids)
regen_token_interval_secs = 3
token_validity_secs = 30

for key, value in uuids.items():
    uuids[key] = uuid.uuid4().hex
    uuids[key] = uuids[key][0:8] + '-' + uuids[key][8:12] + '-' + uuids[key][12:16] + '-' + uuids[key][16:20] + '-' + uuids[key][20:32]

    token_generators[key] = TokenGenerator(
        interval_secs=regen_token_interval_secs,
        retain=int(token_validity_secs / regen_token_interval_secs)
    )
    token_generators[key].start()

print(uuids)

uuids['inscription_retrait'] = '483892bf-2d2a-4cd6-8fd9-311779cb5153'


@app.route('/is_valid/<role>/<token>', methods=['GET'])
def is_token_valid(role, token):
    if role not in uuids:
        return json_response('Unknown role.')

    return json_data({
        'is_valid': token_generators[role].is_valid(token)
    })


@app.route('/uuid/', methods=['GET'])
def get_uuid():
    return json_data(uuids)


@app.route('/major-minor/<role>/', methods=['GET'])
def get_major_minor(role):
    return json_data({
        'uuid': uuids[role],
        'major': token_generators[role].token[0:4],
        'minor': token_generators[role].token[4:8],
        'interval_secs': regen_token_interval_secs
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
