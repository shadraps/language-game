class_name LEXI extends CanvasLayer

## EXPORTS ##

@export_file var vocab_list_file

## CONSTANTS ##

const DEBUG := true

const BUTTON_SELECTED_BORDER = Color("c631ffff")

## OTHER VARIABLES ##

# gui variables
@onready var main_panel: Panel = $MainPanel
@onready var word_list: VBoxContainer = $MainPanel/MarginContainer/VBoxContainer/MainContent/WordListScroll/WordList
@onready var details_v_box: VBoxContainer = $MainPanel/MarginContainer/VBoxContainer/MainContent/DetailsScroll/DetailsVBox
@onready var close_button: Button = $MainPanel/CloseButtonPanel/CloseButton
@onready var open_button: Button = $OpenButton

const DEFINITION_V_BOX = preload("uid://pi7g371u8f52")
const HORIZONTAL_LINE = preload("uid://bas2ay2m4v5tm")
const QUOTE_RICH_TEXT = preload("uid://bnmdvkvn773m1")
const SPACER = preload("uid://5vmdlnf70lrg")
const WORD_BUTTON = preload("uid://dfaw4n3nrv3r1")
const WORD_ENTRY = preload("uid://c0ef17sb7uipi")
const WORD_LABEL = preload("uid://btsrlavrw467n")
const WIKTIONARY_LINK = preload("uid://bfn83dq5ipflj")
const CREDITS_LABEL = preload("uid://6y86dvm17eg6")

# data variables
var vocab_list: Array
var vocab_defs: Dictionary
var window_open := false

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
	
	# Configuring open/close
	set_window_open(window_open)
	close_button.pressed.connect(set_window_open.bind(false))
	open_button.pressed.connect(toggle_window_open.bind())
		
	# Initializing vocabulary list
	await _initialize_vocabulary()
	update_display()

## PUBLIC METHODS ##

# opening / closing window
func set_window_open(to_set: bool) -> void:
	_dprint("Setting window open: %s, previous window_open: %s" % [to_set, window_open])
	main_panel.visible = to_set
	window_open = to_set
	
func toggle_window_open() -> void:
	set_window_open(!window_open)

# Updating display
func update_display() -> void:
	# clearing previous vocab words
	for word_button in word_list.get_children():
		word_button.queue_free()
	
	# adding new vocab words
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
			button.add_theme_stylebox_override("hover", style)
		
		# finalizing button
		button.pressed.connect(_on_word_button_pressed.bind(word))
		word_list.add_child(button)
		
	# clearing previous description
	for child in details_v_box.get_children():
		child.queue_free()
	
	# adding new description
	_dprint("Checking selected word: %s" % _selected_word)
	if _selected_word != "":
		# page title & word
		var word = _selected_word
		var word_label = WORD_LABEL.instantiate()
		word_label.text = word
		details_v_box.add_child(word_label)
		
		# adding entries
		var data = vocab_defs[word]
		for entry in data.entries:
			# data variables
			var senses = entry.senses
			var pronunciations = entry.pronunciations
			var forms = entry.forms
			
			# creating entry UI
			var line_panel = HORIZONTAL_LINE.instantiate()
			var entry_vbox = WORD_ENTRY.instantiate()
			
			# adding new definitions
			for sense in senses:
				var def_v_box = DEFINITION_V_BOX.instantiate()
				var extra = ", ".join(sense.tags)
				extra = ", " + extra if extra != "" else extra
				def_v_box.find_child("Details").text = entry.partOfSpeech + extra
				def_v_box.find_child("EnglishGloss").text = sense.definition
				entry_vbox.find_child("Definitions").add_child(def_v_box)
				
			# adding pronunciations
			var ipa_label = entry_vbox.find_child("IPAPronunciation")
			var ipa_texts: Array[String] = []
			for pronunciation in pronunciations:
				ipa_texts.append(pronunciation.text)
			ipa_label.text = ", ".join(ipa_texts)
			
			# adding other forms
			var forms_label = entry_vbox.find_child("OtherForms")
			var forms_text_lines: Array[String] = []
			for form in forms:
				forms_text_lines.append("- %s: " % form.word + ", ".join(form.tags))
			forms_label.text = "\n".join(forms_text_lines)
			forms_label.visible = false if forms_label.text == "" else true
			
			# adding entry
			details_v_box.add_child(line_panel)
			details_v_box.add_child(entry_vbox)
			
		# adding credits
		var bottom_line = HORIZONTAL_LINE.instantiate()
		details_v_box.add_child(bottom_line)
		
		var wiktionary_link = WIKTIONARY_LINK.instantiate()
		wiktionary_link.text = "[color=#9999ff][url=%s]%s[/url][/color]" % [data.source.url, data.source.url]
		details_v_box.add_child(wiktionary_link)
		
		var credits_label = CREDITS_LABEL.instantiate()
		details_v_box.add_child(credits_label)

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
		push_error("The word %s was not able to be validated. Response: " % word, data)
	
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
