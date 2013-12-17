// assignment_8_ScaleBuilder.ck
// Walking the Hyperactive Beagle
//
// This module defines a class to manage our scale and melodies

public class ScaleBuilder
	{
	static int scale[];
	static int melodyVoice1[];
	static int melodyVoice2[];
	static int pianoMelody[];
	static int sparklerMelody[];
	static int third;
	static int fifth;
	static int octave;

	fun int[] build_scale(int root,int numNotes)
		{
		return this.build_scale("ionian",root,numNotes);
		}

	fun int[] build_scale(string mode,int root,int numNotes)
		{
		mode.lower() => string lowMode;
		if      (lowMode == "i")   "ionian"     => lowMode;
		else if (lowMode == "ii")  "dorian"     => lowMode;
		else if (lowMode == "iii") "phrygian"   => lowMode;
		else if (lowMode == "iv")  "lydian"     => lowMode;
		else if (lowMode == "v")   "mixolydian" => lowMode;
		else if (lowMode == "vi")  "aeolian"    => lowMode;
		else if (lowMode == "vii") "locrian"    => lowMode;

		int magic;
		if      (lowMode == "ionian")     7*root + 5 => magic;
		else if (lowMode == "dorian")     7*root + 3 => magic;
		else if (lowMode == "phrygian")   7*root + 1 => magic;
		else if (lowMode == "lydian")     7*root + 6 => magic;
		else if (lowMode == "mixolydian") 7*root + 4 => magic;
		else if (lowMode == "aeolian")    7*root + 2 => magic;
		else if (lowMode == "locrian")    7*root     => magic;
		else
			{
			<<< "(in ScaleBuilder)","mode="+mode,"is not recognized" >>>;
			me.exit();
			}

		int _scale[numNotes] @=> scale;
		for (0=>int i ; i<numNotes ; i++)
			(12*i+magic)/7 => _scale[i];

		2 => third;
		4 => fifth;
		7 => octave;

		return _scale;
		}

	fun void set_melody(string which, int melody[])
		{
		if      (which == "voice1")   melody @=> melodyVoice1;
		else if (which == "voice2")   melody @=> melodyVoice2;
		else if (which == "piano")    melody @=> pianoMelody;
		else if (which == "sparkler") melody @=> sparklerMelody;
		}
	}
