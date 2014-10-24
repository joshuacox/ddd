#/bin/sh
docker run -t -i -P ddd /bin/bash &
ADDRESS=$(docker port $(docker ps -q) 80)
echo "http://$ADDRESS"
#chromium "$ADDRESS" &
