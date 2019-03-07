#!/bin/bash
docker run --name nginx_proxy -d -v `pwd`:/etc/nginx/conf.d -p 443:443 nginx
