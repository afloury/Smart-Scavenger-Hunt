# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import json
import redis

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)


@app.route('/score/', methods=['GET'])
def create_container():
    raw_teams = r.get('teams')
    if raw_teams is None:
        return json_data([])

    scores = []
    for team_uuid in json.loads(raw_teams.decode('utf-8')):
        team_data = json.loads(r.get('team-' + team_uuid).decode('utf-8'))
        scores += [{
            'name': team_data['name'],
            'score': team_data['score']
        }]

    return json_data(scores)

    # Trier du plus grand au plus petit
    scores.sort(key=lambda x: x['score'], reverse=True)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
