#!/bin/bash

SGP=$1

if [ -s $SGP ] ; then
  echo "usage: $0 <src@grp:audio_port:video_port>"
  exit 1
fi

SG=`echo $SGP | awk -F: '{print \$1}'`
AUDIO_PORT=`echo $SGP | awk -F: '{print \$2}'`
VIDEO_PORT=`echo $SGP | awk -F: '{print \$3}'`

echo "Joining $SG on ports $AUDIO_PORT and $VIDEO_PORT"
gst-launch-1.0 udpsrc multicast-iface="eth0" uri="udp://$SG:$AUDIO_PORT" name="audiosrc" ! 'application/x-rtp,payload=96,encoding-name=AC3,clock-rate=44100' !\
                 rtpac3depay ! ac3parse ! avdec_ac3 ! autoaudiosink \
               udpsrc multicast-iface="eth0" uri="udp://$SG:$VIDEO_PORT" name="videosrc"  ! 'application/x-rtp,payload=96,encoding-name=H264' ! \
                 rtph264depay ! h264parse ! avdec_h264 ! autovideosink 

exit 0
