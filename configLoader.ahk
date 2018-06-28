
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

global keyTranslate := {"82":"BB","83":"BC","84":"BD","85":"BE","86":"BF","87":"BA","88":"C0","89":"DB","8A":"DC","8B":"DD","8C":"DE","8D":"DF"}
; 82 BB  =
; 83 BC  ,
; 84 BD  -
; 85 BE  .
; 86 BF  /
; 87 BA  ¨ ;
; 88 C0  ö '
; 89 DB  [ ´
; 8A DC  §
; 8B DD  å ]
; 8C DE  ä #
; 8D DF  `

	
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
				; Modification date is the only one returning with milliseconds
				FileGetTime, FileMod, % A_LoopFileFullPath, M
				FileMod := ToUnixTimestamp(FileMod)
				keybindFiles[FileMod] := A_LoopFileFullPath
				
				if(keybindSetting != "" && keybindToSelect == -1) {
					found := RegExMatch(A_LoopFileFullPath, "FFXIV_CHR[A-Z0-9]+", ffxivChar)
					if(found && keybindSetting == ffxivChar) {
						keybindToSelect := FileMod
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

GetKeyLetter(binds, key, def := 0) {
	in := false
	for i, v in binds {
		if(i == key) {
			in := true
		}
	}
	if(in && binds[key].key1 != 0) {
		c := SubStr(binds[key].key1, 3)
		for i, v in keyTranslate {
			if(i == c) {
				c := v
			}
		}
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

class NoteKey {
	key := 0
	mod := 0
	__New(k, m := 0) {
		this.key := k
		this.mod := m
	}
	DownMod() {
		if(this.mod) {
			return "{" . this.mod . " down}"
		}
		return ""
	}
	Down() {
		s := "{vk" . this.key . " down}"
		return s
	}
	UpMod() {
		if(this.mod) {
			return "{" . this.mod . " up}"
		}
		return ""
	}
	Up() {
		s := "{vk" . this.key . " up}"
		return s
	}
}

ReadKeyTest()
{
	filename := SelectKeybindsFile()
	binds := readKeybinds(filename)
	c :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C4")
	d :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D4")
	e :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_E4")
	f :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F4")
	g :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G4")
	a :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A4")
	b :=    GetKeyLetter(binds, "PERFORMANCE_MODE_EX_B4")

	MsgBox, C: %c%`nD: %d%`nE: %e%`nF: %f%`nG: %g%`nA: %a%`nB: %b%
}


ReadKeyConfig()
{
	filename := SelectKeybindsFile()
	binds := readKeybinds(filename)
	if(binds._NewEnum()[k, v]) {
	
		key := {}
		tkey := GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C3", 0)
		if(tkey == 0) {
			; Default modifier key based layout
			key["C"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_C4", DefaultNoteKeys["C"])
			key["C#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_C4_SHARP", DefaultNoteKeys["C#"])
			key["D"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_D4", DefaultNoteKeys["D"])
			key["Eb"] := GetKeyLetter(binds, "PERFORMANCE_MODE_D4_SHARP", DefaultNoteKeys["Eb"])
			key["E"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_E4", DefaultNoteKeys["E"])
			key["F"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_F4", DefaultNoteKeys["F"])
			key["F#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_F4_SHARP", DefaultNoteKeys["F#"])
			key["G"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_G4", DefaultNoteKeys["G"])
			key["G#"] := GetKeyLetter(binds, "PERFORMANCE_MODE_G4_SHARP", DefaultNoteKeys["G#"])
			key["A"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_A4", DefaultNoteKeys["A"])
			key["Bb"] := GetKeyLetter(binds, "PERFORMANCE_MODE_A4_SHARP", DefaultNoteKeys["Bb"])
			key["B"] :=  GetKeyLetter(binds, "PERFORMANCE_MODE_B4", DefaultNoteKeys["B"])
			key["C+1"] := GetKeyLetter(binds, "PERFORMANCE_MODE_C5", key["C+1"])
					
			higherOctave := GetModKey(binds, "PERFORMANCE_MODE_OCTAVE_HIGHER", 0x10)
			lowerOctave := GetModKey(binds, "PERFORMANCE_MODE_OCTAVE_LOWER", 0x11)
			
			ho := KeyModToLabel(higherOctave)
			lo := KeyModToLabel(lowerOctave)
			
			for i, e in ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"] {
				NoteKeys[e] := new NoteKey(key[e])
				NoteKeys[e . "+1"] := new NoteKey(key[e], ho)
				NoteKeys[e . "-1"] := new NoteKey(key[e], lo)
			}
			NoteKeys["C+2"] := new NoteKey(key["C+1"], ho)
		} else {
			NoteKeys["C-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C3"))
			NoteKeys["C#-1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C3_SHARP"))
			NoteKeys["D-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D3"))
			NoteKeys["Eb-1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D3_SHARP"))
			NoteKeys["E-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_E3"))
			NoteKeys["F-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F3"))
			NoteKeys["F#-1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F3_SHARP"))
			NoteKeys["G-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G3"))
			NoteKeys["G#-1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G3_SHARP"))
			NoteKeys["A-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A3"))
			NoteKeys["Bb-1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A3_SHARP"))
			NoteKeys["B-1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_B3"))
			NoteKeys["C"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C4"))
			NoteKeys["C#"] :=   new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C4_SHARP"))
			NoteKeys["D"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D4"))
			NoteKeys["Eb"] :=   new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D4_SHARP"))
			NoteKeys["E"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_E4"))
			NoteKeys["F"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F4"))
			NoteKeys["F#"] :=   new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F4_SHARP"))
			NoteKeys["G"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G4"))
			NoteKeys["G#"] :=   new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G4_SHARP"))
			NoteKeys["A"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A4"))
			NoteKeys["Bb"] :=   new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A4_SHARP"))
			NoteKeys["B"] :=    new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_B4"))
			NoteKeys["C+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C5"))
			NoteKeys["C#+1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C5_SHARP"))
			NoteKeys["D+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D5"))
			NoteKeys["Eb+1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_D5_SHARP"))
			NoteKeys["E+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_E5"))
			NoteKeys["F+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F5"))
			NoteKeys["F#+1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_F5_SHARP"))
			NoteKeys["G+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G5"))
			NoteKeys["G#+1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_G5_SHARP"))
			NoteKeys["A+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A5"))
			NoteKeys["Bb+1"] := new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_A5_SHARP"))
			NoteKeys["B+1"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_B5"))
			NoteKeys["C+2"] :=  new NoteKey(GetKeyLetter(binds, "PERFORMANCE_MODE_EX_C6"))
		}
		if(!keybindFile) {
			keybindFile := filename
		}
	}
}