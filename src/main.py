# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
from json_responses import json_data, json_error, json_response

# Initialisation Flask
app = Flask(__name__)
CORS(app)


@app.route('/')
def increment():
    return 'Hello world, this is the orchestrator!'


@app.route('/hello/', methods=['GET'])
def create_container():
    return json_data({
        'message': 'Salut mec !'
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True)
