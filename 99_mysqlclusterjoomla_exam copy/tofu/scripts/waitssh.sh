#!/bin/bash

echo "Waiting ssh to launch on 22..."
while ! nc -z $1 22; do
  sleep 5 # wait for 1 of the second before check again
  echo "Waiting ssh..."
done
echo "SSH launched"