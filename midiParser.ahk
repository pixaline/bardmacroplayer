#SingleInstance force

swapEndian(i) {
	return (i >> 24) | ((i >> 8) & 0x0000FF00) | ((i << 8) & 0x00FF0000) | (i << 24)
}

readVarShort(file) {
	return readVarSize(file, 2)
}

readVarInt(file) {
	return readVarSize(file, 4)
}

readVarSize(file, size) {
	res := 0
	while(size != 0) {
		byte := file.ReadUCharType()
		size -= 1
		if(byte & 0x80) {
			res += (byte & 0x7F)
			res := res << 7
		} else {
			res += byte
		}
	}
	return res
}

readString(file, len) {
	if(len == -1) {
		len := file.ReadUCharType()
		file.Pos -= 1
	}
	str := file.Read(len)
	return str
}

readDeltaByteCount(file) {
	pos := file.Pos
	byte := file.ReadUCharType()
	byteCount := 1
	while(byte >= 128) {
		byte := file.ReadUCharType()
		byteCount += 1
	}
	file.Pos := pos
	return byteCount
}

charToHex(int, pad = 0) {
	Static hx := "0123456789ABCDEF"
	If !( 0 < int |= 0 )
		Return !int ? "00" : "-" charToHex( -int, pad )

	s := 1 + Floor( Ln( int ) / Ln( 16 ) )
	h := SubStr( "0000000000000000", 1, pad := pad < s ? s : pad < 16 ? pad : 18 )
	u := A_IsUnicode = 1
	Loop % s
		NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4
	Return h
}


bytesToShort(file) {
	return bytesToNumber(file, 2)
}

bytesToInt(file) {
	return bytesToNumber(file, 4)
}

bytesToNumber(file, size) {
	res := "0x"
	while(size != 0) {
		size -= 1
		c := file.ReadUCharType()
		h := charToHex(c, 2)
		res := res . h
	}
	return res + 0
}


class NoteEvent
{
	note := ""
	channel := 0
	deltaMs := 0
	
	GetNoteLetter(octaveOffset := 0) {
		return BardRange[(this.note + 1) - 12 * (3 - octaveOffset)]
	}
	
	__New(n, c := 0) {
		this.note := n
		this.deltaMs := 1
		this.channel := c
		base.__New()
	}
}

class MidiTrack
{
	trackName := ""
	trackTempo := 120
	trackNotes := []
	trackNumNotes := 1
	
	lastNoteDelta := 0
	totalDelta := 0
	
	
	NoteDown(note, channel, dms) {
		if(InStr(this.trackName, "Piano") || true) {
			this.trackNotes[this.trackNumNotes-1].deltaMs := dms
			this.trackNotes.Push(new NoteEvent(note, channel))
			this.trackNumNotes += 1
		}
	}
	
	ParseTrack(timeDivision, file) {
		if(!file)
			return
		id := file.Read(4)
		if(id != "MTrk")
			return false
			
		size := bytesToInt(file)
		
		; begin reading data
		
		metaEventCount := 0
		midiEventCount := 0
		while(size > 0) {
			pos := file.Pos
			deltaCount := readDeltaByteCount(file)
			delta := readVarSize(file, deltaCount)
			
			event := file.ReadUCharType()
			if(lastStatus >= 0x80 && event < 0x80) {
				if(event != lastStatus) {
					event := lastStatus
					file.Pos -= 1
				}
			}
			if(event == 0xFF) {
				metaEvent := file.ReadUCharType()
				p := file.Pos - 1
				len := file.ReadUCharType()
				finalPos := file.Pos + len
				if(metaEvent == 0x00) {
					; seq num
					num := readVarShort(file)
				}
				else if(metaEvent == 0x01) {
					; text
					text := readString(file, len)
				}
				else if(metaEvent == 0x02) {
					; copyright
					text := readString(file, len)
				}
				else if(metaEvent == 0x03) {
					; track name
					this.trackName := readString(file, len)
				}
				else if(metaEvent == 0x04) {
					; intrument name
					name := readString(file, len)
				}
				else if(metaEvent == 0x05) {
					; lyric
					text := readString(file, len)
				}
				else if(metaEvent == 0x06) {
					; marker
					text := readString(file, len)
				}
				else if(metaEvent == 0x07) {
					; cue point
					text := readString(file, len)
				}
				else if(metaEvent == 0x08) {
					; prog name
					text := readString(file, len)
				}
				else if(metaEvent == 0x09) {
					; device name
					name := readString(file, len)
				}
				else if(metaEvent == 0x0A) {
					; ???
					name := readString(file, len)
				}
				else if(metaEvent == 0x0C) {
					; ???
					name := readString(file, len)
				}
				else if(metaEvent == 0x20) {
					; chan prefix
					port := file.ReadUCharType()
				}
				else if(metaEvent == 0x21) {
					; port
					port := file.ReadUCharType()
				}
				else if(metaEvent == 0x2F) {
					; end of track
				}
				else if(metaEvent == 0x51) {
					; tempo
					this.trackTempo := 60000000 / bytesToNumber(file, 3)
				}
				else if(metaEvent == 0x54) {
					; smtpe offset
					hr := file.ReadUCharType()
					mn := file.ReadUCharType()
					se := file.ReadUCharType()
					fr := file.ReadUCharType()
					ff := file.ReadUCharType()
				}
				else if(metaEvent == 0x58) {
					; time signature
					nn := file.ReadUCharType()
					dd := file.ReadUCharType()
					cc := file.ReadUCharType()
					bb := file.ReadUCharType()
				}
				else if(metaEvent == 0x59) {
					; key signature
					sf := file.ReadUCharType()
					mi := file.ReadUCharType()
				}
				else {
					data := file.Read(len)
					pos := file.Pos
					MsgBox, Unknown event: %event% and %metaEvent% with data %data% at %pos%
				}
				file.Pos := finalPos
				metaEventCount += 1
				
			} else if(event >= 0xF0 && event <= 0xF7) {
				len := file.ReadUCharType()
				eventData := file.Read(len)
				lastStatus := 0
			} else {
				if(event >= 0x80) {
					lastStatus := event
					this.lastNoteDelta += delta
					this.totalDelta += delta
					if(lastStatus <= 0x8F) {
						; Note off
						note := file.ReadUCharType()
						vel := file.ReadUCharType()
						channel := lastStatus - 0x80 + 1
						
					} else if(lastStatus <= 0x9F) {
						; Note on
						note := file.ReadUCharType()
						vel := file.ReadUCharType()
						channel := lastStatus - 0x90 + 1
						if(vel != 0) {
							del := this.lastNoteDelta * (60000 / (this.trackTempo * timeDivision))
							this.lastNoteDelta := 0
							this.NoteDown(note, channel, del)
						}
						
					} else if(lastStatus <= 0xAF) {
						; poly key pressure
						note := file.ReadUCharType()
						pressure := file.ReadUCharType()
						
					} else if(lastStatus <= 0xBF) {
						; controller change
						num := file.ReadUCharType()
						val := file.ReadUCharType()
						; set volume etc
						
					} else if(lastStatus <= 0xCF) {
						; program change
						val := file.ReadUCharType()
						; MsgBox, Program change: %val%
						
					} else if(lastStatus <= 0xDF) {
						; chan key pressure
						val := file.ReadUCharType()
						; MsgBox, Key pressure: %val%
						
					} else if(lastStatus <= 0xEF) {
						; pitch bend
						val := file.ReadUCharType()
						val2 := file.ReadUCharType()
					}
				}
				midiEventCount += 1
			}
			size -= (file.Pos - pos)
		}
		file.Pos += size
		; MsgBox, %id% len %size% meventcnt %metaEventCount% and %midiEventCount%
	}
	
	__New(timeDivision, file) {
		this.ParseTrack(timeDivision, file)
		base.__New()
	}
}

class MidiFile
{
	midiFile := 0
	midiFormat := 0
	midiNumTracks := 0
	midiTimeDivision := 0
	midiTracks := {}
	
	ParseHeader() {
		if(!this.midiFile)
			return false
		if(this.midiFile.Read(4) != "MThd")
			return false
		if(readVarInt(this.midiFile) != 6)
			return false
		
		this.midiFormat := bytesToShort(this.midiFile)
		this.midiNumTracks := bytesToShort(this.midiFile)
		this.midiTimeDivision := bytesToShort(this.midiFile)
		
		len := this.midiFile.Length
		fmt := this.midiFormat
		nt := this.midiNumTracks
		td := this.midiTimeDivision
				
		Loop %nt% {
			this.midiTracks[A_Index] := new MidiTrack(td, this.midiFile)
		}
		
		return true
	}
	
	__New(filename) {
		this.midiFile := FileOpen(filename, "r-d")
		if(this.midiFile) {
			size := this.midiFile.Length
			this.ParseHeader()
			this.midiFile.Close()
		}
		if(size) {
			msg := Format("{1:s} ({2:d} bytes), {3:d} tracks, {4:d} PPQ`n`n", filename, size, this.midiTracks.Length(), this.midiTimeDivision)
			Loop % this.midiNumTracks {
				track := this.midiTracks[A_Index]
				msg .= Format("#{1:d} - {2:s}, {3:d}`n", A_Index, track.trackName, track.trackTempo)
				for i, v in track.trackNotes {
					msg .= Format("{1:s} +{2:d} {3:d}`n", v.note, v.deltaMs, v.channel)
				}
			}
			; MsgBox % msg
		}
		base.__New()
	}
}
