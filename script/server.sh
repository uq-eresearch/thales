#!/bin/sh
#
# Starting and stopping the Rails server.
#
# Copyright (C) 2012, The University of Queensland.
#----------------------------------------------------------------

DEFAULT_PORT=3000

#----------------------------------------------------------------
# Parameters

HELP=
VERBOSE=
PORT=$DEFAULT_PORT
FORCE=

ACTION=

#----------------------------------------------------------------
# Process command line

PROG=`basename $0`

getopt -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  eval set -- `getopt --long help,verbose,port:,force --options fhvp: -- "$@"`
else
    # Original getopt is available
  eval set -- `getopt fhvp: "$@"`
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -f | --force)       FORCE=yes;;
    -p | --port)        PORT="$2"; shift;;
    -h | --help)        HELP=yes;;
    -v | --verbose)     VERBOSE=yes;;
    --)                 shift; break;;
  esac
  shift
done

if [ $HELP ]; then
  echo "Usage: ${PROG} [options] action"
  echo "Options:"
  echo "  -p | --port num"
  echo "        port to run server on (default: $DEFAULT_PORT)"
  echo "  -f | --force"
  echo "        force start the server even if the PID file exists"
  echo "  -h | --help"
  echo "        show this message"
  echo "  -v | --verbose"
  echo "        show extra information"
  echo "Actions:"
  echo "  start   - starts the server"
  echo "  stop    - stops the server"
  echo "  restart - stops and starts the server"
  echo "  status  - shows the status of the server"
  exit 3
fi

if [ $# -eq 0 ]; then
  echo "Usage error: command missing (--help for help)" >&2
  exit 2
elif [ $# -eq 1 ]; then
  ACTION="$1"
else
  echo "Usage error: too many arguments (--help for help)" >&2
  exit 2
fi

#----------------------------------------------------------------

# Change to Rails project top level directory
cd `dirname $0`/.. || exit 1

PIDFILE=tmp/pids/server.pid
PIDDIR=`dirname $PIDFILE`
if [ ! -d "app" ]; then
  echo "Error: not a Rails project (app directory not found): `pwd`" >&2
  echo "Error: script installed in wrong directory: `dirname $0`" >&2
  exit 1
fi

case "$ACTION" in
    start)
	if [ -f $PIDFILE ]; then
	    ps -p `cat "$PIDFILE"` > /dev/null
	    if [ $? -eq 0 ]; then
  	      echo "Error: cannot start: server is already running." >&2
	      exit 1
	    fi
	    if [ ! "$FORCE" ]; then
  	      echo "Error: zombie PID file found: $PIDFILE (use --force to overwrite)" >&2
	      exit 1
	    fi
	fi

	which rails >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	  echo 'Error: rails command not found (run "bundle install"?)' >&2
	  exit 1
	fi

	rails server -d --port=${PORT}

	sleep 3
	if [ ! -f $PIDFILE ]; then
	  echo "Error: rails server failed to start (try \"rails server -d\")" >&2
	  exit 1
	fi
	;;

    stop)
	if [ -f $PIDFILE ]; then
	    kill -INT `cat "$PIDFILE"`
	else
	    echo "Warning: PID file not found: server not running?" >&2
	fi
	;;

    restart)
	if [ -f $PIDFILE ]; then
	    kill -INT `cat "$PIDFILE"`
	    sleep 1
	    while [ -f $PIDFILE ]; do
		echo "Waiting for server to stop"
		sleep 1
	    done
	    rails server -d --port=${PORT}

	else
	    echo "Warning: PID file not found: server not running?" >&2
	fi
	;;

    status)
	if [ -f $PIDFILE ]; then
	    ps -p `cat "$PIDFILE"` > /dev/null
	    if [ $? -eq 0 ]; then
		echo "Rails server running (PID=`cat $PIDFILE`)"
	    else
		echo "Rails server not running (zombie PID file exists)"
	    fi
	else
	    echo "Rails server not running"
	fi
	;;

    *)
	echo "Usage error: unknown command: $ACTION (--help for help)" >&2
	exit 2
esac

exit 0

#EOF
