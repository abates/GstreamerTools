package main

import (
	"fmt"
	"github.com/ziutek/gst"
	"os"
)

var err error

func makeElement(element, name string) *gst.Element {
	if err != nil {
		return nil
	}
	e := gst.ElementFactoryMake(element, name)
	if e == nil {
		err = fmt.Errorf("could not create element '%s' of type '%s'", name, element)
	}
	return e
}

func setProperty(element *gst.Element, name string, value interface{}) {
	if err == nil {
		element.SetProperty(name, value)
	}
}

func link(elements ...*gst.Element) {
	var src *gst.Element
	for _, sink := range elements {
		if err == nil && src != nil {
			if !src.Link(sink) {
				err = fmt.Errorf("Failed to link %s:%s -> %s:%s", src.Type(), src.GetName(), sink.Type(), sink.GetName())
			}
		}
		src = sink
	}
}

func main() {
	src := makeElement("videotestsrc", "testSource")

	encoder := makeElement("x264enc", "encoder")
	setProperty(encoder, "key-int-max", 250)

	parser := makeElement("h264parse", "parser")

	mux := makeElement("mpegtsmux", "muxer")

	sink := makeElement("hlssink", "sink")
	setProperty(sink, "target-duration", 5)
	setProperty(sink, "location", "segments/segment%05d.ts")
	setProperty(sink, "playlist-location", "segments/playlist.m3u8")

	if err != nil {
		fmt.Fprintf(os.Stderr, "Cannot proceed %v\n", err)
		os.Exit(-1)
	}

	pipe := gst.NewPipeline("TestPipeline")
	if pipe == nil {
		panic("Failed to create pipe")
	}
	pipe.Add(src, encoder, parser, mux, sink)

	link(src, encoder, parser, mux, sink)

	pipe.SetState(gst.STATE_PLAYING)
	for {
	}
}
