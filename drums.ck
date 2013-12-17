// assignment_8_drums.ck
// Walking the Hyperactive Beagle
//
// This module provides a back ground rhythm using a high-hat and a fixed
// pattern.

me.dir(-1) => string rootPath;
rootPath + "/audio/" => string audioPath;

SndBuf hihat => Pan2 drumPan => dac;
1 => drumPan.gain;
-.8 => drumPan.pan;
0 => hihat.gain;
0.2 => float hihatGain;

audioPath + "hihat_01.wav" => hihat.read;
hihat.samples() => hihat.pos;

BPM tempo;
tempo.quarterNote => dur quarter;
tempo.eighthNote => dur eighth;

ClockManager clock;
clock.drumsDuration => dur totalDuration;
clock.fadeDuration  => dur fadeDuration;
false => int fadeComplete;

[ 2., 1, 1, 1, 1, 1, 1, 0 ] @=> float hihatPatternA[];
[ 2., 1, 1, 1, 0, 0, 2, 0 ] @=> float hihatPatternB[];
float hihatChosen[];

spork ~ fade_out(totalDuration-fadeDuration,fadeDuration);

0 => int measureNum;
-1 => int beatNumber;
while (!fadeComplete)
	{
	beatNumber++;
	beatNumber % 8 => int beatInPattern;
	if (beatInPattern == 0) measureNum++;

	if (measureNum % 4 == 0) hihatPatternB @=> hihatChosen;
	                    else hihatPatternA @=> hihatChosen;
	if (hihatChosen[beatInPattern] != 0)
		{
		hihatGain * hihatChosen[beatInPattern] => hihat.gain;
		0 => hihat.pos;
		Math.random2f(.8,1.2) => hihat.rate;
		}

	eighth => now;
	}

// shred to fade out

fun void fade_out(dur wait, dur fadeTime)
	{
	wait => now;
	now => time start;
	while (now - start < fadeTime)
		{
		(now - start) / fadeTime => float fadePosition;
		1-fadePosition => drumPan.gain;
		10::ms => now;
		}
	true => fadeComplete;
	}
