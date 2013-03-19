#!/bin/sh
#
# chkconfig: 345 95 1
# Description: Nginx
# Provides: nginx
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
#
#---

# Set NGINX_BIN to be the nginx executable

NGINX_BIN=/usr/local/nginx/sbin/nginx

# Check configuration

if [ ! -f "$NGINX_BIN" ]; then
  echo "Error: $0 incorrectly configured: no NGINX_BIN: $NGINX_BIN"
  exit 1
fi

# Perform action

case "$1" in
  start)
    "$NGINX_BIN"
    exit $?
    ;;
  stop)
    "$NGINX_BIN" -s quit
    exit $?
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  status)
    ps -ef | grep -i NGINX | grep -v 'nginx status' | grep -v NGINX
    exit 1
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

#EOF
