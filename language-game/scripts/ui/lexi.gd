class_name LEXI extends CanvasLayer

## EXPORTS ##

@export_file var vocab_list_file

## CONSTANTS ##

const DEBUG := true

const WORD_BUTTON = preload("uid://dfaw4n3nrv3r1")

const BUTTON_SELECTED_BORDER = Color("b38100ff")

## OTHER VARIABLES ##

# gui variables
@onready var word_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MainContent/WordListScroll/WordList
@onready var details: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MainContent/DetailsScroll/Details

# data variables
var vocab_list: Array
var vocab_defs: Dictionary

# internal helper variables for initializing/validating vocabulary
signal _vocab_initialized
var _vocab_remaining := 0

# gui helper variables
var _selected_word := ""

## BUILTIN METHODS ##

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEBUG:
		var result1 = await look_up("playa")
		var result2 = await look_up("yay")
		var result3 = await look_up("playat")
		
		_dprint("playa: ", result1)
		_dprint("yay: ", result2)
		_dprint("playat: ", result3)
		
	# Initializing vocabulary list
	_initialize_vocabulary()
	update_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## PUBLIC METHODS ##

# Updating display
func update_display() -> void:
	# clearing previous vocab words
	for word_button in word_list.get_children():
		word_button.queue_free()
	
	for word in vocab_list:
		# instantiating button
		var button: Button = WORD_BUTTON.instantiate()
		button.text = word
		
		# coloring button
		var source := preload("uid://n1yq1a33u8bh")
		var style := source.duplicate() as StyleBoxFlat
		if button.text == _selected_word:
			style.border_color = BUTTON_SELECTED_BORDER
			button.add_theme_stylebox_override("normal", style)
		
		# finalizing button
		button.pressed.connect(_on_word_button_pressed.bind(word))
		word_list.add_child(button)

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
	
## EVENT LISTENERS

func _on_word_button_pressed(word: String):
	_dprint("Selected word %s" % word)
	_selected_word = word
	
	# updating display
	update_display()
	
## PRIVATE HELPER METHODS ##

func _initialize_vocabulary():
	# getting vocab list as array
	vocab_list = _load_vocab_list()
	vocab_list.sort()
	_dprint("Registered vocab list: ", vocab_list)
	
	# looking up and verifying individual words in vocab list
	_vocab_remaining = vocab_list.size()
	for word in vocab_list:
		_initialize_one_word(word)
		
	if _vocab_remaining > 0:
		await _vocab_initialized
		
	_dprint("Finished validations: ", vocab_defs.keys())
		
func _initialize_one_word(word: String):
	_dprint("Validating word %s" % word)
	var data = await look_up(word)
	_vocab_remaining -= 1
	if _vocab_remaining <= 0:
		_vocab_initialized.emit()
	
	# checking for error message
	if data is String:
		push_error("The word %s was not able to be validated. Response: ", data)
	
	# adding data and definition entries
	vocab_defs[word] = data

func _load_vocab_list() -> Array:
	var file = FileAccess.open(vocab_list_file, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return []

func _dprint(...args: Array) -> void:
	if DEBUG:
		print.callv(args)
