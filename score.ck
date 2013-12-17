// assignment_8_score.ck
// Walking the Hyperactive Beagle
//
// This module is what drives the whole composition

// debug flags
// false represents the normal state for most of these settings; setting them
// them to true enables or disables certain items in the program

false => int debugTiming;       // report timing info (or don't)
false => int goSlow;            // playback at a slower speed (or don't)
true  => int infinitePlay;      // playback forever (or don't)
false => int stifleIntro;       // prevent the intro from playing (or don't)
false => int stiflePiano;       // prevent the piano from playing (or don't)
false => int stifleSparkle;     // prevent the sparkler from playing (or don't)
false => int stifleDrums;       // prevent the drums from playing (or don't)
false => int stifleMelody;      // prevent the melody from playing (or don't)

// set up tempo to be used by other modules

BPM tempo;
192 => float beat;  // quarter notes per minute
if      (goSlow == 1) beat*3/4 => beat;
else if (goSlow >= 2) beat/2   => beat;
else if (goSlow <  0) beat*5/4 => beat;
tempo.tempo(beat);
tempo.quarterNote => dur quarter;
tempo.eighthNote => dur eighth;
4*quarter => dur whole;

// set up the total duration timing

ClockManager clock;
60::second => dur totalDuration;
if      (goSlow == 1) totalDuration*4/3 => totalDuration;
else if (goSlow >= 2) totalDuration*2   => totalDuration;
else if (goSlow <  0) totalDuration*4/5 => totalDuration;
clock.set_clock("fade", 1::second);

// set up a scale (six octaves) to be used by other modules;  we print the
// array contents to show that we have met the notes requirements

ScaleBuilder sb;
note_to_midi("C3") => int midiC;
sb.build_scale(/*root*/ midiC-24,/*numNotes*/ 43) @=> int scale[];
sb.octave => int octave;

// set up melodies to be used by other modules;  the following note names are
// indexes into our scale array, for notes in the middle octave

2*octave+0=>int C;  2*octave+4=>int G;
2*octave+1=>int D;  2*octave+5=>int A;
2*octave+2=>int E;  2*octave+6=>int B;
2*octave+3=>int F;
octave =>int o;     // note modifier for one octave
2*octave =>int oo;  // note modifier for two octaves
-1=>int rest;       // note name for a rest

sb.set_melody("piano",    [A-2*octave, A-2*octave, F-2*octave, G-2*octave]);
sb.set_melody("sparkler", [A+octave,   C+2*octave, F+2*octave, G+2*octave]);

64*3   => int _M;   // (ticks per measure for playback, 3 ticks per 64th note)
_M/2   => int _2;   // half note
_M/4   => int _4;   // quarter note
_M/8   => int _8;   // eighth note
_M/16  => int _16;  // sixteenth note
_4+_8  => int _4d;  // dotted quarter note
_8+_16 => int _8d;  // dotted eighth note

[ A,_M+_4   ,                                                 // measure 1
              G,_8      , A,_8       , C+o,_4d   , B,_8     ,
  A,_2      , E,_2+_2   ,                                     // measure 3
                          D,_4       , G,_4                 ,
  E,_M+_4   ,                                                 // measure 5
              B-o,_8    , C,_8       , D,_4      , C,_4     ,
  A-o,_M+_2                                                 , // measure 7
              rest,_2                                       ,

  A+o,_M+_4 ,                                                 // measure 9
              G+o,_8d   , A+o,_16   , C+oo,_4d  , B+o,_8    ,
  A+o,_2    , D+o,_16   , E+o,_2-_16+_2                     , // measure 11
                          C+o,_4d   , D+o,_8                , 
  F+o,_2    , E+o,_2+_4 ,                                     // measure 13
              B-o+o,_8  , C+o,_8    , D+o,_4    , C+o,_4    ,
  A,_M+_M                                                   ] // measure 15
  @=> int melody1[];


[ rest,6*_M                                                 , // measures 1..6
  rest,_4d  , F,_8      , E,_2+_2                           , // measure 7
              rest,_2                                       ,
  rest,2*_M                                                 , // measures 9..10
  rest,2*_M                                                 , // measures 11..12
  rest,2*_M                                                 , // measures 13..14
  rest,_4d  , C+o,_8    , E+o,_2+_M                         ] // measure 15
  @=> int melody2[];

sb.set_melody("voice1", melody1);
sb.set_melody("voice2", melody2);

// set up paths to chuck files

me.dir() + "/intro.ck"        => string introPath;
me.dir() + "/piano_rhythm.ck" => string pianoPath;
me.dir() + "/sparkler.ck"     => string sparklePath;
me.dir() + "/drums.ck"        => string drumPath;
me.dir() + "/melody.ck"       => string melodyPath;

// conduct our ochestra

now => time start;

if (!stifleIntro)
	{
	if (debugTiming) <<< (now-start)/second,"starting intro" >>>;
	Machine.add(introPath);
	4::second => now;
	}

if (!stiflePiano)
	{
	if (debugTiming) <<< (now-start)/second,"starting piano" >>>;
	if (infinitePlay) clock.set_clock("piano", 1::week);
	             else clock.set_clock("piano", totalDuration-(now-start));
	Machine.add(pianoPath);
	4*whole => now;
	}

if (!stifleSparkle)
	{
	if (debugTiming) <<< (now-start)/second,"starting sparkler" >>>;
	if (infinitePlay) clock.set_clock("sparkler", 1::week);
	             else clock.set_clock("sparkler", totalDuration-(now-start));
	Machine.add(sparklePath);
	4*whole => now;
	}

if (!stifleDrums)
	{
	if (debugTiming) <<< (now-start)/second,"starting drums" >>>;
	if (infinitePlay) clock.set_clock("drums", 1::week);
	             else clock.set_clock("drums", totalDuration-(now-start));
	Machine.add(drumPath);
	4*whole => now;
	}

if (!stifleMelody)
	{
	if (debugTiming) <<< (now-start)/second,"starting melody" >>>;
	Machine.add(melodyPath);
	}

// if we're playing forever, restart the melody every so often

if (infinitePlay)
	{
	while (!stifleMelody)
		{
		40*whole => now;
		if (debugTiming) <<< (now-start)/second,"restarting melody" >>>;
		Machine.add(melodyPath);
		}
	}

// otherwise, just wait around a while to report timing;  note that we
// shouldn't need to remove the shreds, since they all quit on their own

else
	{
	while (now < start + totalDuration + 2::second)
		{
		1::second =>  now;
		if (debugTiming) <<< (now-start)/second,"loitering" >>>;
		}
	}

//==========
// note_to_midi--
//	Convert a string describing a note to a MIDI note number.
//
// Acknowledgement: loosely based on Simple-pitch.ck provided by the instructors
//==========

fun int note_to_midi(string noteName)
	{
	// define midi note numbers for A thru G in octave zero
	//A  B  C  D  E  F  G
	[21,23,12,14,16,17,19] @=> int octaveZero[];

	// look up first character in octave

	noteName.charAt(0) - 65 => int noteIx;
	if ((noteIx < 0) || (noteIx >= octaveZero.cap()))
		{
		<<< "note_to_midi","illegal note",noteName >>>;
		return -1;
		}

	octaveZero[noteIx] => int note;

	// count the number of sharps and flats, and detect an octave setting

	0 => int sharps;
	0 => int flats;
	0 => int octave;
	false => int negative;
	for (1=>int scanIx; scanIx<noteName.length() ; scanIx++)
		{
		false => int badChar;
		if      (noteName.charAt(scanIx) == '#') sharps++;
		else if (noteName.charAt(scanIx) == 's') sharps++;
		else if (noteName.charAt(scanIx) == 'b') flats++;
		else if (noteName.charAt(scanIx) == 'f') flats++;
		else if (noteName.charAt(scanIx) == '-') true => negative;
		else if (noteName.charAt(scanIx) <  '0') true => badChar;
		else if (noteName.charAt(scanIx) >  '9') true => badChar;
		else 10*octave + (noteName.charAt(scanIx)-48) => octave;

		if (badChar)
			{
			<<< "note_to_midi","illegal note",noteName >>>;
			return -1;
			}
		}

	if (negative) -octave => octave;
	note + sharps - flats + 12*octave => note;
	if ((note < 0) || (note > 127))
		{
		<<< "note_to_midi","note out of midi range",noteName >>>;
		return -1;
		}

	return note;
	}

