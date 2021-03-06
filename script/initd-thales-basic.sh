#!/bin/bash
#
# chkconfig: 345 90 1
# Description: Thales
# Provides: thales
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
#

# Set PROJ_DIR to the directory where the Thales project sources are installed.

PROJ_DIR="/home/thales/thales"

# Set UNICORN to the Unicorn program. If using RVM, this will be the wrapper
# script that was created for Unicorn.

UNICORN="/home/thales/.rvm/bin/thales_unicorn" 

# Set PID_FILE to path of PID file configured into "config/unicorn.rb".
# The PID file is created by Unicorn, and this script uses it to stop
# and obtain the status of the running process.

PID_FILE="$PROJ_DIR/tmp/pids/unicorn.pid"

# Port to run Unicorn server on.
# Since a proxy server (e.g. nginx) will be used, this just needs to be
# an unused port that is not accessible from outside the host. It should be
# different from the development server port, so testing and development
# can occur at the same time as this server is running.

PORT=30123

ENVIRONMENT=production

#---
# Checking configuration

if [ "$PROJ_DIR" ]; then
  if [ ! -d "$PROJ_DIR" ]; then
    echo "Error: $0 configured incorrectly: PROJ_DIR no dir: $PROJ_DIR" >&2
    exit 1
  fi
else
  # Assume script is still in the script subdirectory of the project directory
  cd "`dirname $0`/.." || exit 1
  if [ ! \( -d app -a -d lib/thales \) ]; then
    echo "Error: $0 configured incorrectly: PROJ_DIR not set" >&2
    exit 1
  fi
  PROJ_DIR=`pwd`
fi

if [ ! -f "$UNICORN" ]; then
  echo "Error: $0 configured incorrectly: UNICORN does not exist: $UNICORN"
  exit 1
fi

# Change working directory to project directory

cd "$PROJ_DIR"
if [ $? -ne 0 ]; then exit 1; fi

case "$1" in
  start)
    # Prevent start if already running
    if [ -f "$PID_FILE" ]; then
      ps -p `cat "$PID_FILE"` > /dev/null
      if [ $? -eq 0 ]; then
        echo "Error: Thales is already running." >&2
        exit 1
      fi
    fi

    # Create directory for PID file (if it does not exist)
    PID_DIR=`dirname "$PID_FILE"`
    if [ ! -d "$PID_DIR" ]; then
      mkdir -p "$PID_DIR"
      if [ $? -ne 0 ]; then exit 1; fi
    fi

    "$UNICORN" -c config/unicorn.rb -E $ENVIRONMENT -p $PORT &
    ;;

  stop)
    if [ -f "$PID_FILE" ]; then
      PID=`cat "$PID_FILE"`
      /usr/bin/kill -s SIGQUIT $PID
      rm -f "$PID_FILE"
    else
      echo "Warning: no PID file ($PID_FILE): not running?"
    fi
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  status)
    if [ -f "$PID_FILE" ]; then
      ps -p `cat "$PID_FILE"` > /dev/null
      if [ $? -eq 0 ]; then
        echo "Thales: running"
      else
        echo "Thales: not running (was not cleanly stopped)"
      fi
    else
      echo "Thales: not running"
    fi
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0

#EOF
