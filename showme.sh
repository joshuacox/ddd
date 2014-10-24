#/bin/sh
echo 'List of Containers with ports'
sleep 1
ADDRESS=$(docker ps -q|sort |xargs -n1 -I '{}' docker port {} 80)
for i in $ADDRESS; do echo "http://$i"; chromium $i & done
