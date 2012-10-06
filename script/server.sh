#!/bin/sh
#
# Starting and stopping the Rails server.
#
# Copyright (C) 2012, The University of Queensland.
#----------------------------------------------------------------

PIDBASEDIR=tmp
PIDFILE=${PIDBASEDIR}/pids/server.pid

if [ $# -eq 0  -o  "$1" = '-h'  -o  "$1" = '--help' ]; then
    # Show help
    echo "Usage: $0 command"
    echo "Commands:"
    echo "  start   - starts the server"
    echo "  stop    - stops the server"
    echo "  restart - stops and starts the server"
    echo "  status  - shows the status of the server"

elif [ $# -eq 1 ]; then

    PIDDIR=`dirname $PIDFILE`
    if [ ! -d "$PIDBASEDIR" ]; then
	echo "Error: directory not found: $PIDBASEDIR (wrong directory?)" >&2
	exit 1
    fi

    case "$1" in
	start)
	    if [ -f $PIDFILE ]; then
		echo "Error: PID file found: server already running?" >&2
		exit 1
	    else
		rails server -d
	    fi
	    ;;

	stop)
	    if [ -f $PIDFILE ]; then
		kill -INT `cat tmp/pids/server.pid`
	    else
		echo "Warning: PID file not found: server not running?" >&2
	    fi
	    ;;
	restart)
	    if [ -f $PIDFILE ]; then
		kill -INT `cat tmp/pids/server.pid`
		sleep 1
		while [ -f $PIDFILE ]; do
		    echo "Waiting for server to stop"
		    sleep 1
		done
		rails server -d

	    else
		echo "Warning: PID file not found: server not running?" >&2
	    fi
	    ;;

	status)
	    if [ -f $PIDFILE ]; then
		echo "Rails server running (PID=`cat $PIDFILE`)"
	    else
		echo "Rails server not running"
	    fi
	    ;;
	*)
	    echo "Usage error: unknown command: $1 (--help for help)" >&2
	    exit 2
    esac

else
  echo "Usage error: too many arguments (--help for help)" >&2
  exit 2
fi

exit 0

#EOF
