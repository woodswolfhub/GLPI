#!/bin/bash

/usr/sbin/service cron start
/usr/sbin/apache2ctl -D FOREGROUND
