extends RefCounted
## Maps uttered words → Fragment / Thread / Law kinds. Not a command parser.

const LEXICON_PATH := "res://content/speak_lexicon.json"

var fragments: Dictionary = {}
var threads: Dictionary = {}
var laws: Dictionary = {}
var voice_phrases: PackedStringArray = PackedStringArray()


func load_default() -> void:
	if not FileAccess.file_exists(LEXICON_PATH):
		_embed_fallback()
		return
	var raw := FileAccess.get_file_as_string(LEXICON_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		_embed_fallback()
		return
	var data: Dictionary = parsed
	fragments = data.get("fragments", {})
	threads = data.get("threads", {})
	laws = data.get("laws", {})
	var phrases: Array = data.get("voice_stub_phrases", [])
	voice_phrases = PackedStringArray()
	for p in phrases:
		voice_phrases.append(str(p))


func _embed_fallback() -> void:
	fragments = {"anchor": "Anchor", "span": "Span", "beam": "Span", "peg": "Anchor"}
	threads = {"brace": "Brace", "bind": "Brace", "feed": "Feed", "echo": "Echo"}
	laws = {"law": "Law", "stand": "Law", "seat": "Law", "hold": "Law"}
	voice_phrases = PackedStringArray(["anchor", "span", "brace", "hold the span", "law"])


## Classify a free-text utterance into matter the void can hold.
## Returns { kind, label, source_word, words }
func classify(utterance: String) -> Dictionary:
	var cleaned := utterance.strip_edges().to_lower()
	cleaned = cleaned.replace(",", " ").replace(".", " ").replace("!", " ").replace("?", " ")
	while cleaned.find("  ") >= 0:
		cleaned = cleaned.replace("  ", " ")
	if cleaned.is_empty():
		return {}
	var words: PackedStringArray = PackedStringArray(cleaned.split(" ", false))
	var joined := cleaned
	if laws.has(joined):
		return _hit("law", str(laws[joined]), joined, words)
	if threads.has(joined):
		return _hit("thread", str(threads[joined]), joined, words)
	if fragments.has(joined):
		return _hit("fragment", str(fragments[joined]), joined, words)
	for w in words:
		if laws.has(w):
			return _hit("law", str(laws[w]), w, words)
	for w in words:
		if threads.has(w):
			return _hit("thread", str(threads[w]), w, words)
	for w in words:
		if fragments.has(w):
			return _hit("fragment", str(fragments[w]), w, words)
	var label := words[0].capitalize() if words.size() == 1 else cleaned.capitalize()
	return _hit("fragment", label, cleaned, words)


func _hit(kind: String, label: String, source: String, words: PackedStringArray) -> Dictionary:
	return {
		"kind": kind,
		"label": label,
		"source_word": source,
		"words": words,
	}
