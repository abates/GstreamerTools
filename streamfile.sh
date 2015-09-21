#!/bin/bash

BIND_INTERFACE=$1
FILE=$2

if [ -z "$BIND_INTERFACE" ] || [ -z "$FILE" ] ; then
  echo "usage: $0 <bind interface> <input file>"
  exit 1
fi

MULTICAST_IP_ADDR="232.0.0.1"
PORT="5004"

BIND_ADDRESS=`ifconfig $BIND_INTERFACE | grep "inet addr:" | awk '{print \$2}' | awk -F: '{print \$2}'`
if [ -z "`gst-inspect-1.0 | grep omxh264enc`" ] ; then
  H264_ENC="x264enc quantizer=19"
else
  H264_ENC=omxh264enc
fi

echo "Launching stream at rtp://$BIND_ADDRESS@$MULTICAST_IP_ADDR:$PORT"

gst-launch-1.0 filesrc location="$FILE" ! decodebin name="input" \
               input. !queue ! videoconvert ! videoscale ! video/x-raw,width=720,height=480 ! $H264_ENC ! queue ! h264parse ! mux. \
               input. ! queue ! audioconvert ! avenc_ac3_fixed ! queue ! mux. \
               mpegtsmux name="mux" ! rtpmp2tpay ! \
               udpsink auto-multicast=true ttl-mc=3 bind-address=$BIND_ADDRESS host=$MULTICAST_IP_ADDR port=$PORT

