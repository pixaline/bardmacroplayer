xor(text, key) {
	count := 1
	
	Loop % strlen(text)
	{
		out .= chr((asc(substr(text, count, 1)) ^ key))
		count += 1
	}
	return out
}

headerSize(file) {
	file.Seek(0x04, 0)
	hf := file.ReadUInt()
	if((file.Length - hf) == 32) {
		return hf
	}
	return 0
}

dataSize(file) {
	file.Seek(0x08, 0)
	return file.ReadUInt() + 16
}


readHeader(file) {
	header := {}
	header["file_size"] := headerSize(file)
	header["data_size"] := dataSize(file)
	return header
}

readSection(file, key) {
	data := xor(file.Read(3), key)
	type := Asc(SubStr(data, 1, 1))
	size := Asc(SubStr(data, 2, 1))
	; size should be read from two bytes, not 1 as above, fix this first if something breaks
	; should be fine with only keybind info, as the info is static
	if(size) {
		return xor(file.Read(size), key)
	}
	return 0
}

class ffxivKey
{
	key1 := 0
	key1mod := 0
	key2 := 0
	key2mod := 0
	
	__New(str) {
		array := StrSplit(str, .)
		this.key1 := "0x" . array[1]
		this.key1mod := "0x" . array[2]
		this.key2 := "0x" . array[3]
		this.key2mod := "0x" . array[4]
		base.__New()
	}
}

readKeybinds(filename)
{
	keyArray := {}
	file := FileOpen(filename, "r-d")
	if(file) {
		header := readHeader(file)
		if(header["file_size"] != 0) {
			file.Seek(0x11, 0)
			while(file.Pos < header["data_size"]) {
				command := readSection(file, 0x73)
				str := readSection(file, 0x73)
				keyArray[command] := new ffxivKey(str)
			}
		}
		file.Close()
	}
	return keyArray
}