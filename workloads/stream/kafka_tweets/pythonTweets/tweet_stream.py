#!/usr/bin/python3 

import os
kafka = os.getenv('KAFKA_HOME')

from kafka import KafkaProducer
from datetime import datetime
import secret_config as conf ## where I put my Twitter API keys
import tweepy
import sys
import re

TWEET_TOPICS = ['pizza']

KAFKA_BROKER = 'localhost:9092'
KAFKA_TOPIC = 'tweets'

# put your API keys here
consumer_key = conf.consumer_key
consumer_secret = conf.consumer_secret_key

access_token = conf.access_token
access_token_secret = conf.access_token_secret

class Streamer(tweepy.Stream):

    def on_error(self, status_code):
        if status_code == 402:
            return False

    def on_status(self, status):
        tweet = status.text

        tweet = re.sub(r'RT\s@\w*:\s', '', tweet)
        tweet = re.sub(r'https?.*', '', tweet)

        global producer
        producer.send(KAFKA_TOPIC, bytes(tweet, encoding='utf-8'))

        d = datetime.now()

        print(f'[{d.hour}:{d.minute}.{d.second}] sending tweet')

streamer = Streamer(consumer_key, consumer_secret, access_token, access_token_secret)

try:
    producer = KafkaProducer(bootstrap_servers=KAFKA_BROKER)
except Exception as e:
    print(f'Error Connecting to Kafka --> {e}')
    sys.exit(1)

streamer.filter(track=TWEET_TOPICS)
