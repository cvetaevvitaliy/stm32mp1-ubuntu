#! /bin/bash

sudo growpart /dev/mmcblk0 4
sudo resize2fs /dev/mmcblk0p4
df -h
