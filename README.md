# FFXIV Bard Macro Player
This is an utility to play 3 octave arrangements from text files and (attempted) midi files using the Autohotkey language. It loads and parses ffxiv's KEYBIND.DAT file (autodetected by access time) to find the keystrokes for the Performance actions, loads and parses the text/midi files and converts it to millisecond time format, and then implements a note player that sends the correct keystrokes to the FFXIV window. This only sends keystrokes and does not read the game memory at all, so you shouldn't get banned for using it.

## Usage
Make a folder to contain BardMacroPlayer.exe, BardMacroPlayer.ini (optional) and a subdirectory called "songs". You should put midi (.mid) files and bard arrangement songs (.txt) in there. The program should be self-explanatory enough. You can hide the program while in-game by pressing the Insert key (default).

## Midi files
Midi files is an experimental feature. It should be able to pick out suitable tracks to play and perform them without problems. However, there might be some tempo issues that needs fixing. 

## Bard arrangement file format
These are simple text files designed to be easily edited in notepad. Notes are depicted as they are in-game [C, C#, D, Eb, E, F, F#, G, G#, A, Bb, B] and the upper and lower octave (appending [+1] and [-1] to the note). Pauses are depicted as forward slashes [/], which can be concatenated together. Each pause has a default duration of 100 milliseconds. Note that the C+1 note isn't available.

You can set some settings specific to each arrangement by writing them as individual lines anywhere in the file.
* ``p`` followed by a number sets the pause duration in milliseconds. ``p100`` turns the ``////`` pause in to a 400 millisecond pause.
* ``d`` followed by a number adds a delay in milliseconds to each note. ``d50`` makes each note take 50 more milliseconds to perform. This can be used to slow down/speed up the composition.

## BardMacroPlayer.ini
Configuration file. Requires application reload.
* ``ExitConfirmation=0`` to enable/disable the exit prompt.
* ``HideHotkey=Insert`` to toggle the music player visiblity. Must be focused to FFXIV to use it.

## License
MIT
