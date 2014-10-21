#/bin/sh
# make an ascii art logo from DDD.jpg
jp2a -i --chars='  DDdd' -b --height=20 DDD.jpg | tee ddd.txt
