#!/bin/bash
# script to update HASS repository

sudo git add .
sudo git status
echo -n "Enter the Description for the change: " [Minor Update]
read CHANGE_MSG
sudo git commit -m "${CHANGE_MSG}"
sudo git push 

