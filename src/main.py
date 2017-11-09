# coding=utf-8
from flask import Flask, request
from flask_cors import CORS
import os
import random
import uuid
import requests
from google.cloud import vision
from google.cloud.vision import types


# Initialisation Google API Vision
client = vision.ImageAnnotatorClient()

# Initialisation Flask
app = Flask(__name__)
CORS(app)


@app.route('/picture/', methods=['POST'])
def google_vision():
    raw_data = request.stream.read()
    image = types.Image(content=raw_data)

    response = client.label_detection(image=image)
    labels = response.label_annotations

    print('Labels:')
    for label in labels:
        print(label.description)
        print(label.score)
        print('')

    return 'ok'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
