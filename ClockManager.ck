// assignment_8_ClockManager.ck
// Walking the Hyperactive Beagle
//
// This module defines a class to manage our overall clock

public class ClockManager
	{
	static dur fadeDuration;
	static dur pianoDuration;
	static dur sparklerDuration;
	static dur drumsDuration;

	fun void set_clock(string which, dur duration)
		{
		if      (which == "fade")     duration => fadeDuration;
		else if (which == "piano")    duration => pianoDuration;
		else if (which == "sparkler") duration => sparklerDuration;
		else if (which == "drums")    duration => drumsDuration;
		}
	}
