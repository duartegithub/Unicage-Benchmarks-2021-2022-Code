#!/bin/bash

rm -r project
rm -r target
sbt compile
sbt package
