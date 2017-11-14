# coding=utf-8
from ibeacon import ibeacon
import time
import requests
import json
import os

location_restriction_server_url = 'http://192.168.2.1:5002'  # Todo: Mettre ça en variable d'environnement

allowed_beacon_mode = ['inscription_retrait', 'depot']
if 'SMART_SCAVENGER_HUNT_BEACON_MODE' not in os.environ:
    print('Environment variable SMART_SCAVENGER_HUNT_BEACON_MODE should be set to %s but is not set.' % str(allowed_beacon_mode))
    exit(1)

beacon_mode = os.environ['SMART_SCAVENGER_HUNT_BEACON_MODE']
if beacon_mode not in allowed_beacon_mode:
    print('Environment variable SMART_SCAVENGER_HUNT_BEACON_MODE should be set to %s but got \'%s\' instead.' % (str(allowed_beacon_mode), beacon_mode))
    exit(1)

ibeacon.init()
sleep_time = 2
while True:
    global beacon_mode
    try:
        response = requests.get(location_restriction_server_url + '/major-minor/%s/' % beacon_mode)
    except requests.exceptions.ConnectionError:
        time.sleep(2)
        continue

    if response.status_code == 200:
        json_data = json.loads(response.content)

        print('%s / %s / %s' % (json_data['uuid'], json_data['major'], json_data['minor']))
        print('\n\n\n')

        ibeacon.set_config(json_data['uuid'], json_data['major'], json_data['minor'])
        sleep_time = json_data['interval_secs']

    else:
        print('Response code isn\'t 200! Got %d' % response.status_code)

    time.sleep(sleep_time / 4.0)

