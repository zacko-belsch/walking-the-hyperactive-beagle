// assignment_8_sparkler.ck
// Walking the Hyperactive Beagle
//
// This module provides a "sparkly" sound.  It uses a chord sequence defined by
// the conductor with each chord occupying a whole measure.  During the measure
// the chord is represented by either (1) a single note on the first beat, (2)
// two notes separated by one of three timings, or (3) a fast-paced series of
// many notes.  In all cases the notes are chosen randomly from the current
// chord.

Pan2 sparklePan => dac;
0.3 => float sparkleGain;
0.8 => sparklePan.pan;

ModalBar sparkle[3];
for (0=>int sparkleNum; sparkleNum<sparkle.cap() ; sparkleNum++)
	{
	sparkle[sparkleNum] => sparklePan;
	sparkleGain => sparkle[sparkleNum].gain;
	1 => sparkle[sparkleNum].preset;
	}

BPM tempo;
tempo.quarterNote => dur quarter;
tempo.eighthNote => dur eighth;
4*quarter => dur whole;

11 => int steps;
70::ms => dur stepT;

ClockManager clock;
clock.sparklerDuration => dur totalDuration;
clock.fadeDuration  => dur fadeDuration;
false => int fadeComplete;

ScaleBuilder sb;
sb.scale @=> int scale[];
sb.sparklerMelody @=> int chordSeries[];
sb.third  => int third;
sb.fifth  => int fifth;
sb.octave => int octave;

spork ~ fade_out(totalDuration-fadeDuration,fadeDuration);

// this plays the chord sequence

0 => int measureNum;
-1 => int chordNumber;
while (!fadeComplete)
	{
	measureNum++;
	now + whole => time measureEnd;

	// get the chord for this measure
	(chordNumber+1) % chordSeries.cap() => chordNumber;
	chordSeries[chordNumber] => int chordRootNote;

	// decide whether to do a few notes or a rapid-fire series

	true => int doSingleNotes;
	if (measureNum <= 4)
		true => doSingleNotes;
	else if (measureNum <= 8)
		(chordNumber != 3) => doSingleNotes;
	else
		{
		Math.randomf() => float r;
		(r < .70) => doSingleNotes;
		}

	// play a couple isolated notes for the measure (if selected)

	if (doSingleNotes)
		{
		int notesToPlay;
		dur noteTiming;
		Math.randomf() => float r;
		if (measureNum <= 4) { 1 => notesToPlay;                               }
		else if (r < .40)    { 1 => notesToPlay;                               }
		else if (r < .65)    { 2 => notesToPlay; eighth         => noteTiming; }
		else if (r < .90)    { 2 => notesToPlay; quarter        => noteTiming; }
		else                 { 2 => notesToPlay; quarter+eighth => noteTiming; }

		for (1=>int i ; i<=notesToPlay ; i++)
			{
			choose_from_standard_triad(chordRootNote) => int note;
			scale[note] => Math.mtof => sparkle[0].freq;
			1 => sparkle[0].noteOn;
			if (i<notesToPlay) noteTiming => now;
			}
		}

	// or play a quick series of random notes from the chord, starting on the
	// root, never repeating the same note twice in succession, and ending an
	// octave above the root

	else
		{
		-1 => int sparkleNum;
		-1 => int note;
		for (1=>int step ; step<=steps ; step++)
			{
			(sparkleNum+1) % sparkle.cap() => sparkleNum;
			note => int prevNote;
	
			if (step == 1)
				chordRootNote => note;
			else if (step == steps)
				chordRootNote+octave => note;
			else
				{
				-1 => int reservedNote;
				if (step == steps-1) chordRootNote+octave => reservedNote;
				choose_from_standard_triad(chordRootNote,[prevNote,reservedNote]) => note;
				}
	
			scale[note] => Math.mtof => sparkle[sparkleNum].freq;
			1 => sparkle[sparkleNum].noteOn;
			stepT => now;
			}
		}

	measureEnd => now;
	}

// shred to fade out

fun void fade_out(dur wait, dur fadeTime)
	{
	wait => now;
	now => time start;
	while (now - start < fadeTime)
		{
		(now - start) / fadeTime => float fadePosition;
		for (0=>int sparkleNum; sparkleNum<sparkle.cap() ; sparkleNum++)
			(1-fadePosition) * sparkleGain => sparkle[sparkleNum].gain;
		10::ms => now;
		}
	true => fadeComplete;
	}

//==========
// choose_from_standard_triad--
//    Choose one note from a standard triad chord (root, third, fifth, octave).
//==========

fun int choose_from_standard_triad(int chordRootNote)
    {
	return chordRootNote + choose_from_array([0,third,fifth,octave]);
	}

fun int choose_from_standard_triad(int chordRootNote, int prohibited[])
    {
    int note;
	do
		{
		choose_from_standard_triad(chordRootNote) => note;
		} while (in_array(note,prohibited));
	return note;
	}

//==========
// choose_from_array--
//    Choose one element from an array, at random.
//==========

fun int choose_from_array(int array[])
    {
    return array[Math.random2(0,array.cap()-1)];
    }

//==========
// in_array--
//	Determine whether an array contains a particular value.
//==========

fun int in_array(int val, int array[])
	{
	for (0=>int i ; i<array.cap() ; i++)
		{ if (array[i] == val) return true; }
	return false;
	}

