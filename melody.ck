// assignment_8_melody.ck
// Walking the Hyperactive Beagle
//
// This module plays the melody, uses a "score" array defined by the conductor

// debug flags
// false represents the normal state for most of these settings; setting them
// them to true enables or disables certain items in the program

false => int debugMelody;       // report what note we're playing (or don't)


VoicForm voice1 => JCRev reverb => Pan2 melodyPan => dac;
VoicForm voice2 =>       reverb;
1.0 => float melodyGain;
0.0 => melodyPan.gain;
.8  => reverb.gain;
.2  => reverb.mix;
.35 => voice1.gain;           .30 => voice2.gain;
3   => voice1.phonemeNum;     3   => voice2.phonemeNum;
0   => voice1.voiceMix;       0   => voice2.voiceMix;
.63 => voice1.loudness;       .63 => voice2.loudness;
.71 => voice1.pitchSweepRate; .71 => voice2.pitchSweepRate;
6.4 => voice1.vibratoFreq;    6.4 => voice2.vibratoFreq;
.05 => voice1.vibratoGain;    .05 => voice2.vibratoGain;


BPM tempo;
tempo.thirtysecondNote/3 => dur tickDur;

ScaleBuilder sb;
sb.scale @=> int scale[];

2 => int voicesLeft;

spork ~ fade_in(500::ms);
spork ~ play_voice("voice1", voice1, sb.melodyVoice1);
spork ~ play_voice("voice2", voice2, sb.melodyVoice2);
while (voicesLeft > 0) 1::second => now;


fun void play_voice(string name, VoicForm voice, int melody[])
	{
	1 => voice.noteOff;

	string debugInfo;
	now => time playStart;
	0 => int tickInMelody;
	0 => int melodyIx;
	while (melodyIx < melody.cap())
		{
		melody[melodyIx]   => int note;
		melody[melodyIx+1] => int ticksToPlay;
		2 +=> melodyIx;
	
		if (note == -1)
			"rest" => debugInfo;
		else
			"note=scale["+note+"]=" + scale[note] => debugInfo;
	
		if (debugMelody)
			<<< (now-playStart)/second,name,
				"tick="+tickInMelody,(melodyIx-2)/2,
				"ticks="+ticksToPlay,
				debugInfo >>>;
	
		if (note == -1)
			ticksToPlay*tickDur => now;
		else
			{
			scale[note] => Std.mtof => voice.freq;
			1 => voice.noteOn;
			ticksToPlay*tickDur => now;
			1 => voice.noteOff;
			}
	
		tickInMelody + ticksToPlay => tickInMelody;
		}
	
	if (debugMelody)
		<<< (now-playStart)/second,name,
			"tick="+tickInMelody,"done" >>>;

	voicesLeft--;
	}	

// shred to fade in

fun void fade_in(dur fadeTime)
	{
	now => time start;
	while (now - start < fadeTime)
		{
		(now - start) / fadeTime => float fadePosition;
		fadePosition * melodyGain => melodyPan.gain;
		10::ms => now;
		}
	}
