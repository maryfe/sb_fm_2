

/*
 * Base Example 
 *
 *   Sketch that features the basic building blocks of a Spacebrew client app.
 * 
 */

import spacebrew.*;


//local: 172.29.3.140
String server="sandbox.spacebrew.cc";
String name="Rafa FM_2";
String description ="This is set up to suscribe to mobile slider clients publishing range values";
//incoming range var
float inputX=10;    
float inputY=10;
float inputZ=10;

color c= color(0);


Spacebrew sb;

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext
// declare our unit generators
WavePlayer modulator;
WavePlayer modulator2;
WavePlayer carrier;
WavePlayer carrier2;
WavePlayer carrier3;

Glide modulatorFrequency;
// our envelope and gain objects
Envelope gainEnvelope;
Gain synthGain;

void setup() {
  size(600, 400);

  // initialize our AudioContext
  ac = new AudioContext();
  // create the modulator, this WavePlayer will
  // control the frequency of the carrier
  modulatorFrequency = new Glide(ac, 20, 50 );

  ///<<<<<<<
  modulator = new WavePlayer(ac, modulatorFrequency, 
  Buffer.SINE);
  // create a custom frequency modulation function
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate
      // frequency range
      return (x[0] * inputX ) ;
    }
  };
  //another wave player for the second modulator with its own frequencyModulation function

  ///<<<<<<<
  modulator2 = new WavePlayer(ac, modulatorFrequency, Buffer.SINE);
  //function to calculate frequency modulation, the return is store into carrier and carrier2
  Function frequencyModulation2 = new Function(modulator2)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate
      // frequency range
      return (x[0] * 100.0) + inputY;
    }
  };


  // create a 3rd WavePlayer, control the frequency
  // with the function created above
  ///<<<<<<<
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SQUARE);

  //and a 4th wave player for carrier2
  ///<<<<<<<
  carrier2=new WavePlayer(ac, frequencyModulation2, Buffer.SQUARE);

  // create the envelope object that will control the gain
  gainEnvelope = new Envelope(ac, 0);
  // create a Gain object, connect it to the gain envelope
  synthGain = new Gain(ac, 1, gainEnvelope);
  // connect the carrier to the Gain input
  synthGain.addInput(carrier);
  synthGain.addInput(carrier2);
  // connect the Gain output to the AudioContext
  ac.out.addInput(synthGain);
  ac.start(); // start audio processing



  // instantiate the sb variable
  sb = new Spacebrew( this );

  // add each thing you publish to
  //PARAMS: addPublish(name,type,default);
  //types: boolean,string,range
  //  sb.addPublish( "buttonPress", "boolean", false ); 
  sb.addPublish("xValue", "range", 0);
  sb.addPublish("yValue", "range", 0);
  sb.addPublish("zValue", "range", 0);

  //  sb.addPublish("mouseY", "range", 0);

  // add each thing you subscribe to
  // sb.addSubscribe( "color", "range" );
  //  sb.addSubscribe("buttonPress", "boolean");
  //  sb.addSubscribe("mouseMove", "boolean");
  sb.addSubscribe("x", "range");
  sb.addSubscribe("y", "range");
  sb.addSubscribe("z", "range");

  // connect to spacebrew
  sb.connect(server, name, description );
}


/*
 * Here's the code to draw a scatterplot waveform.
 * The code draws the current buffer of audio across the
 * width of the window. To find out what a buffer of audio
 * is, read on.
 * 
 * Start with some spunky colors.
 */
color fore = color(255, 102, 204);
color back = color(0, 0, 0);

/*
 * Just do the work straight into Processing's draw() method.
 */

float amplitude1;
float amplitude2;



void draw() {
  // do whatever you want to do here
  background(c);

  //  inputX= mouseX*random(0,3); 
  //  inputY=map(mouseY,0,height,10,height-100);
  //  inputZ=2;

  modulatorFrequency.setValue(inputY);

  amplitude1=map(inputZ,0,1023,.3,.9);
  println("amplitude1 ="+amplitude1);
  // when the mouse button is pressed,
  // add a 50ms attack segment to the envelope
  // and a 300 ms decay segment to the  envelope
  gainEnvelope.addSegment( amplitude1, random(10, 200)); // over 50ms rise to 0.8
  gainEnvelope.addSegment(0.0, random(20, 150)); // in 300ms fall to 0.0


    //  if (true) {
  //    println(input);
  //    // println("incomingY = "+incomingY);
  //    //this happens upon receipt of message
  //
  //    // ellipse(width/2, height/2, input, input);
  //  }
}
 

void keyPressed() {
  if (key=='s') {
    sb.send("mouseX", mouseX);
    // sb.send("mouseY", mouseY);
    c=color(0);
  }
}

void mouseDragged() {
  sb.send("mouseX", mouseX);
  // sb.send("mouseY", mouseY);
  c=color(100);
  //  println("mouseX");
}

void mousePressed() {
  sb.send("buttonPress", true);

  Function frequencyModulation3 = new Function(modulator2)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate
      // frequency range
      return (x[0] * 100.0 +200);
    }
  };
  carrier3=new WavePlayer(ac, frequencyModulation3, Buffer.SQUARE);
  synthGain.addInput(carrier3);
}

void mouseReleased() {
  sb.send("buttonPress", false);
}


void onRangeMessage( String name, int value ) {
  println("got range message " + name + " : " + value);
  if (name.equals("x")) {
    inputX=value;
    //yellow
    //    c=color(255, 255, 0);
  } 
  else if (name.equals("y")) {
    inputY=value;
  }
  else if (name.equals("z")) {
    inputZ=value;
  }
}






