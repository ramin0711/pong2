// Integrating glass bowl and pong physic app thingy!
// Ramin Anushiravani

// Additive Sine Synthesis, 7 sine wave partials, arbitrary frequencies.
//  by Perry R. Cook, 2015
// Mode Class models a single exponentially decaying sine wave
class Mode extends Chubgraph {
    SinOsc s => Gain mul => outlet;  // Sine wave
    Impulse ex => OnePole env => mul; // exponential decaying envelope
    3 => mul.op; // set to multiply   // multiply the two
    
    fun void freq(float freq) { freq => s.freq; } // set frequency
    
    fun void T60(dur tsixty) {                    // set decay time
        Math.pow(10.0,-3.0/(tsixty/samp)) => env.pole;
        1.0 => env.b0;  // overrides internal normalization
    }
    
    fun void keyOn() { 1.0 => ex.next; }    // trigger it to sound
}

// Simple physics of bouncing ball in a 
//    square  box.  One peg in center.
//  Collisions trigger sounds.  
//    by Perry R. Cook, 2015
// Simple Inharmonic sound with seven partials
class GlassBowl extends Chubgraph  {
    7 => int NUM_PARTIALS;
    Mode m[NUM_PARTIALS];
    [111.0,273,413,733,1111,1577,2138] @=> float freqs[];
    [1.0,0.4,0.3,0.2,0.1,0.1,0.7] @=> float gains[];
    [3.0,2.7,2.3,2.1,1.7,1.4,1.0] @=> float t60s[];
    for (int i; i < NUM_PARTIALS; i++)  {
        m[i] => dac;
        freqs[i] => m[i].freq;
        t60s[i]::second => m[i].T60;
        gains[i]/NUM_PARTIALS => m[i].gain;
    }
    
    fun void whackIt()  {  // fire up all modes at current settings
        for (int i; i < NUM_PARTIALS; i++)  {
            m[i].keyOn();
        }
    }
    
    fun void whackItRandom(float velocity)  { // random scaled gains
        for (int i; i < NUM_PARTIALS; i++)  {
            freqs[i] => m[i].freq;
            Math.random2f(gains[i]/2,gains[i]*2)*velocity => m[i].gain;
        }
        whackIt();
    }
    
    // overloaded function uses position (0-1.0) for mode gains
    //   makes gross assumption that modes are 1D spatial modes
    fun void whackIt(float velocity, float position)  {
        for (int i; i < NUM_PARTIALS; i++)  {
            freqs[i] => m[i].freq;
            Math.sin(pi*(i+1)*position) => float temp;
            <<< temp >>>;
            velocity*temp*gains[i] => m[i].gain;
        }
        whackIt();
    }
    
    // overloaded function uses pitch transpose (0-1) plus position
    fun void whackIt(float pitch, float velocity, float position)  {
        for (int i; i < NUM_PARTIALS; i++)  {
            pitch*freqs[i] => m[i].freq;
            Math.sin(pi*(i+1)*position/NUM_PARTIALS) => float temp;
            velocity*temp*gains[i] => m[i].gain;
        }
        whackIt();
    }
}    
// Here is my def for Class glassbowl 2. 
// I change the frequencies to lower ones (and wanted
// to also add that beating pattern you get when 
// the harmonics are close to each pther )and increased 
// the t60 to get more lasting reverb. I also 
// increased the gain and put them closer to each other

class GlassBowl2 extends Chubgraph  {
    7 => int NUM_PARTIALS;
    Mode m[NUM_PARTIALS];
    [51.0,153,153.1,153.5,191,207,338] @=> float freqs[];
    [2.0,1.9,1.3,1.2,1.1,1,0.7] @=> float gains[];
    [12.0,6.7,5.3,4.1,3.7,2.4,1.0] @=> float t60s[];
    for (int i; i < NUM_PARTIALS; i++)  {
        m[i] => dac;
        freqs[i] => m[i].freq;
        t60s[i]::second => m[i].T60;
        gains[i]/NUM_PARTIALS => m[i].gain;
    }
    
    fun void whackIt()  {  // fire up all modes at current settings
        for (int i; i < NUM_PARTIALS; i++)  {
            m[i].keyOn();
        }
    }
    
    fun void whackItRandom(float velocity)  { // random scaled gains
        for (int i; i < NUM_PARTIALS; i++)  {
            freqs[i] => m[i].freq;
            Math.random2f(gains[i]/2,gains[i]*2)*velocity => m[i].gain;
        }
        whackIt();
    }
    
    // overloaded function uses position (0-1.0) for mode gains
    //   makes gross assumption that modes are 1D spatial modes
    fun void whackIt(float velocity, float position)  {
        for (int i; i < NUM_PARTIALS; i++)  {
            freqs[i] => m[i].freq;
            Math.sin(pi*(i+1)*position) => float temp;
            <<< temp >>>;
            velocity*temp*gains[i] => m[i].gain;
        }
        whackIt();
    }
    
    // overloaded function uses pitch transpose (0-1) plus position
    fun void whackIt(float pitch, float velocity, float position)  {
        for (int i; i < NUM_PARTIALS; i++)  {
            pitch*freqs[i] => m[i].freq;
            Math.sin(pi*(i+1)*position/NUM_PARTIALS) => float temp;
            velocity*temp*gains[i] => m[i].gain;
        }
        whackIt();
    }
}    


// Simple Ball object with physics variables
class Ball {
    0.06 => float r;   // radius
    0.5 => float x;    // x position
    0.5 => float y;    // y position
    0.02 => float dx;  // velocity in x
    0.01 => float dy;  // velocity in y
    0.0 => float ax;   // acceleration in x 
    0.0 => float ay;   // acceleration in y
    0.995 => float damp; // 1.0 means no loss over time
    
    fun void doPhysics()  {
        ax +=> dx;   // dx += ax; // in C/Java
        ay +=> dy;   // dy += ay; // in C/Java
        (damp *=> dx) +=> x;      // x += (dx *= damp);  // in C/Java
        (damp *=> dy) +=> y;      // y += (dy *= damp);  // in C/Java
    }
}

// Define your sound making objects here
//  You're going to make this different, using
//    the glassbowl and your own customized one too
//"special:dope" => ballSound.read;
GlassBowl gb;
GlassBowl2 gb2;
gb=> Pan2 pan => dac;
gb.whackIt;
//ballSound.samples() => ballSound.pos;

Ball ball; // moving ball
Ball peg;  // rigid filled peg
0.15 => peg.r; // make it bigger this time
0.0 => peg.x => peg.y => peg.dx => peg.dy;
drawPeg(0,peg);  // only have to do this once

now + 20::second => time then;  // run for 10 seconds

while (now < then)   {
    ball.doPhysics();
    drawBall(1,ball);
    if (checkLeftRightWalls(ball)) {
        ball.x => pan.pan;  // pan is set by position
        soundA(ball.dx);
    }
    if (checkTopBottomWalls(ball)) {
        ball.x => pan.pan;
        soundB(ball.dy);
    }   
    if (checkBallPegballSound(ball,peg)) {
        soundC(ball.dx+ball.dy);
    }
    33*ms => now;  // 30 frames (roughly) per second
}

chout <= "Exit\n";   // send exit signal to GL Viewer
chout.flush();

fun void drawBall(int which,Ball bl)  {
    chout <= "b"+which+" "+bl.x+" "+bl.y+" "+bl.r+"\n";   // draw a ball
    chout.flush();                  // make sure things don't linger in buffers
}

fun void drawPeg(int which, Ball pg)  {
    drawBall(which,pg);        // draw a ball, but
    chout <= "f"+which+" 1\n"; // then fill it in
    chout.flush();             // make sure things don't linger in buffers
}

fun int checkLeftRightWalls(Ball bl)  {
    if (bl.x < -(1.0-bl.r)) {  // check left limit in x
        3*bl.dx -=> bl.x;  // bounce off
        -1 *=> bl.dx;   // with velocity reflection
        Math.random2f(-0.001,0.001) => bl.ax;  // new random x force
        return 1;
    }
    else if (bl.x > (1.0-bl.r)) {  // check right limit in x
        3*bl.dx -=> bl.x;  // bounce off
        -1 *=> bl.dx;   // with velocity reflection
        Math.random2f(-0.001,0.001) => bl.ax;  // new random x force
        return 1;
    }
    else return 0;
}

fun int checkTopBottomWalls(Ball bl)  {
    if (bl.y > (1.0-bl.r)) {  // check top limit in y
        3*bl.dy -=> bl.y;  // bounce off
        -1 *=> bl.dy;   // with velocity reflection
        Math.random2f(-0.001,0.001) => bl.ay;  // new random y force
        return 1;
    }
    else if (bl.y < -(1.0-bl.r)) {  // check top limit in y
        3*bl.dy -=> bl.y;  // bounce off
        -1 *=> bl.dy;   // with velocity reflection
        Math.random2f(-0.001,0.001) => bl.ay;  // new random y force
        return 1;
    }
    else return 0;
}

fun float distance(Ball bl, Ball bl2)  {
    bl2.x - bl.x => float delx;
    bl2.y - bl.y => float dely;
    return Math.sqrt(delx*delx + dely*dely);
}

fun int checkBallPegballSound(Ball bl, Ball pg)  {
    if (distance(bl,pg) < bl.r+pg.r)  {  // collision!!
        3*bl.dy -=> bl.y;  // bounce off
        -0.5 *=> bl.dy;   // with velocity reflection and great loss
        3*bl.dx -=> bl.x;  // bounce off
        -0.5 *=> bl.dx;   // with velocity reflection and great loss
        
        // the peg has magical powers!!!
        Math.random2f(-0.001,0.001) => bl.ax; // new random forces
        Math.random2f(-0.001,0.001) => bl.ay; //  after collision
        return 1;
    }
    else return 0;
}

//  You're gonna make these very different.  
//  All sinusoidal additive sounds, NO PCM!!
// I changed everything to inharmonic sines here. The first 
// call the glass bowl class, different pitch and behaviors here
// for soundA and soundB. soundC call glassbowl 2, which was
// defined earlier on top. 
// I'm not sure how awesome it sounds yet, I wish I knew more to give 
// it more structure. But, it's kind of making music I guess, 
// just not very good ones yet :)
fun void soundA(float vel)  {
 // test "strike position" function
    gb.whackIt(Math.random2f(0.1,2),5*vel,0.5);  
}

fun void soundB(float vel)  {
   // "special:dope" => ballSound.read; 
    Math.random2f(0.5,4.0) => float pitch;
    gb.whackIt(pitch,       // pitch multiplier
                   0.5 + 0.2*Math.fabs(vel), // velocity
                      0.3);
    //ballSound.samples() => ballSound.pos;
}

fun void soundC(float vel)  {  
    gb2.whackIt();
}

