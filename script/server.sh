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

ACTION=

#----------------------------------------------------------------
# Process command line

PROG=`basename $0`

getopt -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  eval set -- `getopt --long help,verbose,port: --options hvp: -- "$@"`
else
    # Original getopt is available
  eval set -- `getopt hvp: "$@"`
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)        HELP=yes;;
    -v | --verbose)     VERBOSE=yes;;
    -p | --port)        PORT="$2"; shift;;
    --)                 shift; break;;
  esac
  shift
done

if [ $HELP ]; then
  echo "Usage: ${PROG} [options] action"
  echo "Options:"
  echo "  -p | --port num"
  echo "        port to run server on (default: $DEFAULT_PORT)"
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
	    echo "Error: PID file found: server already running?" >&2
	    exit 1
	else
	    rails server -d --port=${PORT}
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
	    rails server -d --port=${PORT}

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
	echo "Usage error: unknown command: $ACTION (--help for help)" >&2
	exit 2
esac

exit 0

#EOF
