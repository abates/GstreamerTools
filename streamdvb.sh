#!/bin/bash

TMP_DIR=`mktemp -d`
if [ -z "`gst-inspect-1.0 | grep omxh264enc`" ] ; then
  CODEC=x264enc
else
  CODEC="omxmpeg2videodec ! omxh264enc target-bitrate=3500000 control-rate=variable periodicty-idr=250 interval-intraframes=250"
  #CODEC="omxmpeg2videodec ! omxh264enc periodicty-idr=450"
  #CODEC="omxmpeg2videodec ! video/x-raw ! omxh264enc target-bitrate=2000000 control-rate=variable periodicty-idr=150"
fi

echo "Launching test stream and writing to $TMP_DIR"

#export GST_DEBUG=gstomxh264enc:5

gst-launch-1.0 -vvv dvbsrc frequency=683028615 modulation=8vsb ! tsdemux name="input" program-number=3 \
               input. ! queue  max-size-buffers=0 max-size-time=0 ! mpegvideoparse ! $CODEC ! h264parse ! mux. \
               input. ! queue ! ac3parse ! mux. \
               mpegtsmux name="mux" ! \
               hlssink target-duration=5 location=$TMP_DIR/segment%05d.ts playlist-location=$TMP_DIR/playlist.m3u8 &

retval=$?
GST_PID=$!
CWD=`pwd`

cd $TMP_DIR
python -m SimpleHTTPServer 9981 
cd $CWD

kill -9 $GST_PID
rm -rf $TMP_DIR
exit $retval
