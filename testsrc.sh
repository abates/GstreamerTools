#!/bin/bash

BIND_INTERFACE=eth0
MULTICAST_IP_ADDR="232.0.0.1"
AUDIO_UDP_PORT="5004"
VIDEO_UDP_PORT="5005"

BIND_ADDRESS=`ifconfig $BIND_INTERFACE | grep "inet addr:" | awk '{print \$2}' | awk -F: '{print \$2}'`
if [ -z "`gst-inspect-1.0 | grep omxh264enc`" ] ; then
  H264_ENC=x264enc
else
  H264_ENC=omxh264enc
fi

gst-launch-1.0 -v videotestsrc is-live=true ! $H264_ENC ! queue ! h264parse ! rtph264pay ! videosink. \
                  audiotestsrc is-live=true ! avenc_ac3_fixed bitrate=64000 ! rtpac3pay ! queue ! audiosink. \
                  udpsink name="audiosink" auto-multicast=true ttl-mc=3 bind-address=$BIND_ADDRESS host=$MULTICAST_IP_ADDR port=$AUDIO_UDP_PORT \
                  udpsink name="videosink" auto-multicast=true ttl-mc=3 bind-address=$BIND_ADDRESS host=$MULTICAST_IP_ADDR port=$VIDEO_UDP_PORT

