// assignment_8_BPM.ck
// Walking the Hyperactive Beagle
//
// This module defines a class to manage our tempo
//
// acknowledgement: this is the BPM class from the instructors, except I
// changed the declaration of myDuration to prevent crashing

public class BPM
	{
	// global variables
	static dur myDuration[];
	static dur quarterNote, eighthNote, sixteenthNote, thirtysecondNote;

	fun void tempo(float beat)
		{
		// beat is BPM, example 120 beats per minute

		60.0/(beat) => float SPB; // seconds per beat
		SPB :: second => quarterNote;
		quarterNote*0.5 => eighthNote;
		eighthNote*0.5 => sixteenthNote;
		sixteenthNote*0.5 => thirtysecondNote;

		// store data in array
		[quarterNote, eighthNote, sixteenthNote, thirtysecondNote] @=> myDuration;
		}
	}
