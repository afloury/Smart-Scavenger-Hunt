# coding=utf-8
from flask import Flask, request
from flask_cors import CORS

# Initialisation Flask
app = Flask(__name__)
CORS(app)


@app.route('/')
def increment():
    return 'Hello world, this is the orchestrator!'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
