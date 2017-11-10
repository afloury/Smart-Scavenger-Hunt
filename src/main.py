import redis
import uuid
import copy
import time
from token_generator import TokenGenerator

# Todo: Rendre configurable le serveur redis depuis ENV ?
r = redis.StrictRedis(host='redis', port=6379, db=0)

# Génération des UUIDs
uuids = {
    'inscription_retrait': None,
    'depot': None
}

token_generators = copy.copy(uuids)
regen_token_interval_secs = 3
token_validity_secs = 45

r.set('lrid_regen_token_interval_secs', str(regen_token_interval_secs).encode('utf-8'))

for key, value in uuids.items():
    uuids[key] = uuid.uuid4().hex
    uuids[key] = uuids[key][0:8] + '-' + uuids[key][8:12] + '-' + uuids[key][12:16] + '-' + uuids[key][16:20] + '-' + uuids[key][20:32]

    r.set('uuid_%s' % key, uuids[key].encode('utf-8'))

    token_generators[key] = TokenGenerator(
        redis=r,
        redis_key_name='lrid_%s' % key,
        interval_secs=regen_token_interval_secs,
        retain=int(token_validity_secs / regen_token_interval_secs)
    )
    token_generators[key].start()

while True:
    time.sleep(60)
