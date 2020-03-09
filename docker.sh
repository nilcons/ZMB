#!/bin/bash

docker run -it -e MYSQL_ROOT_PASSWORD=zmb --ip 172.17.0.2 mysql:5.7
