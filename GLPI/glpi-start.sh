#!/bin/bash

/usr/sbin/service cron start
#/usr/sbin/service apache2 start
/usr/sbin/apache2ctl -D FOREGROUND