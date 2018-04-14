
#Include xivParser.ahk
ToUnixTimestamp(T) {
	FormatTime Y, %T%, yyyy
	FormatTime D, %T%, YDay
	FormatTime H, %T%, H
	FormatTime M, %T%, m
	FormatTime S, %T%, s
	
	Return (31536000*(Y-1970) + (D+Floor((Y-1972)/4))*86400 + H*3600 + M*60 + S)
}
global keybindFiles := {}
global selectedKeybind
	
SelectKeybindsFile()
{
	ffxivPath := A_MyDocuments . "\My Games\FINAL FANTASY XIV - A Realm Reborn\FFXIV_CHR*"
	keybindFiles := {}
	keybindToSelect := -1
	keybindSetting := settings["LastKeybind"]
	numKeybinds := 0
	
	Loop, %ffxivPath%, 2
	{
		chrPath := A_LoopFileFullPath . "\KEYBIND.DAT"
		Loop %chrPath%, 1
		{
			if(readKeybinds(A_LoopFileFullPath)["PERFORMANCE_MODE_C4"].key1) {
				FileGetTime, FileMod, % A_LoopFileFullPath, A
				FileMod := ToUnixTimestamp(FileMod)
				keybindFiles[FileMod] := A_LoopFileFullPath
				
				if(keybindSetting != "" && keybindToSelect == -1) {
					found := RegExMatch(A_LoopFileFullPath, "FFXIV_CHR[A-Z0-9]+", ffxivChar)
					if(found && keybindSetting == ffxivChar) {
						keybindToSelect := %FileMod%
					}
				}
				numKeybinds += 1
			}
		}
	}
	if(keybindToSelect == -1) {
		; Just pick the last modified keybind file by default
		selectedKeybind := keybindFiles[keybindFiles.MaxIndex()]
	} else {
		selectedKeybind := keybindFiles[keybindToSelect]
	}
	return selectedKeybind
}

KeyModToLabel(mod)
{
	if(mod == 0x10) {
		return "Shift"
	}
	if(mod == 0x11) {
		return "Ctrl"
	}
	if(mod == 0x12) {
		return "Alt"
	}
	return ""
}

GetKeyLetter(binds, key, def) {
	in := false
	for i, v in binds {
		if(i == key) {
			in := true
		}
	}
	if(in && binds[key].key1 != 0) {
		c := Format("{:L}", Chr(binds[key].key1))
		return c
	}
	return def
}
GetModKey(binds, key, def) {
	in := false
	for i, v in binds {
		if(i == key) {
			in := true
		}
	}
	if(in && binds[key].key1 != 0) {
		return binds[key].key1
	}
	return def
}

ReadKeyConfig()
{
	filename := SelectKeybindsFile()
	binds := readKeybinds(filename)
	if(binds._NewEnum()[k, v]) {
	
		NoteKeys["C"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_C4", NoteKeys["C"])
		NoteKeys["C#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_C4_SHARP", NoteKeys["C#"])
		NoteKeys["D"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_D4", NoteKeys["D"])
		NoteKeys["Eb"] := GetKeyLetter(binds, "PERFORMANCE_MODE_D4_SHARP", NoteKeys["Eb"])
		NoteKeys["E"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_E4", NoteKeys["E"])
		NoteKeys["F"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_F4", NoteKeys["F"])
		NoteKeys["F#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_F4_SHARP", NoteKeys["F#"])
		NoteKeys["G"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_G4", NoteKeys["G"])
		NoteKeys["G#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_G4_SHARP", NoteKeys["G#"])
		NoteKeys["A"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_A4", NoteKeys["A"])
		NoteKeys["Bb"] := GetKeyLetter(binds, "PERFORMANCE_MODE_A4_SHARP", NoteKeys["Bb"])
		NoteKeys["B"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_B4", NoteKeys["B"])
				
		higherOctave := GetModKey(binds, "PERFORMANCE_MODE_OCTAVE_HIGHER", 0x10)
		lowerOctave := GetModKey(binds, "PERFORMANCE_MODE_OCTAVE_LOWER", 0x11)
		
		ho := KeyModToLabel(higherOctave)
		lo := KeyModToLabel(lowerOctave)
		
		tempNotes := NoteKeys
		for i, e in ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"] {
			NoteKeys[e . "+1"] := "{" . ho . " down}" . NoteKeys[e] . "{" . ho . " up}"
			NoteKeys[e . "-1"] := "{" . lo . " down}" . NoteKeys[e] . "{" . lo . " up}"
		}
		NoteKeys["C+2"] := "{" . ho . " down}" . GetKeyLetter(binds, "PERFORMANCE_MODE_C5", NoteKeys["C+1"]) . "{" . ho . " up}"
		if(!keybindFile) {
			keybindFile := filename
		}
	}
}