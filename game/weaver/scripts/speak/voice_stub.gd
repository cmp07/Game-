extends Node
## Stub voice→text. Real STT later; this feeds the same utterance pipeline as typing.

signal phrase_ready(text: String)
signal listening_changed(active: bool)

var lexicon: RefCounted
var _index: int = 0
var _listening: bool = false
var _typewriter_active: bool = false


func configure(lex: RefCounted) -> void:
	lexicon = lex


func is_listening() -> bool:
	return _listening


func is_busy() -> bool:
	return _listening or _typewriter_active


func begin_listen() -> void:
	if is_busy():
		return
	_listening = true
	listening_changed.emit(true)


func cancel_listen() -> void:
	_listening = false
	listening_changed.emit(false)


## Simulate a short listen, then emit a canned phrase into the typewriter path.
func complete_listen() -> String:
	if not _listening:
		return ""
	_listening = false
	listening_changed.emit(false)
	var phrase := next_phrase()
	phrase_ready.emit(phrase)
	return phrase


func next_phrase() -> String:
	if lexicon == null:
		return "span"
	var phrases: PackedStringArray = lexicon.voice_phrases
	if phrases.is_empty():
		return "span"
	var phrase := phrases[_index % phrases.size()]
	_index = (_index + 1) % maxi(1, phrases.size())
	return phrase


## Type a phrase into a callable one glyph at a time (diegetic, not instant dump).
func typewrite_into(target: Callable, phrase: String, tree: SceneTree) -> void:
	if _typewriter_active:
		return
	_typewriter_active = true
	for i in phrase.length():
		target.call(phrase.substr(0, i + 1))
		await tree.create_timer(0.045).timeout
	_typewriter_active = false
