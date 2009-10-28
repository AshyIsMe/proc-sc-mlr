/*

Run this SynthDef in SuperCollider before running this Sketch.

SynthDef(\playbuf_2, { |bufnum = 0, outbus = 0, amp = 0.5, loop = 0, rate = 1.0, startPos = 0|
	var data;
	data = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, 0, startPos, loop);
	FreeSelfWhenDone.kr(data);
	Out.ar(outbus, data * amp);
}).store;

SynthDef(\playbuf_3, { |bufnum = 0, outbus = 0, amp = 0.5, loop = 0, rate = 1.0, startPos = 0|
	//var data;
	//data = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, startPos, 0, loop);
	//FreeSelfWhenDone.kr(data);
	//Out.ar(outbus, data * amp);

	var start, trig;
	start = startPos;
	trig = MouseButton.kr(0, 1);
	startPos = MouseX.kr(0, 1) * BufFrames.kr(bufnum);
	Out.ar(outbus, BufRd.ar(2, bufnum, Phasor.ar(
		trig,
		BufRateScale.kr(bufnum) * rate,
		start,
		BufFrames.kr(bufnum),
		startPos
)));
}).store;
*/

import oscP5.*;
import netP5.*;
import supercollider.*;
import jklabs.monomic.*;
import sojamo.drop.*;
import controlP5.*;

Buffer buffer;
Monome m;
Synth synth;
SDrop drop;
ControlP5 controlP5;
ScrollList l;

String sample = "F:\\Documents and Settings\\Ash\\Desktop\\Monome\\Samples\\02. Rusty Nails.wav";
Integer itemNum = 0;
Integer monomeWidth = 8;
Integer monomeHeight = 8;
String[] samples = new String[monomeHeight];
Buffer[] buffers = new Buffer[monomeHeight];

// AA TODO: Add support for multiple simultaneous buffers

void setup ()
{
  buffer = new Buffer(2);
  buffer.read(sample, this, "done"); 

  m = new MonomeOSC(this);
  m.lightsOff();
  drop = new SDrop(this);
  
  size(600,400);
  controlP5 = new ControlP5(this);
  l = controlP5.addScrollList("myList", 100,100,400,280);
  l.setLabel("Samples");
  addSample(sample);
}

void draw ()
{
}

void done (Buffer buffer)
{
  println("Buffer loaded.");
  println("Channels:    " + buffer.channels);
  println("Frames:      " + buffer.frames);
  println("Sample Rate: " + buffer.sampleRate);
  
  synth = new Synth("playbuf_2");
//  synth = new Synth("mlr");
//  synth = new Synth("playbuf_3");
  
  synth.set("bufnum", buffer.index);
//  synth.set("startPos", (int)(buffer.frames / 2));
//  synth.create();
}

void mousePressed()
{
//  buffer.free(this, "freed");
}

void freed (Buffer buffer)
{
  println("Buffer freed.");
}

void monomePressed(int x, int y)
{
  m.lightsOff();
  m.lightOn(x, y);
  
  if (synth.created)
  {
    synth.free();
  }
  
  println("x, y: " + x + ", " + y);
  println("x / 8 = " + ((x / 8f)));
  println("Buffer position: Frame " + (buffer.frames * (x / 8f)));
  synth.set("startPos", (int)(buffer.frames * (x / 8f)));
  synth.create();
}

void stop()
{
  buffer.free(this, "freed");
  synth.free();
}

void dropEvent(DropEvent theDropEvent) 
{
  addSample("" + theDropEvent.file());
  loadBuffer("" + theDropEvent.file());
}

void controlEvent(ControlEvent event) 
{
  if (event.isController())
  {
    //Button press
    println(event.controller().value()+ " from " + event.controller());
    loadBuffer(samples[(int)event.controller().value()]);
  }
  else if (event.isGroup()) 
  {
    println(event.group().value() + " from " + event.group());
  }
}


void addSample(String fileName)
{
  println("addSample(\"" + fileName + "\")");
  controlP5.Button b = l.addItem(fileName, itemNum);
  b.setId(100 + itemNum);
  samples[itemNum] = fileName;
  itemNum++;
}

void loadBuffer(String fileName)
{
  synth.free();
  buffer.free();
  buffer = new Buffer(2);
  buffer.read(fileName, this, "done");            
}
