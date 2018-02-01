
class txtNote {
	note := ""
	deltaMs := 0
}

class TxtFile
{
	notes := []
	numNotes := 1
	trackIndex := 1
	
	__New(filename) {
		file := FileOpen(filename, "r-d")
		if(file) {
			msTemp := 0
			pauseMs := 100
			delay := 0
			while(!file.AtEOF) {
				s := RegExReplace(file.ReadLine(), "\r\n$","")
				i := SubStr(s, 1, 1)
				if(i == "p") {
					pauseMs := SubStr(s, 2)
					continue
				}
				if(i == "d") {
					delay := SubStr(s, 2)
					continue
				}
				Loop, parse, s, %A_Space%
				{
					if(InStr(A_LoopField, "/")) {
						; Parse as pause
						n := 0
						Loop, parse, A_LoopField
						{
							n += 1
						}
						msTemp += pauseMs * n
					}
					else if(Ord(A_LoopField) > 32) {
						; Parse as note
						note := new txtNote()
						note.note := A_LoopField
						note.deltaMs := msTemp + delay
						msTemp := 0
						this.notes.Push(note)
						this.numNotes += 1
					} else {
						; Treat newline as a single / so you can hear it
						msTemp += pauseMs
					}
				}
			}
			file.Close()
		}
		base.__New()
	}
}