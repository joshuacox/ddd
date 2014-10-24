#/bin/sh
sudo echo 'Build'
/usr/bin/time -v sudo docker build -t ddd . 
aplay /usr/share/sounds/alsa/Front_Center.wav
