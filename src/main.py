# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import os
import random
import uuid
import requests


app = Flask(__name__)
CORS(app)


@app.route('/hello/', methods=['GET'])
def list_all_nodes():
    return 'salut'


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
