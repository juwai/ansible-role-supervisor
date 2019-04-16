#!/bin/sh
#
# /etc/rc.d/init.d/supervisord
#
# Supervisor is a client/server system that
# allows its users to monitor and control a
# number of processes on UNIX-like operating
# systems.
#
# chkconfig: - 64 36
# description: Supervisor Server
# processname: supervisord

# Source init functions
. /etc/rc.d/init.d/functions

prog="supervisord"

prefix="/usr/local"
exec_prefix="${prefix}"
prog_bin="${exec_prefix}/bin/supervisord"
prog_ctl="${exec_prefix}/bin/supervisorctl"
config_file="/etc/supervisord.conf"
sock_file="/tmp/supervisor.sock"

start()
{
    echo -n $"Starting $prog: "
    $prog_bin -c $config_file
    [ $? -eq 0 ] && success $"$prog startup" || failure $"$prog startup"
    echo
}

stop()
{
    echo -n $"Shutting down $prog: "
    $prog_ctl shutdown > /dev/null
    # Make sure sub processes also been stopped
    for sleep in 2 2 2 2 4 4 4 4 8 8 8 8 last; do
        if [ ! -e $sock_file ] ; then
            success $"$prog shutdown"
            break
        else
            if [[ $sleep -eq "last" ]] ; then
                echo 'It takes too long to stop, must be something wrong'
                failure $"$prog shutdown"
                return 1
            else
                sleep $sleep
            fi
        fi
    done
    echo
}

case "$1" in
    start)
        start
    ;;

    stop)
        stop
    ;;

    status)
        status $prog
    ;;

    restart)
        stop
        start
    ;;

    *)
        echo "Usage: $0 {start|stop|restart|status}"
    ;;
esac
