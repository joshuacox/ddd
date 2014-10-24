#/bin/sh
sudo echo 'List of Containers with ports'
sleep 1
ADDRESS=$(sudo docker ps -q|sort |xargs -n1 -I '{}' '/usr/bin/sudo' docker port {} 80)
for i in $ADDRESS; do echo "http://$i"; chromium $i & done
