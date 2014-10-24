#/bin/sh
sudo docker run -t -i -P ddd /bin/bash &
ADDRESS=$(sudo docker port $(sudo docker ps -q) 80)
echo "http://$ADDRESS"
#chromium "$ADDRESS" &
