#!/bin/bash

mysqldump --skip-extended-insert -h 172.17.0.2 -uroot -p zmb >data.sql 
