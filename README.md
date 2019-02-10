# Important Update
**This tool is no longer being developed. It has been replaced by [Bard Music Player](http://bmp.sqnya.se), the sequel with much more functionality and stability for playing back Midi files in exchange for dropping Text file arrangement support.** The project will still exist in an archived form here, but support will no longer be given. I cannot guarantee the functionality of this program across major game patches. Though, AHK is a pretty simple language. Feel free to fork this.

---

---

## FFXIV Bard Macro Player
This is an utility to play 3 octave arrangements from text files and midi files using the Autohotkey language. It loads and parses ffxiv's KEYBIND.DAT file (autodetected by access time) to find the keystrokes for the Performance actions, loads and parses the text/midi files and converts it to millisecond time format, and then implements a note player that sends the correct keystrokes to the FFXIV window.

## Usage
[Download latest version](https://github.com/parulina/bardmacroplayer/releases)

Make a folder to contain BardMacroPlayer.exe, BardMacroPlayer.ini (optional) and a subdirectory called "songs". You should put midi (.mid) files and bard arrangement songs (.txt) in there. The program should be self-explanatory enough. You can hide the program while in-game by pressing the Insert key (default). The stop button reloads the selected song/track. Below the stop/play button is a small slider which offsets the midi track range. It's meant to be used if your midi file plays too high or too low for your bard's 3-octave range, which ranges from C3 to C5 (C6 for the C+2 note). To apply the octave offset, reload the file with the stop button after adjusting the slider.

## Midi files
Midi files is an experimental feature. It should be able to pick out suitable tracks to play and perform them without problems. However, there might be some issues due to the complexity of the midi file format. In such case, please open an issue and attach the midi file with problems.
The program scans and lists midi tracks available to play, as indicated by a number next to the filename. Tracks are what usually separates left to right hand as well as different instruments. If it lists many tracks, be aware that the midi file may be complex to play. As mentioned above, the octave slider is used to load midi tracks with an offset. If you don't know what offset you should have, just try with all the steps, or analyze which keys are being played by a midi player such as [MidiPiano](http://www.midipiano.net/).

## Bard arrangement file format
These are simple text files designed to be easily edited in notepad. Notes are depicted as they are in-game [C, C#, D, Eb, E, F, F#, G, G#, A, Bb, B] and the upper and lower octave (appending [+1] and [-1] to the note) as well as the single [C+2]. Pauses are depicted as forward slashes [/], which can be concatenated together. Each pause and newline has a default duration of 100 milliseconds. Notes and pauses should be separated by one space.

You can set some settings specific to each arrangement by writing them as individual lines anywhere in the file.
* ``p`` followed by a number sets the pause duration in milliseconds. ``p100`` turns the ``////`` pause in to a 400 millisecond pause.
* ``d`` followed by a number adds a delay in milliseconds to each note. ``d50`` makes each note take 50 more milliseconds to perform. This can be used to slow down/speed up the composition.

## BardMacroPlayer.ini
Configuration file. Requires application reload.
* ``ExitConfirmation=0`` to enable/disable the exit prompt.
* ``HideHotkey=Insert`` to toggle the music player visiblity. Must be focused to FFXIV to use it.

## License
MIT
