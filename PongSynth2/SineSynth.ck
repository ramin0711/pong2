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

GlassBowl gb;

// Let's do some testing!!!

<<< "Whack It!!!", "" >>>;
gb.whackIt();  // test once in pure mode
2*second => now;

for (1 => int i; i < 10; i++) { // test "strike position" function
    gb.whackIt(0.5,i/25.0);  // move along "length" of bar (if it were a bar)
    <<< "Whack it at position:", i/13.0 >>>;
    second/2 => now;
}
second => now;

now + 10::second => time then;

// now try out some pitch transpositions
while (now < then)  {
    Math.random2f(0.5,4.0) => float pitch;
    <<< "Whack it with random pitch shift:", pitch  >>>;
    gb.whackIt(pitch,       // pitch multiplier
                   Math.random2f(0.05,0.6), // velocity
                      0.3); // and strike position
    second/2 => now;
}
