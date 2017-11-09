import os
from subprocess import call

# Constantes
_DEFAULT_BLUETOOTH_DEVICE = 'hci0'

# Configuration changeante
bluetooth_device = _DEFAULT_BLUETOOTH_DEVICE

beacon_uuid = None


def init():
    #call(['hciconfig', bluetooth_device, 'up'])
    #call(['hciconfig', bluetooth_device, 'leadv', '0'])
    pass


def set_bluetooth_device(device):
    global bluetooth_device
    bluetooth_device = device


def set_config(uuid, major, minor, power='e9'):
    global beacon_uuid
    uuid = uuid.replace(' ', '').replace('-', '')

    if len(uuid) != 32:
        print('uuid length is invalid, should be 32, is %d' % len(uuid))
        return

    beacon_uuid = [uuid[i:i+2] for i in range(0, len(uuid), 2)]

    if beacon_uuid is None:
        print('Please init iBeacon with init_ibeacon function')
        return

    major = major.replace(' ', '').replace('-', '')
    minor = minor.replace(' ', '').replace('-', '')

    if len(major) != 4:
        print('major length is invalid, should be 4, is %d' % len(major))
        return

    if len(minor) != 4:
        print('minor length is invalid, should be 4, is %d' % len(minor))
        return

    major = [major[i:i+2] for i in range(0, len(major), 2)]
    minor = [minor[i:i+2] for i in range(0, len(minor), 2)]

    global bluetooth_device
    command = ['hcitool']
    command += ['-i', bluetooth_device]
    command += ['cmd', '0x08', '0x0008']
    command += ['1e', '02', '01', '1a', '1a', 'ff', '4c', '00', '02', '15']
    command += beacon_uuid
    command += major
    command += minor
    command += ['e9', '00']

    call(['hciconfig', bluetooth_device, 'noleadv'])
    call(command)
    call(['hciconfig', bluetooth_device, 'leadv', '0'])
