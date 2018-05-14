#!/bin/bash
# script to update HASS repository

sudo git add .
sudo git commit -m $1
sudo git push 

