#!/bin/sh
#
# chkconfig: 345 90 1
# Description: Bluepill loader for Thales
# Provides: thales
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
#
# Based on https://github.com/opscode-cookbooks/bluepill script.

# Set BLUEPILL_BIN to the Bluepill program (or leave empty to
# find bluepill on the PATH). If using RVM, this should be the
# wrapper script created for Bluepill.

BLUEPILL_BIN="/home/thales/.rvm/bin/thales_bluepill"

# Set BLUEPILL_CONFIG to the Bluepill configuration file.

BLUEPILL_CONFIG="/home/thales/thales/config/bluepill.pill"

SERVICE_NAME=thales # This MUST match the application name in BLUEPILL_CONFIG

#---
# Check configuration

if [ -n "$BLUEPILL_BIN" ]; then
  if [ ! -f "$BLUEPILL_BIN" ]; then
    echo "Error: $0 incorrectly configured: no BLUEPILL_BIN: $BLUEPILL_BIN"
    exit 1
  fi
else
  # Attempt to find bluepill in path
  BLUEPILL_BIN=`which bluepill 2>/dev/null`
  if [ ! -f "$BLUEPILL_BIN" ]; then
    echo "Error: $0 incorrectly configured: BLUEPILL_BIN not set"
    exit 1
  fi
fi

if [ ! -f "$BLUEPILL_CONFIG" ]; then
  echo "Error: $0 incorrectly configured: no BLUEPILL_CONFIG: $BLUEPILL_CONFIG"
  exit 1
fi

# Perform action

case "$1" in
  start)
    $BLUEPILL_BIN load $BLUEPILL_CONFIG
    exit $?
    ;;
  stop)
    $BLUEPILL_BIN $SERVICE_NAME stop
    $BLUEPILL_BIN $SERVICE_NAME quit
    exit $?
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  status)
    $BLUEPILL_BIN $SERVICE_NAME status
    exit $?
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
