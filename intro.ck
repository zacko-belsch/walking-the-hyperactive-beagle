// assignment_8_intro.ck
// Walking the Hyperactive Beagle
//
// This module provides a FM effect that serves as an intro transition into
// our composition.  It begins to fade out after 2 seconds and is gone after
// 5 seconds.

SinOsc fmMod => SinOsc fmCarrier => Pan2 master => dac;
0.3 => float masterGain => master.gain;
1.0 => fmCarrier.gain;
2 => fmCarrier.sync;  // FM

5000 => int stepsPerTransition;
20 => int reportsPerTransition;
10::second => dur transition;

10.0   => float prevModGain;
2500.0 => float modGain;
33.0   => float modFreq;
1.0    => float carGain;
383.0 => float carFreq;

spork ~ fade_out(2::second,5::second);

now => time transitionStart;
for (1=>int step ; step<=stepsPerTransition ; step++)
	{
	interpolate(modGain, prevModGain, step, stepsPerTransition) => float newModGain => fmMod.gain;
	modFreq => fmMod.freq;
	carGain => fmCarrier.gain;
	carFreq => fmCarrier.freq;
	transitionStart + (step*transition)/stepsPerTransition => now;
	}

5::second => now;


fun float interpolate(float oldVal, float newVal, int step, int numSteps)
	{
	return ((step * oldVal) + ((numSteps-step) * newVal)) / numSteps;
	}


fun void fade_out(dur wait, dur fadeTime)
	{
	wait => now;
	now => time start;
	while (now - start < fadeTime)
		{
		(now - start) / fadeTime => float fadePosition;
		(1-fadePosition) * masterGain => master.gain;
		10::ms => now;
		}
	}
