#!/bin/bash

BIND_INTERFACE=$1
if [ -z $BIND_INTERFACE ] ; then
  echo "usage: $0 <bind interface>"
  exit 1
fi

MULTICAST_IP_ADDR="232.0.0.1"
PORT="5004"

BIND_ADDRESS=`ifconfig $BIND_INTERFACE | grep "inet addr:" | awk '{print \$2}' | awk -F: '{print \$2}'`
if [ -z "`gst-inspect-1.0 | grep omxh264enc`" ] ; then
  H264_ENC=x264enc
else
  H264_ENC=omxh264enc
fi

echo "Launching test stream at rtp://$BIND_ADDRESS@$MULTICAST_IP_ADDR:$PORT"

gst-launch-1.0 videotestsrc is-live=true ! $H264_ENC ! queue ! h264parse ! mux. \
               audiotestsrc is-live=true ! avenc_ac3_fixed bitrate=64000 ! mux. \
               mpegtsmux name="mux" ! queue ! rtpmp2tpay ! \
               udpsink auto-multicast=true ttl-mc=3 bind-address=$BIND_ADDRESS host=$MULTICAST_IP_ADDR port=$PORT \

