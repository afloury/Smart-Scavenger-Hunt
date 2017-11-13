# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response
import docker

# Initialisation Flask
app = Flask(__name__)
CORS(app)

# Fixme: Virer cette ligne quand https://github.com/docker/docker-py/pull/1545 aura été mergé
client = docker.from_env()

@app.route('/')
def increment():
    return 'Hello world, this is the orchestrator!'


@app.route('/create/', methods=['POST'])
def create_container():
    data = request.get_json(force=True)

    container_name = 'smart-scavenger-hunt-game-' + data['team_uuid']

    client.containers.run(
        image='smart-scavenger-hunt:game',
        auto_remove=True,
        remove=True,
        name=container_name,
        detach=True,
        network='smart-scavenger-hunt',
        environment={
            'TEAM_UUID': data['team_uuid']
        }
    )

    return json_data({
        'container_name': container_name
    }, 201)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
