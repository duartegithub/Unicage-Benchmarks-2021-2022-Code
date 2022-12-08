#!/bin/bash

# Generating command: ./genData-windowed_wordcount.sh
  
echo "(1) fake or (2) real tweets?"
while [ true ] ; do
  read -p "> " tweet_type
  if [ $tweet_type == 1 ] || [ $tweet_type == 2 ]
  then
    break
  else
    echo "(1) OR (2)"
  fi
done

if [ $tweet_type == 1 ]
then
  echo "FAKE tweets incoming."
  echo "With FAKE tweets, it's possible to choose a <velocity> tweets/s:"
  read -p "> " velocity
  python3 ./pythonTweets/fake_tweet_stream.py $velocity
else 
  echo "REAL tweets incoming."
  python3 ./pythonTweets/tweet_stream.py
fi

# generate input data

