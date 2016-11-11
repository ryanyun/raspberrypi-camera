#!/bin/sh

VLC_USER=pi

start()
{
    # v4l2-ctl -d /dev/video1 --list-formats
    v4l2-ctl -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=1 2> /dev/null
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=0 2> /dev/null
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=0 2> /dev/null
    # check if camera settings command was succesful (success: error code $? = 0)
    if [ $? -eq 0 ]
    then
        echo "Starting camera for recording at `date +"%T"`"
    else
        echo "Error: camera not found at /dev/video0" >&2
    fi
    sudo -u $VLC_USER cvlc --no-audio v4l2:///dev/video0:chroma=MJPG:width=1920:height=1080:fps=30 --sout="#std{access=file,fps=30,mux=ogg,noaudio,dst=go.mpg}" -vvv > /dev/null 2>&1  &
}

stream()
{
    # open vlc and connect to network rtsp://192.168.1.1:8554/ and livestream video
    v4l2-ctl -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=1 2> /dev/null
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=0 2> /dev/null
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=0 2> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Starting camera for live streaming"
    else
        echo "Error: camera not found at /dev/video0" >&2
    fi
    sudo -u $VLC_USER cvlc --no-audio v4l2:///dev/video0:chroma=MJPG:width=1920:height=1080:fps=30 --sout="#rtp{sdp=rtsp://:8554/}" -vvv > /dev/null 2>&1  &
}

stop()
{
    echo "Stopping camera recording at `date +"%T"`"
    kill -9 $(pidof vlc) >/dev/null 2>&1
}

case "$1" in
    start)
        start
        ;;
    stream)
        stream
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: $0 {start|stream|stop|restart}"
        ;;
esac

exit 0