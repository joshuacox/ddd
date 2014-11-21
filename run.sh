#/bin/sh
echo 'Starting Aegir-docker-debian'
docker run -P ddd &
sleep 5
docker ps
