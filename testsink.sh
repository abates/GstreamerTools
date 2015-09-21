#!/bin/bash

SGP=$1

if [ -s $SGP ] ; then
  echo "usage: $0 <src@grp:port>"
  exit 1
fi

SG=`echo $SGP | awk -F: '{print \$1}'`
PORT=`echo $SGP | awk -F: '{print \$2}'`

echo "Joining $SG on port $PORT"
gst-launch-1.0 udpsrc multicast-iface="eth0" uri="udp://$SG:$PORT" ! \
              'application/x-rtp,payload=33,encoding-name=MP2T,clock-rate=90000' ! \
               rtpmp2tdepay ! tsdemux name="demux" \
                 demux. ! ac3parse ! avdec_ac3 ! autoaudiosink \
                 demux. ! h264parse ! avdec_h264 ! autovideosink

  #'application/x-rtp,payload=96,encoding-name=H264' ! \
#udpsrc multicast-iface="eth0" uri="udp://$SG:$AUDIO_PORT" name="audiosrc" ! 'application/x-rtp,payload=96,encoding-name=AC3,clock-rate=44100' !\
                 #rtpac3depay ! ac3parse ! avdec_ac3 ! autoaudiosink \
                 #rtph264depay ! h264parse ! avdec_h264 ! autovideosink 

exit 0

