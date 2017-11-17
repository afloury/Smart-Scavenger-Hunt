import random

things = [
    'chair',
    'furniture',
    'couch',
    'table',
    'computer',
    'technology',
    'mobile phone',
    'car',
    'bicycle',
    'wheel',
    'pen',
    'hand',
    'finger',
    'tree',
    'sky',
    'grass',
    'apple',
    'banana',
    'fruit',
    'paper',
    'clock',
    'aluminum can',
    'fork',
    'knife',
    'computer keyboard',
    'refrigerator',
    'screw',
    'door',
    'toilet',
    'flower',
    'headphones',
    'floor',
    'spoon',
    'mug',
    'cup'
]


def gen_mission(nb):
    return random.sample(things, nb)


def remove_item(item):
    if item in things:
        things.remove(item)
