from threading import Thread
import time
import random
import json


class TokenGenerator(Thread):
    def __init__(self, redis, redis_key_name, interval_secs=5, retain=3, length=8, allowed_characters=None):
        Thread.__init__(self)
        self.redis = redis
        self.redis_key_name = redis_key_name
        self.allowed_characters = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'] if allowed_characters is None else allowed_characters
        self.interval_secs = interval_secs
        self.retain = retain
        self.length = length
        self.token = self.gen_random_token()
        self.retained = [None] * self.retain
        self.redis.set(self.redis_key_name + '_last', self.token.encode('utf-8'))
        self.redis.set(self.redis_key_name + '_retained', json.dumps(self.retained).encode('utf-8'))

    def gen_random_token(self):
        return ''.join([random.choice(self.allowed_characters) for _ in range(self.length)])

    def run(self):
        while True:
            self.token = self.gen_random_token()
            for i in range(self.retain-1):
                self.retained[i] = self.retained[i+1]
            self.retained[self.retain-1] = self.token
            self.redis.set(self.redis_key_name + '_last', self.token.encode('utf-8'))
            self.redis.set(self.redis_key_name + '_retained', json.dumps(self.retained).encode('utf-8'))

            time.sleep(self.interval_secs)
