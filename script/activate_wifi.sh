#! /bin/bash

sudo apt update
sudo apt install rfkill -y
sudo rfkill list all
sudo rfkill unblock all
sudo ifconfig wlan0 up
ifconfig
