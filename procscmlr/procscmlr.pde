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

Monome m;
SDrop drop;
ControlP5 controlP5;
ScrollList l;

String sample = "F:\\Documents and Settings\\Ash\\Desktop\\Monome\\Samples\\02. Rusty Nails.wav";
Integer itemNum = 1;
Integer monomeWidth = 8;
Integer monomeHeight = 8;
String[] samples = new String[monomeHeight];
Buffer[] buffers = new Buffer[monomeHeight];
Synth[] synths = new Synth[monomeHeight];

void setup ()
{
/*  buffers[itemNum] = new Buffer(2);
  buffers[itemNum].read(sample, this, "done"); 
  */

  m = new MonomeOSC(this);
  m.lightsOff();
  drop = new SDrop(this);
  
  size(600,400);
  controlP5 = new ControlP5(this);
  l = controlP5.addScrollList("myList", 100,100,400,280);
  l.setLabel("Drag samples (wav) onto the window");
  addSample(sample);
}

void draw ()
{
}

void done (Buffer buffer)
{
  println("Buffer loaded.");
  println("Channels:    " + buffers[itemNum - 1].channels);
  println("Frames:      " + buffers[itemNum - 1].frames);
  println("Sample Rate: " + buffers[itemNum - 1].sampleRate);
  
  synths[itemNum - 1] = new Synth("playbuf_2");
//  synth = new Synth("mlr");
//  synth = new Synth("playbuf_3");
  
  synths[itemNum - 1].set("bufnum", buffers[itemNum - 1].index);
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
  if( y == 0 )    // Top row turns off each sample
  {
    if( synths[x + 1].created )
    {
      synths[x + 1].free();
      for( int i = 0; i < 8; i++ )
      {
        m.lightOff(i, x + 1);
      }
      m.lightOff(x, y);
    }
    else
    {
      monomePressed(0, x + 1);
    }
    
  }
  else
  {    
    for( int i = 0; i < 8; i++ )
    {
      m.lightOff(i, y);
    }
    m.lightOn(x, y);
    m.lightOn(y - 1, 0);
    
    println("monomePressed: x, y: " + x + ", " + y);
    if (synths[y].created)
    {
      synths[y].free();
    }    
    
    println("x, y: " + x + ", " + y);
    println("x / 8 = " + ((x / 8f)));
    println("Buffer position: Frame " + (buffers[y].frames * (x / 8f)));
    synths[y].set("startPos", (int)(buffers[y].frames * (x / 8f)));
    synths[y].create();
  }
}

void stop()
{
/*  buffers[itemNum].free(this, "freed");
  synths[itemNum].free();
  */
}

void dropEvent(DropEvent theDropEvent) 
{
  addSample("" + theDropEvent.file());
}

void controlEvent(ControlEvent event) 
{
  if (event.isController())
  {
    //Button press
/*    println(event.controller().value()+ " from " + event.controller());
    loadBuffer(samples[(int)event.controller().value()]);
    */
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
  loadBuffer(fileName);
  itemNum++;
}

void loadBuffer(String fileName)
{
//  synth.free();
//  buffer.free();

  println("loadBuffer itemNum: " + itemNum);
  buffers[itemNum] = new Buffer(2);
  buffers[itemNum].read(fileName, this, "done");
}
