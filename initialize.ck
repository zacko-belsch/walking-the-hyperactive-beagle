// assignment_8_initialize.ck
// Walking the Hyperactive Beagle
//
// This module loads our class definitions and launches the score file

Machine.add(me.dir()+"/BPM.ck");           // beat timer class
Machine.add(me.dir()+"/ClockManager.ck");  // clock manager class
Machine.add(me.dir()+"/ScaleBuilder.ck");  // scale array class

Machine.add(me.dir()+"/score.ck");         // score file
