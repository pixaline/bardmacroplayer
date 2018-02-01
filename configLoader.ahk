
#Include xivParser.ahk
ToUnixTimestamp(T) {
	FormatTime Y, %T%, yyyy
	FormatTime D, %T%, YDay
	FormatTime H, %T%, H
	FormatTime M, %T%, m
	FormatTime S, %T%, s
	
	Return (31536000*(Y-1970) + (D+Floor((Y-1972)/4))*86400 + H*3600 + M*60 + S)
}
SelectKeybindsFile()
{
	ffxivPath := A_MyDocuments . "\My Games\FINAL FANTASY XIV - A Realm Reborn\FFXIV_CHR*"
	keybindFiles := {}
	numKeybinds := 0
	Loop, %ffxivPath%, 2
	{
		chrPath := A_LoopFileFullPath . "\KEYBIND.DAT"
		Loop %chrPath%, 1
		{
			if(readKeybinds(A_LoopFileFullPath)["PERFORMANCE_MODE_C4"].key1) {
				FileGetTime, FileMod, A_LoopFileFullPath, A
				FileMod := ToUnixTimestamp(FileMod)
				keybindFiles[FileMod] := A_LoopFileFullPath
				numKeybinds += 1
			}
		}
	}
	filename := keybindFiles[keybindFIles.MaxIndex()]
	if(numKeybinds > 1) {
		MsgBox, Lots of keybinds (%numKeybinds%). Choosing the most recent one.`n%filename%
	}
	return filename
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

ReadKeyConfig()
{
	filename := SelectKeybindsFile()
	binds := readKeybinds(filename)
	if(binds._NewEnum()[k, v]) {
	
		NoteKeys["C"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_C4"].key1))
		NoteKeys["C#"] := Format("{:L}", Chr(binds["PERFORMANCE_MODE_C4_SHARP"].key1))
		NoteKeys["D"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_D4"].key1))
		NoteKeys["Eb"] := Format("{:L}", Chr(binds["PERFORMANCE_MODE_D4_SHARP"].key1))
		NoteKeys["E"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_E4"].key1))
		NoteKeys["F"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_F4"].key1))
		NoteKeys["F#"] := Format("{:L}", Chr(binds["PERFORMANCE_MODE_F4_SHARP"].key1))
		NoteKeys["G"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_G4"].key1))
		NoteKeys["G#"] := Format("{:L}", Chr(binds["PERFORMANCE_MODE_G4_SHARP"].key1))
		NoteKeys["A"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_A4"].key1))
		NoteKeys["Bb"] := Format("{:L}", Chr(binds["PERFORMANCE_MODE_A4_SHARP"].key1))
		NoteKeys["B"] :=  Format("{:L}", Chr(binds["PERFORMANCE_MODE_B4"].key1))
		
		higherOctave := binds["PERFORMANCE_MODE_OCTAVE_HIGHER"].key1
		lowerOctave := binds["PERFORMANCE_MODE_OCTAVE_LOWER"].key1
		
		ho := KeyModToLabel(higherOctave)
		lo := KeyModToLabel(lowerOctave)
		
		tempNotes := NoteKeys
		for i, e in ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"] {
			NoteKeys[e . "+1"] := "{" . ho . " down}" . NoteKeys[e] . "{" . ho . " up}"
			NoteKeys[e . "-1"] := "{" . lo . " down}" . NoteKeys[e] . "{" . lo . " up}"
		}
		if(!keybindFile) {
			keybindFile := filename
			ShowParsedKeyboard()
		}
	}
}