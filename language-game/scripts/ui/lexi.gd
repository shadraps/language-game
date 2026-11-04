class_name LEXI extends CanvasLayer

## CONSTANTS ##

const DEBUG := true

## BUILTIN METHODS ##

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEBUG:
		var result1 = await look_up("playa")
		var result2 = await look_up("yay")
		var result3 = await look_up("biblioteca")
		
		_dprint("playa: ", result1)
		_dprint("yay: ", result2)
		_dprint("biblioteca: ", result3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## PUBLIC METHODS ##


# Looking up words
func look_up(word: String) -> Variant:
	assert(not word.is_empty())
	
	# attemping to start request
	_dprint("New word lookup: ", word, " ----------------------")
	var http := HTTPRequest.new()
	add_child(http)
	
	var url := "https://freedictionaryapi.com/api/v1/entries/es/%s?translations=true" % word.uri_encode()
	var start_error := http.request(url)
	
	if start_error != OK:
		http.queue_free()
		return "Could not start request (error %s)." % start_error
		
	# Getting response and JSON data
	_dprint("Created HTTP object successfully, sending request")
	var response: Array = await http.request_completed
	http.queue_free()
	
	var result: int = response[0]
	var response_code: int = response[1]
	var body: PackedByteArray = response[3]
	var body_text := body.get_string_from_utf8()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		return "Network request failed (result %s)." % result
		
	if response_code < 200 or response_code >= 300:
		return "API returned HTTP %s: %s" % [response_code, body_text]
		
	# Parsing retrieved JSON code
	var parser := JSON.new()
	var parse_error := parser.parse(body_text)
	
	if parse_error != OK:
		return "Could not parse API JSON: %s" % parser.get_error_message()
		
	var data = parser.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return "API response was not a JSON object."
		
	if data.has("entries") and data["entries"] is Array and data["entries"].is_empty():
		return "No entry found for \"%s\"." % word
		
	# returning data
	return data
	
## PRIVATE HELPER METHODS ##

func _dprint(...args: Array) -> void:
	if DEBUG:
		print.callv(args)
