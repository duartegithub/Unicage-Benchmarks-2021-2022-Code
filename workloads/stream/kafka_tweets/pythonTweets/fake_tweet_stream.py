#!/usr/bin/python3                                                                                                      

import os
kafka = os.getenv('KAFKA_HOME')
                                                                                                                     
from kafka import KafkaProducer                                                                                         
from random import randint                                                                                              
from time import sleep                                                                                                  
import sys           
import random    
import argparse                                                      

# setting <velocity>
parser = argparse.ArgumentParser()
parser.add_argument("velocity", type=int)
args = parser.parse_args()
rate = 1/args.velocity                                       
                                                                                                                        
BROKER = 'localhost:9092'                                                                                               
TOPIC = 'tweets'                                                                                                      
                                                                                                                        
WORD_FILE = '/usr/share/dict/words'                                                                                     
WORDS = open(WORD_FILE).read().splitlines()      

weighted_choices = [('#', 1), ('', 5)]
population = [val for val, cnt in weighted_choices for i in range(cnt)]
                                                                                                                        
try:                                                                                                                    
    p = KafkaProducer(bootstrap_servers=BROKER)                                                                         
except Exception as e:                                                                                                  
    print(f"ERROR --> {e}")                                                                                             
    sys.exit(1)                                                                                                        
                                                                                                                        
while True:                                                                                                             
    message = ''                                                                                                        
    for _ in range(randint(2, 7)):                                                                                      
        message += random.choice(population) + WORDS[randint(0, len(WORDS)-1)] + ' '                                                                
    print(f">>> '{message}'")                                                                                           
    p.send(TOPIC, bytes(message, encoding="utf8"))                                                                      
    sleep(rate)
