#Include midiParser.ahk
#Include txtParser.ahk

class BasePlayer
{
	filename := ""
	playing := false
	playObject := 0
	noteIndex := 1
	noteCallback := 0
	updateCallback := 0
	
	octaveShift := 0
	speedShift := 1
	
	Play() {
		this.playing := true
		this.updateCallback.Call()
	}
	IsPlaying() {
		return this.playing
	}
	Pause() {
		this.playing := false
		obj := this.playObject
		if(obj) {
			SetTimer % obj, Off
		}
		this.updateCallback.Call()
	}
	Stop() {
		this.Pause()
		this.noteIndex := 1
		this.updateCallback.Call()
	}
	
	NextPlayTimer() {
		this.noteIndex += 1
	}
	
	PlayNote(note) {
		this.noteCallback.Call(note)
	}
	
	__New(){
		this.Stop()
		base.__New()
	}
}

class TxtPlayer extends BasePlayer
{
	txt := 0
	trackIndex := 0
	
	Play() {
		base.Play()
		this.NextPlayTimer()
	}
	
	GetNumNotes() {
		return this.txt.numNotes
	}
	
	GetProgress() {
		return ((this.noteIndex-1) / (this.GetNumNotes()-1))
	}
	SetProgress(prog) {
		this.noteIndex := Floor(this.GetNumNotes() * prog)
		if(this.noteIndex < 1 || this.noteIndex >= this.GetNumNotes()) {
			this.noteIndex := 1
		}
	}

	GetNote(note := -1) {
		if(note == -1) {
			note := this.noteIndex
		}
		return this.txt.notes[note]
	}
	
	NextPlayTimer() {
		if(this.noteIndex >= this.GetNumNotes()) {
			this.Stop()
			
		} else if(this.IsPlaying()) {
			if(this.noteIndex == 1) {
				this.PlayLoop()
				return
			}
			note := this.GetNote()
			ms := -Abs(note.deltaMs) / this.speedShift
			obj := this.playObject
			SetTimer % obj, Delete
			SetTimer % obj, % ms
		}
	}
	
	PlayLoop() {
		if(base.IsPlaying()) {
			base.PlayNote(this.GetNote().note)
			base.NextPlayTimer()
			this.NextPlayTimer()
		}
	}
	
	__New(file){
		this.playObject := ObjBindMethod(this, "PlayLoop")
		if(file) {
			this.txt := new TxtFile(file)
			this.filename := file
		}
		base.__New()
	}
}

class MidiPlayer extends BasePlayer
{
	midi := 0
	trackIndex := 1
	
	Play() {
		base.Play()
		this.NextPlayTimer()
	}
	
	GetTrack() {
		if(this.trackIndex < 1 || this.midi.midiNumTracks <= 0)
			return
		if(this.trackIndex > this.midi.midiNumTracks)
			return
		track := this.midi.midiTracks[this.trackIndex]
		return track
	}
	GetProgress() {
		return ((this.noteIndex-1) / (this.GetNumNotes()-1))
	}
	SetProgress(prog) {
		this.noteIndex := Floor(this.GetNumNotes() * prog)
		if(this.noteIndex < 1 || this.noteIndex >= this.GetNumNotes()) {
			this.noteIndex := 1
		}
	}
	
	GetNumNotes() {
		return this.GetTrack().trackNumNotes
	}
	
	GetNote(note := -1) {
		if(note == -1) {
			note := this.noteIndex
		}
		track := this.GetTrack()
		if(track) {
			if(note < 1)
				return
			if(note > track.trackNumNotes)
				return
			note := track.trackNotes[note]
			return note
		}
		return
	}
	
	NextPlayTimer() {
		if(this.noteIndex >= this.GetNumNotes()) {
			this.Stop()
			
		} else if(this.IsPlaying()) {
			note := this.GetNote()
			base.PlayNote(note.GetNoteLetter(this.octaveShift))
			ms := -Abs(note.deltaMs) / this.speedShift
			obj := this.playObject
			SetTimer % obj, % ms, -1
		}
	}
	
	PlayLoop() {
		if(base.IsPlaying()) {
			base.NextPlayTimer()
			this.NextPlayTimer()
		}
	}
	
	__New(file, track := 1){
		this.playObject := ObjBindMethod(this, "PlayLoop")
		this.trackIndex := track
		if(file) {
			this.midi := new MidiFile(file)
			this.filename := file
		}
		base.__New()
	}
}