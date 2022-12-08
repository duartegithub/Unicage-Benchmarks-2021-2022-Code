#!/bin/bash

basedir=$(dirname "$(readlink -f "$0")")
cd $basedir

rm -r project
rm -r target
sbt compile
sbt package
