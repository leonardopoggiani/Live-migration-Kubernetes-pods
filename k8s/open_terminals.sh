#!/bin/bash

echo "Starting terminals with ssh connections.."
alacritty -e ssh "ubuntu@172.16.5.183" &
alacritty -e ssh "ubuntu@172.16.3.23" &
alacritty -e ssh "ubuntu@172.16.5.119" &
alacritty -e ssh "ubuntu@172.16.3.19" &


