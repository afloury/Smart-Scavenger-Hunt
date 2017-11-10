# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import redis
import json
from json_responses import json_data, json_error, json_response

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)


@app.route('/is_valid/<role>/<token>', methods=['GET'])
def is_token_valid(role, token):
    if role not in ['inscription_retrait', 'depot']:
        return json_response('Unknown role.')

    return json_data({
        'is_valid': token in json.loads(r.get('lrid_%s_retained' % role).decode('utf-8'))
    })


@app.route('/uuid/', methods=['GET'])
def get_uuid():
    return json_data({
        'inscription_retrait': r.get('uuid_inscription_retrait').decode('utf-8'),
        'depot': r.get('uuid_depot').decode('utf-8'),
    })


@app.route('/major-minor/<role>/', methods=['GET'])
def get_major_minor(role):
    lrid = r.get('lrid_%s_last' % role).decode('utf-8')

    return json_data({
        'uuid': r.get('uuid_%s' % role).decode('utf-8'),
        'major': lrid[0:4],
        'minor': lrid[4:8],
        'interval_secs': int(r.get('lrid_regen_token_interval_secs').decode('utf-8'))
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
