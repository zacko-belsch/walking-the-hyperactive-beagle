// assignment_8_piano_rhythm.ck
// Walking the Hyperactive Beagle
//
// This module provides a low frequency piano-based rhythm as the foundation
// for our composition.  It uses a chord sequence defined by the conductor with
// each chord occupying a whole measure.  During the measure the chord is
// played as two alternating notes, either the root and the octave or the root
// and the fifth (chosen randomly).
//
// Initially this voice is in the middle of the audio field, but after a short
// while begins panning left and right, connected to a sinusoid.

Rhodey keys => LPF phil => JCRev r => Pan2 pianoPan => dac;
1 => pianoPan.gain;
0 => pianoPan.pan;
.8 => keys.gain;
.8 => r.gain;
.2 => r.mix;
400 => phil.freq;
1.0 => phil.Q;
2.0 => phil.gain;

BPM tempo;
tempo.quarterNote => dur quarter;
tempo.eighthNote => dur eighth;
quarter*16 => dur measure;

ClockManager clock;
clock.pianoDuration => dur totalDuration;
clock.fadeDuration  => dur fadeDuration;
false => int fadeComplete;

ScaleBuilder sb;
sb.scale @=> int scale[];
sb.pianoMelody @=> int chordSeries[];
sb.fifth  => int fifth;
sb.octave => int octave;

spork ~ piano_walk(measure,1.3*measure);
spork ~ fade_out(totalDuration-fadeDuration,fadeDuration);

// 'main' shred plays the chord sequence

-1 => int chordNumber;
while (!fadeComplete)
	{
	// get the chord for this measure and randomly shift up an octave
	(chordNumber+1) % chordSeries.cap() => chordNumber;
	chordSeries[chordNumber] + octave*Math.random2(0,1) => int note;

	// randomly choose the alternating interval as a fifth or an octave
	note + choose_from_array([fifth,octave]) => int note2;

	// play the measure with slightly randomized touch
	for (1=>int beat ; beat<=4 ; beat++)
		{
		scale[note] => Std.mtof => keys.freq;
		(.8,1.0) => Math.random2f => keys.noteOn;
		eighth => now;

		scale[note2] => Std.mtof => keys.freq;
		(.5,.8) => Math.random2f => keys.noteOn;
		eighth => now;
		}

	}

// shred to pan the voice left and right

fun void piano_walk(dur wait, dur period)
	{
	wait => now;
	now => time start;
	while (true)
		{
		((now - start) / period) % 1 => float fractionOfCycle;
		Math.sin(fractionOfCycle * 2 * pi) => pianoPan.pan;
		10::ms => now;
		}
	}

// shred to fade out

fun void fade_out(dur wait, dur fadeTime)
	{
	wait => now;
	now => time start;
	while (now - start < fadeTime)
		{
		(now - start) / fadeTime => float fadePosition;
		1-fadePosition => pianoPan.gain;
		10::ms => now;
		}
	true => fadeComplete;
	}

// choose one element from an array, at random.

fun int choose_from_array(int array[])
    {
    return array[Math.random2(0,array.cap()-1)];
    }

